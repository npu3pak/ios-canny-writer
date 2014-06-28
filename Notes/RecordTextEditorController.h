//
//  RecordTextEditorController.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 12.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WYPopoverController/WYPopoverController.h>
#import "RecordSearchController.h"

@class Record;

@interface RecordTextEditorController : UIViewController <UITextViewDelegate, SearchDelegate, WYPopoverControllerDelegate>

@property Record *record;
@property NSManagedObjectContext *managedObjectContext;

//При добавлении новой записи сразу показываем экран редактирования.
//И потом уже из экрана редактирования пропихиваем в NavController экран просмотра
@property BOOL isNewRecord;
@property UINavigationController *recordsNavigationController;
@property UIViewController *recordPreviewController;

@property(weak, nonatomic) IBOutlet NSLayoutConstraint *textPaddingBottom;
@property(weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarHeight;
@property(weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;
@property(weak, nonatomic) IBOutlet TextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *appearanceToolbarItem;

- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender;

- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender;

- (IBAction)onDoneButtonClick:(UIBarButtonItem *)sender;

- (IBAction)onSwitchKeyboardExtensionClick:(UIBarButtonItem *)sender;

@end
