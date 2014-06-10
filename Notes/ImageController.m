//
// Created by Евгений Сафронов on 24.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImageController.h"
#import "Photo.h"
#import "Record.h"


@implementation ImageController {
    UIColor *_defaultNavBarColor;
}

- (void)viewDidLoad {
    [self showButtons];
    [self addTapRecognizer];
    [self showImage];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _defaultNavBarColor = self.navigationController.navigationBar.tintColor;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBar.translucent = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.tintColor = _defaultNavBarColor;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)showButtons {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteImage:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

- (void)deleteImage:(id)sender {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actionSheetAddCancel", @"Отмена")
                                            destructiveButtonTitle:NSLocalizedString(@"actionSheetDeleteRecord", @"Удалить изображение")
                                                 otherButtonTitles:nil];
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.record removeFromDiskPhoto:self.photo];
        [self.record removePhotosObject:self.photo];
        [self.managedObjectContext save:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    NSData *jpegData = [NSData dataWithContentsOfFile:self.photo.uri];
    self.imageView.image = [UIImage imageWithData:jpegData];
}


@end