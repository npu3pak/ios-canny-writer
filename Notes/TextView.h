//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TextView : UITextView
- (void)setText:(NSString *)text;

- (void)setAttributedText:(NSAttributedString *)attributedString;

- (void)makeFontBigger;

- (void)makeFontSmaller;

@end