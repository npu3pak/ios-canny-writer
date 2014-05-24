//
// Created by Евгений Сафронов on 24.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;


@interface ImageController : UIViewController{}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property Photo *photo;

@end