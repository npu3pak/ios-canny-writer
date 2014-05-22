//
//  ImagesController.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface ImagesController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property(strong, nonatomic) UIPageViewController *pageViewController;
@property(strong, nonatomic) Record *record;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property(weak, nonatomic) IBOutlet UILabel *emptyImagesLabel;

- (IBAction)onAddButtonClick:(UIBarButtonItem *)sender;
@end
