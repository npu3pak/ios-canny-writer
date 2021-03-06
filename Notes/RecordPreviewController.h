//
//  RecordPreviewController.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import "RecordSearchController.h"
#import "MWPhotoBrowser.h"

@class Record;
@class TextView;

@interface RecordPreviewController : UIViewController <UITextFieldDelegate, SearchDelegate, WYPopoverControllerDelegate, UIActionSheetDelegate, MWPhotoBrowserDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(strong, nonatomic) Record *record;
@property(strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBarButton;
@property(weak, nonatomic) IBOutlet UITextField *titleTextField;
@property(weak, nonatomic) IBOutlet TextView *textView;

- (void)showRecord;

- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender;

@end
