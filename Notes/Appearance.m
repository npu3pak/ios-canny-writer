//
//  Appearance.m
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "Appearance.h"
#import "WYPopoverController.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation Appearance

+ (void)applyTheme {
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];


    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self setPopoverAppearance];
    }
}

+ (void)setPopoverAppearance {
    WYPopoverBackgroundView *popoverAppearance = [WYPopoverBackgroundView appearance];

    [popoverAppearance setGlossShadowColor:[UIColor clearColor]];
    [popoverAppearance setGlossShadowOffset:CGSizeMake(0, 0)];

    [popoverAppearance setInnerShadowBlurRadius:0];
    [popoverAppearance setInnerShadowColor:[UIColor clearColor]];
    [popoverAppearance setInnerShadowOffset:CGSizeMake(0, 0)];

    UIColor *whiteColor = [UIColor whiteColor];
    [popoverAppearance setFillTopColor:whiteColor];
    [popoverAppearance setFillBottomColor:whiteColor];
    [popoverAppearance setOuterStrokeColor:[UIColor whiteColor]];
    [popoverAppearance setInnerStrokeColor:whiteColor];
}


@end
