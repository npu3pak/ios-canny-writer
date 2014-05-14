//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "TextView.h"
#import "Preferences.h"


@implementation TextView {
    Preferences *_preferences;
}

- (void)setText:(NSString *)text {
    if (!_preferences)
        _preferences = [[Preferences alloc] init];
    super.text = text; //Не self. Иначе зациклится
    self.font = [UIFont fontWithName:_preferences.fontName size:_preferences.fontSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedString {
    if (!_preferences)
        _preferences = [[Preferences alloc] init];
    super.attributedText = attributedString; //Не self
    self.font = [UIFont fontWithName:_preferences.fontName size:_preferences.fontSize];
}

@end