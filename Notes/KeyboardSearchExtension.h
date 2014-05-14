//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>


#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface KeyboardSearchExtension : UIToolbar

- (instancetype)initWithDelegate:(id)aDelegate onCancelSelector:(SEL)anOnCancelSelector onNextSelector:(SEL)anOnNextSelector onPreviousSelector:(SEL)anOnPreviousSelector height:(CGFloat)height width:(CGFloat)width;
@end