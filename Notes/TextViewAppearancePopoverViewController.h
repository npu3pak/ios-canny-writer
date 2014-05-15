//
// Created by Евгений Сафронов on 15.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextView;

@interface TextViewAppearancePopoverViewController : UIViewController {
}
- (IBAction)onMakeBiggerClick:(id)sender;

- (IBAction)onMakeSmallerClick:(id)sender;

+ (TextViewAppearancePopoverViewController *)instanceFromStoryboard;

@property TextView *textView;

@end