//
// Created by Евгений Сафронов on 24.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImageController.h"
#import "Photo.h"
#import "Record.h"


@implementation ImageController

- (void)viewDidLoad {
    [self showButtons];
    [self addTapRecognizer];
    [self showImage];
}

- (void)showButtons {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImage:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)deleteImage:(id)sender {
    [self.record removePhotosObject:self.photo];
    [self.managedObjectContext save:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTapRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
}

- (void)onTap {
    BOOL isHidden = self.navigationController.isNavigationBarHidden;
    [self.navigationController setNavigationBarHidden:!isHidden animated:YES];
}

- (void)showImage {
    self.imageView.image = [UIImage imageWithData:self.photo.photo];
}


@end