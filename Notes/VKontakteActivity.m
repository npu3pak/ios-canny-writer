#import "VKontakteActivity.h"
#import "VKSdk.h"
#import "MBProgressHUD.h"

@interface VKontakteActivity () <VKSdkDelegate>

@property(nonatomic, strong) UIViewController *parent;
@property(nonatomic, strong) MBProgressHUD *HUD;

@property NSMutableArray *images;
@property NSString *text;

@end

static NSString *kAppID = @"4339505";

@implementation VKontakteActivity

#pragma mark - NSObject

- (id)initWithParent:(UIViewController *)parent {
    if ((self = [super init])) {
        self.parent = parent;
    }

    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType {
    return @"VKActivityTypeVKontakte";
}

- (NSString *)activityTitle {
    return @"VKontakte";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"vk_activity"];
}


- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (UIActivityItemProvider *item in activityItems) {
        if (![item isKindOfClass:[UIImage class]] && ![item isKindOfClass:[NSString class]])
            return NO;
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    _images = @[].mutableCopy;
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.text = item;
        }
        else if ([item isKindOfClass:[UIImage class]]) {
            [_images addObject:item];
        }
    }
}

- (void)performActivity {
    [VKSdk initializeWithDelegate:self andAppId:kAppID];

    if ([VKSdk wakeUpSession]) {
        [self uploadRecord];
    }
    else {
        [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
    }
}

#pragma mark - Upload

- (void)uploadRecord {
    [self begin];


    //Получаем авторизационную инфу
    NSString *userId = [VKSdk getAccessToken].userId;
    if (userId == nil) {
        [self end];
        return;
    }

    //Если только текст - отправляем его и на этом считаем миссию завершенной
    if (self.images == nil || self.images.count == 0) {
        [self postToWall:@{VK_API_FRIENDS_ONLY : @(0),
                VK_API_OWNER_ID : userId,
                VK_API_MESSAGE : self.text}];
        return;
    }

    //Готовим запрос на загрузку картинок
    NSMutableArray *imageUploadRequests = @[].mutableCopy;
    for (UIImage *image in _images) {
        VKRequest *uploadRequest = [VKApi uploadWallPhotoRequest:image parameters:[VKImageParameters jpegImageWithQuality:1.0] userId:userId.longLongValue groupId:0];
        [imageUploadRequests addObject:uploadRequest];
    }
    VKBatchRequest *uploadBatchRequest = [[VKBatchRequest alloc] initWithRequestsArray:imageUploadRequests];

    //Загружаем картинки на сервер
    [uploadBatchRequest executeWithResultBlock:^(NSArray *responses) {
        //Картинки загружены - готовим аттачи к записи
        NSMutableArray *photosAttachments = [NSMutableArray new];
        for (VKResponse *resp in responses) {
            VKPhoto *photoInfo = [(VKPhotoArray *) resp.parsedModel objectAtIndex:0];
            [photosAttachments addObject:[NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id]];
        }

        //Готовим параметры для отправки записи на стену
        [self postToWall:@{VK_API_ATTACHMENTS : [photosAttachments componentsJoinedByString:@","],
                VK_API_FRIENDS_ONLY : @(0),
                VK_API_OWNER_ID : userId,
                VK_API_MESSAGE : self.text}];

    }                               errorBlock:^(NSError *error) {
        //Произошла ошибка
        [self showErrorMessage:error.localizedDescription];
        [self end];
    }];
}

- (void)postToWall:(NSDictionary *)params {
    VKRequest *post = [[VKApi wall] post:params];
    [post executeWithResultBlock:^(VKResponse *response) {
        NSNumber *postId = response.json[@"post_id"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall%@_%@", [VKSdk getAccessToken].userId, postId]]];
        [self end];
    }                 errorBlock:^(NSError *error) {
        [self showErrorMessage:error.localizedDescription];
        [self end];
    }];
}

- (void)showErrorMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorDialogTitle", @"Ошибка") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ErrorDialogButtonClose", @"Закрыть") otherButtonTitles:nil];
    [alert show];
}

- (void)begin {
    UIView *view = self.parent.view.window;
    self.HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = NSLocalizedString(@"HudLabelLoading", @"Загрузка...");
    [self.HUD show:YES];
}

- (void)end {
    [self.HUD hide:YES];
    [self activityDidFinish:YES];
}

#pragma mark - vkSdk

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.parent];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self uploadRecord];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.parent presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkAcceptedUserToken:(VKAccessToken *)token {
    [self uploadRecord];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Access denied"
                                                       delegate:self
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
    [alertView show];

    [self end];
}

@end
