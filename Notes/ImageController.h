//
// Created by Евгений Сафронов on 24.05.14.
// Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;
@class Record;


@interface ImageController : UIViewController <UIActionSheetDelegate> {}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property Photo *photo;
@property Record *record;

@end