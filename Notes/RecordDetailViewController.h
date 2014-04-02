//
//  RecordDetailViewController.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface RecordDetailViewController : UIViewController

@property (strong, nonatomic) Record* record;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textPaddingTop;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onSearchFromEditClick:(UIBarButtonItem *)sender;
- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onCameraButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onEditDoneButtonClick:(UIBarButtonItem *)sender;

@end
