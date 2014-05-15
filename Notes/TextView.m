//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "TextView.h"
#import "Preferences.h"


static const int kFontResizingStep = 2;

@implementation TextView {
    Preferences *_preferences;
}

- (void)setText:(NSString *)text {
    if (!_preferences)
        _preferences = [[Preferences alloc] init];
    super.text = text; //Не self. Иначе зациклится
    self.font = [UIFont fontWithName:_preferences.textViewFontName size:_preferences.textViewFontSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedString {
    if (!_preferences)
        _preferences = [[Preferences alloc] init];
    super.attributedText = attributedString; //Не self
    self.font = [UIFont fontWithName:_preferences.textViewFontName size:_preferences.textViewFontSize];
}

- (void)makeFontBigger {
    [self changeFontSizeBy:kFontResizingStep];
}

- (void)makeFontSmaller {
    [self changeFontSizeBy:-kFontResizingStep];
}

- (void)changeFontSizeBy:(CGFloat)sizeOffset {
    CGFloat newSize = self.font.pointSize + sizeOffset;
    CGFloat minSize = 10;
    CGFloat maxSize = 40;
    if (newSize < minSize)
        newSize = minSize;
    if (newSize > maxSize)
        newSize = maxSize;
    UIFont *newFont = [UIFont fontWithName:self.font.fontName size:newSize];
    self.font = newFont;
    [TextView appearance].font = newFont;
    _preferences.textViewFontSize = newSize;
}


@end