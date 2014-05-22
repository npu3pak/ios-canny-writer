//
//  ImagesPageContentController.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImagesPageContentController.h"
#import "Record.h"
#import "Photo.h"

@implementation ImagesPageContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageWithData:self.photo.photo];
    //TODO обработать сообщение об ошибке, если не удалось загрузить фотографию
    self.imageView.image = image;
}

@end
