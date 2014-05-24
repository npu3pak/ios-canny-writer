//
//  PhotosCollectionCell.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 24.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "PhotosCollectionCell.h"
#import "Photo.h"

@implementation PhotosCollectionCell

- (void)showPhoto:(Photo *)photo {
    self.imageView.image = [UIImage imageWithData:photo.thumbnail];
}


@end
