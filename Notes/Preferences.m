//
// Created by Евгений Сафронов on 12.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "Preferences.h"


static NSString *const kFontName = @"HelveticaNeue";
static NSString *const kDefaultsKeyTextViewFontSize = @"TextViewFontSize";

static const int kDefaultTextViewSize = 16;

@implementation Preferences {
    NSUserDefaults *_userDefaults;
}

- (id)init {
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSString *)textViewFontName {
    return kFontName;
}

- (CGFloat)textViewFontSize {
    float size = [_userDefaults floatForKey:kDefaultsKeyTextViewFontSize];
    return size == 0 ? kDefaultTextViewSize : size;
}

- (void)setTextViewFontSize:(CGFloat)size {
    [_userDefaults setFloat:size forKey:kDefaultsKeyTextViewFontSize];
    _userDefaults.synchronize;
}

@end