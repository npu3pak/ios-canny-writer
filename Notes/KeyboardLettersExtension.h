//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyboardLettersExtension : UIToolbar

- (instancetype)initWithTargetTextView:(UITextView *)aTargetTextView symbols:(NSArray *)aSymbols height:(CGFloat)height width:(CGFloat)width;

@end