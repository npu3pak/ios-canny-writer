//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "KeyboardSearchExtension.h"


#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation KeyboardSearchExtension {
    id _delegate;
    SEL _onCancelSelector;
    SEL _onNextSelector;
    SEL _onPreviousSelector;
}

- (instancetype)initWithDelegate:(id)aDelegate onCancelSelector:(SEL)anOnCancelSelector onNextSelector:(SEL)anOnNextSelector onPreviousSelector:(SEL)anOnPreviousSelector height:(CGFloat)height width:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    if (self) {
        _delegate = aDelegate;
        _onCancelSelector = anOnCancelSelector;
        _onNextSelector = anOnNextSelector;
        _onPreviousSelector = anOnPreviousSelector;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
            self.tintColor = [UIColor colorWithRed:0.56f green:0.59f blue:0.63f alpha:1.0f];
        self.translucent = NO;
        self.items = self.buttons;
    }

    return self;
}

- (NSArray *)buttons {
    UIBarButtonItem *flexSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *previous = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SearchKeyboardPrevious", @"Предыдущее")
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(onPreviousClick)];
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SearchKeyboardNext", @"Следующее")
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(onNextClick)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"SearchKeyboardCancel", @"Готово")
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(onCancelClick)];
    return @[previous, next, flexSeparator, cancel];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)onPreviousClick {
    if ([_delegate respondsToSelector:_onPreviousSelector]) {
        [_delegate performSelector:_onPreviousSelector];
    }
}

- (void)onNextClick {
    if ([_delegate respondsToSelector:_onNextSelector]) {
        [_delegate performSelector:_onNextSelector];
    }
}

- (void)onCancelClick {
    if ([_delegate respondsToSelector:_onCancelSelector]) {
        [_delegate performSelector:_onCancelSelector];
    }
}

#pragma clang diagnostic pop

@end