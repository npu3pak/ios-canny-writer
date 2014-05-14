//
//  HistoryController.h
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;
@class RecordPreviewController;

@interface HistoryController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UILabel *emptyHistoryLabel;

@property (strong, nonatomic) Record* record;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//Нужно, чтобы обновить текст после восстановления
@property RecordPreviewController *recordPreviewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *restoreButtonItem;

- (IBAction)onRestoreButtonClick:(UIBarButtonItem *)sender;

@end
