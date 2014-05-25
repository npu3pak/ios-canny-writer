//
//  ImagesController.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface ImagesController : UICollectionViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property(strong, nonatomic) Record *record;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)onAddClick:(id)sender;

@end
