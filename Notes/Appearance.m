//
//  Appearance.m
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "Appearance.h"

@implementation Appearance

+ (void)applyTheme {
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor whiteColor];

}


@end
