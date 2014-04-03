//
//  HistoryViewController.h
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface HistoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UILabel *emptyHistoryLabel;

@property (strong, nonatomic) Record* record;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
