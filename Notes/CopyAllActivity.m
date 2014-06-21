//
// Created by Евгений Сафронов on 21.06.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "CopyAllActivity.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <MBProgressHUD/MBProgressHUD.h>


@implementation CopyAllActivity {
    UIViewController *_parent;
    NSMutableString *_textToCopy;
    NSMutableArray *_images;
    MBProgressHUD *HUD;
}

- (id)initWithParent:(UIViewController *)parent {
    if ((self = [super init])) {
        _parent = parent;
    }

    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType {
    return @"ActivityTypeCopyAll";
}

- (NSString *)activityTitle {
    return @"Скопировать с фото";
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
    _textToCopy = @"".mutableCopy;
    _images = @[].mutableCopy;
    for (id item in activityItems) {
        if (item != nil && [item isKindOfClass:NSString.class]) {
            [_textToCopy appendString:item];
        } else if (item != nil && [item isKindOfClass:UIImage.class]) {
            [_images addObject:item];
        }
    }
}

- (void)performActivity {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSMutableArray *items = @[].mutableCopy;

    NSDictionary *textDictionary = @{(NSString *) kUTTypeText : _textToCopy};
    [items addObject:textDictionary];

    for (UIImage *image in _images) {
        [items addObject:@{(NSString *) kUTTypeImage : image}];
    }

    pasteboard.items = items;
    [self activityDidFinish:YES];
}

@end