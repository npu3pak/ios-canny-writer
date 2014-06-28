//
// Created by Евгений Сафронов on 21.06.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "CopyTextOnlyActivity.h"


@implementation CopyTextOnlyActivity {
    UIViewController *_parent;
    NSMutableString *_textToCopy;
}

- (id)initWithParent:(UIViewController *)parent {
    if ((self = [super init])) {
        _parent = parent;
    }

    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType {
    return @"ActivityTypeCopyTextOnly";
}

- (NSString *)activityTitle {
    return @"Скопировать текст";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"ActivityCopyText"];
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
    for (id item in activityItems) {
        if (item != nil && [item isKindOfClass:[NSString class]]) {
            [_textToCopy appendString:item];
        }
    }
}

- (void)performActivity {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = _textToCopy;
    [self activityDidFinish:YES];
}

@end