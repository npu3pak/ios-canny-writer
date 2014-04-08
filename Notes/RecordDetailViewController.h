//
//  RecordDetailViewController.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface RecordDetailViewController : UIViewController <UISearchBarDelegate, UITextViewDelegate>

@property (strong, nonatomic) Record* record;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textPaddingTop;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender;

- (void)refreshView;

- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onCameraButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onEditDoneButtonClick:(UIBarButtonItem *)sender;
- (IBAction)onShowHistoryButtonClick:(UIBarButtonItem *)sender;

@end
