//
// Created by Евгений Сафронов on 24.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImageController.h"
#import "Photo.h"


@implementation ImageController

- (void)viewDidLoad {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
    self.imageView.image = [UIImage imageWithData:self.photo.photo];
}

- (void)onTap {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end