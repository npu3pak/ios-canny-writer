//
// Created by Евгений Сафронов on 12.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Preferences : NSObject

- (NSString *)textViewFontName;

- (CGFloat)textViewFontSize;

- (void)setTextViewFontSize:(CGFloat)size;

@end