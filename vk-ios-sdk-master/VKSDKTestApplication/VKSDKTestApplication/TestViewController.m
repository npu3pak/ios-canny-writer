//
//  TestViewController.m
//
//  Copyright (c) 2014 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TestViewController.h"
#import "VKSdk.h"
#import "ApiCallViewController.h"
@implementation TestViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleDone target:self action:@selector(logout:)];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)getUser:(id)sender {
	VKRequest *request = [[VKApi users] get];
	[request executeWithResultBlock: ^(VKResponse *response) {
	    NSLog(@"Result: %@", response);
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
	}];
}

- (IBAction)getSubscriptions:(id)sender {
    VKRequest * request = [[VKApi users] getSubscriptions:@{VK_API_EXTENDED : @(1), VK_API_COUNT : @(100)}];
    request.secure = NO;
    [request executeWithResultBlock:^(VKResponse *response) {
        NSLog(@"Result: %@", response);

    } errorBlock:^(NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

static NSArray *labels = nil;
static NSString *const USERS_GET   = @"users.get";
static NSString *const FRIENDS_GET = @"friends.get";
static NSString *const FRIENDS_GET_FULL = @"friends.get with fields";
static NSString *const USERS_SUBSCRIPTIONS = @"Pavel Durov subscribers";
static NSString *const UPLOAD_PHOTO = @"Upload photo to wall";
static NSString *const UPLOAD_PHOTO_ALBUM = @"Upload photo to album";
static NSString *const UPLOAD_PHOTOS = @"Upload several photos to wall";
static NSString *const TEST_CAPTCHA = @"Test captcha";
static NSString *const CALL_UNKNOWN_METHOD = @"Call unknown method";
static NSString *const TEST_VALIDATION = @"Test validation";

//Fields
static NSString *const ALL_USER_FIELDS = @"id,first_name,last_name,sex,bdate,city,country,photo_50,photo_100,photo_200_orig,photo_200,photo_400_orig,photo_max,photo_max_orig,online,online_mobile,lists,domain,has_mobile,contacts,connections,site,education,universities,schools,can_post,can_see_all_posts,can_see_audio,can_write_private_message,status,last_seen,common_count,relation,relatives,counters";
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!labels)
		labels = @[USERS_GET, USERS_SUBSCRIPTIONS, FRIENDS_GET, FRIENDS_GET_FULL, UPLOAD_PHOTO, UPLOAD_PHOTO_ALBUM, UPLOAD_PHOTOS, TEST_CAPTCHA, CALL_UNKNOWN_METHOD, TEST_VALIDATION];
	return labels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestRow"];
	UILabel *label = (UILabel *)[cell viewWithTag:1];
	label.text = labels[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *label = labels[indexPath.row];
	if ([label isEqualToString:USERS_GET]) {
		[self callMethod:[[VKApi users] get:@{ VK_API_FIELDS : ALL_USER_FIELDS }]];

	}
	else if ([label isEqualToString:USERS_SUBSCRIPTIONS]) {
        [self callMethod:[VKRequest requestWithMethod:@"users.getFollowers" andParameters:@{VK_API_USER_ID : @"1", VK_API_COUNT : @(1000), VK_API_FIELDS : ALL_USER_FIELDS} andHttpMethod:@"GET" classOfModel:[VKUsersArray class]]];
	}
	else if ([label isEqualToString:UPLOAD_PHOTO]) {
		[self uploadPhoto];
	}
	else if ([label isEqualToString:UPLOAD_PHOTOS]) {
		[self uploadPhotos];
	}
	else if ([label isEqualToString:TEST_CAPTCHA]) {
		[self testCaptcha];
	}
	else if ([label isEqualToString:UPLOAD_PHOTO_ALBUM]) {
		[self uploadInAlbum];
	}
	else if ([label isEqualToString:FRIENDS_GET]) {
		[self callMethod:[[VKApi friends] get]];
	}
	else if ([label isEqualToString:FRIENDS_GET_FULL]) {
		VKRequest *friendsRequest = [[VKApi friends] get:@{ VK_API_FIELDS : ALL_USER_FIELDS}];
		[self callMethod:friendsRequest];
	}
    else if ([label isEqualToString:CALL_UNKNOWN_METHOD]) {
		[self callMethod:[VKRequest requestWithMethod:@"I.am.Lord.Voldemort" andParameters:nil andHttpMethod:@"POST"]];
	}
    else if ([label isEqualToString:TEST_VALIDATION]) {
        [self callMethod:[VKRequest requestWithMethod:@"account.testValidation" andParameters:nil andHttpMethod:@"GET"]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([[segue identifier] isEqualToString:@"API_CALL"]) {
		ApiCallViewController *vc = [segue destinationViewController];
		vc.callingRequest = self->callingRequest;
		self->callingRequest = nil;
	}
}

- (void)callMethod:(VKRequest *)method {
	self->callingRequest = method;
	[self performSegueWithIdentifier:@"API_CALL" sender:self];
}

- (void)testCaptcha {
	VKRequest *request = [[VKApiCaptcha new] force];
	[request executeWithResultBlock: ^(VKResponse *response) {
	    NSLog(@"Result: %@", response);
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
	}];
}

- (void)uploadPhoto {
	VKRequest *request = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
	[request executeWithResultBlock: ^(VKResponse *response) {
	    NSLog(@"Photo: %@", response.json);
        VKPhoto *photoInfo = [(VKPhotoArray*)response.parsedModel objectAtIndex:0];
	    NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
	    VKRequest *post = [[VKApi wall] post:@{ VK_API_ATTACHMENTS : photoAttachment, VK_API_FRIENDS_ONLY : @(1), VK_API_OWNER_ID : @"-60479154" }];
	    [post executeWithResultBlock: ^(VKResponse *response) {
	        NSLog(@"Result: %@", response);
            NSNumber * postId = response.json[@"post_id"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall-60479154_%@", postId]]];
		} errorBlock: ^(NSError *error) {
	        NSLog(@"Error: %@", error);
		}];
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
	}];
}

- (void)uploadPhotos {
	VKRequest *request1 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
	VKRequest *request2 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
	VKRequest *request3 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
	VKRequest *request4 = [VKApi uploadWallPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] userId:0 groupId:60479154];
	VKBatchRequest *batch = [[VKBatchRequest alloc] initWithRequests:request1, request2, request3, request4, nil];
	[batch executeWithResultBlock: ^(NSArray *responses) {
	    NSLog(@"Photos: %@", responses);
	    NSMutableArray *photosAttachments = [NSMutableArray new];
	    for (VKResponse * resp in responses) {
	        VKPhoto *photoInfo = [(VKPhotoArray*)resp.parsedModel objectAtIndex:0];
	        [photosAttachments addObject:[NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id]];
		}
	    VKRequest *post = [[VKApi wall] post:@{ VK_API_ATTACHMENTS : [photosAttachments componentsJoinedByString:@","], VK_API_FRIENDS_ONLY : @(1), VK_API_OWNER_ID : @"-60479154" }];
	    [post executeWithResultBlock: ^(VKResponse *response) {
	        NSLog(@"Result: %@", response);
            NSNumber * postId = response.json[@"post_id"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall-60479154_%@", postId]]];
		} errorBlock: ^(NSError *error) {
	        NSLog(@"Error: %@", error);
		}];
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
	}];
}

- (void)uploadInAlbum {
	VKRequest *request = [VKApi uploadAlbumPhotoRequest:[UIImage imageNamed:@"fat_awesome"] parameters:[VKImageParameters pngImage] albumId:181808365 groupId:60479154];
	[request executeWithResultBlock: ^(VKResponse *response) {
	    NSLog(@"Result: %@", response);
        VKPhoto * photo = [(VKPhotoArray*)response.parsedModel objectAtIndex:0];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/photo-60479154_%@", photo.id]]];
	} errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
	}];
}
- (void) logout:(id) sender {
    [VKSdk forceLogout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
