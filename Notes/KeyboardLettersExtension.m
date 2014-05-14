//
// Created by Евгений Сафронов on 14.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "KeyboardLettersExtension.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation KeyboardLettersExtension {
    UITextView *targetTextView;
    NSArray *symbols;
}

- (instancetype)initWithTargetTextView:(UITextView *)aTargetTextView symbols:(NSArray *)aSymbols height:(CGFloat)height width:(CGFloat)width {
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, width, height)];
    if (self) {
        targetTextView = aTargetTextView;
        symbols = aSymbols;
        self.tintColor = SYSTEM_VERSION_LESS_THAN(@"7.0")
                ? [UIColor colorWithRed:0.56f green:0.59f blue:0.63f alpha:1.0f]
                : [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
        self.translucent = NO;
        self.items = self.keyboardButtons;
    }
    return self;
}

- (NSArray *)keyboardButtons {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    for (NSString *symbol in symbols) {
        [buttons addObject:separator];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:symbol
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(barButtonAddText:)];
        [button setWidth:30];
        [buttons addObject:button];
    }
    [buttons addObject:separator];
    return buttons;
}


- (IBAction)barButtonAddText:(UIBarButtonItem *)sender {
    if (targetTextView.isFirstResponder) {
        [targetTextView insertText:sender.title];
    }
}


@end