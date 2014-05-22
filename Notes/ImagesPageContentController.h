//
//  ImagesPageContentController.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface ImagesPageContentController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property NSUInteger pageIndex;
@property Photo *photo;

@end
