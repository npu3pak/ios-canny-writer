//
// Created by Евгений Сафронов on 15.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "TextViewAppearancePopoverViewController.h"
#import "TextView.h"


@implementation TextViewAppearancePopoverViewController {

}
- (IBAction)onMakeBiggerClick:(id)sender {
    [self.textView makeFontBigger];
}

- (IBAction)onMakeSmallerClick:(id)sender {
    [self.textView makeFontSmaller];
}

+ (TextViewAppearancePopoverViewController *)instanceFromStoryboard {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [storyboard instantiateViewControllerWithIdentifier:@"TextViewAppearancePopoverViewController"];
}

@end