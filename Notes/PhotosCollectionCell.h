//
//  PhotosCollectionCell.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 24.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Photo;

@interface PhotosCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

-(void)showPhoto:(Photo *)photo;

@end
