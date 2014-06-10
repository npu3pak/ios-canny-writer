//
//  RecordPreviewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <WYPopoverController/WYStoryboardPopoverSegue.h>
#import "RecordPreviewController.h"
#import "Record.h"
#import "History.h"
#import "HistoryController.h"
#import "VKontakteActivity.h"
#import "TextView.h"
#import "RecordTextEditorController.h"
#import "TextViewAppearancePopoverViewController.h"

static NSInteger const kToolbarItemWidth = 10;

static NSString *const kSegueEditText = @"editText";
static NSString *const kSegueFindText = @"findText";
static NSString *const kSegueShowHistory = @"showHistory";
static NSString *const kSegueShowImages = @"showImages";

@implementation RecordPreviewController {
    NSValue *_selectedRangeValue;
    WYPopoverController *_wyPopoverController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.record.text == nil)
        [self editRecordText];
    [self enableKeyboardHideOnTap];
}

//Прячем клавиатуру по тапу по текстовому полю
- (void)enableKeyboardHideOnTap {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTitleEditing)];
    [self.textView addGestureRecognizer:tapRecognizer];
}

//Прячем клавиатуру по нажатию кнопки "Done"
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endTitleEditing];
    return YES;
}

//Вызываем коллбэк textFieldShouldEndEditing
- (void)endTitleEditing {
    [self.view endEditing:YES];
}

//После окончания редактирования заголовка сохраняемся
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self saveTitle];
    return YES;
}

- (void)saveTitle {
    self.record.title = self.titleTextField.text;
    [self.managedObjectContext save:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showRecord];
    [self showBottomToolbar:animated];
    [self scrollToSearchResult];
}


//Если мы перешли сюда из окна поиска - показываем результат поиска
- (void)scrollToSearchResult {
    if (_selectedRangeValue) {
        NSRange range = _selectedRangeValue.rangeValue;
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
        _selectedRangeValue = nil;
    }
}

- (void)showRecord {
    [self.titleTextField setText:self.record.title];
    [self.textView setText:self.record.text];
}

- (void)showBottomToolbar:(BOOL)animated {
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarSearch"] style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButtonClick:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:kToolbarItemWidth];
    UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarTimeMachine"] style:UIBarButtonItemStylePlain target:self action:@selector(onShowHistoryButtonClick:)];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarShare"] style:UIBarButtonItemStylePlain target:self action:@selector(onShareButtonClick:)];
    UIBarButtonItem *changeAppearance = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarFontSize"] style:UIBarButtonItemStylePlain target:self action:@selector(onChangeTextViewAppearance:)];
    UIBarButtonItem *showImages = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(onShowImages)];;
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(askRecordDeletion)];;
    [self setToolbarItems:@[search, fixedSpace, history, fixedSpace, changeAppearance, fixedSpace, showImages, fixedSpace, delete, separator, share]];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)askRecordDeletion {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actionSheetAddCancel", @"Отмена")
                                            destructiveButtonTitle:NSLocalizedString(@"actionSheetDeleteRecord", @"Удалить запись")
                                                 otherButtonTitles:nil];
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.record removeAllPhotosFromDisk];
        [self.managedObjectContext deleteObject:self.record];
        [self.managedObjectContext save:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onShowImages {
    [self performSegueWithIdentifier:@"showImages" sender:self];
}

- (void)onChangeTextViewAppearance:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"showAppearancePopover" sender:sender];
}

- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender {
    [self endTitleEditing];
    [self editRecordText];
}

- (void)editRecordText {
    [self performSegueWithIdentifier:kSegueEditText sender:self];
}

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueFindText sender:self];
}

- (IBAction)onShowHistoryButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueShowHistory sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueShowHistory]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setRecordPreviewController:self];
    } else if ([segue.identifier isEqualToString:kSegueEditText]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:kSegueShowImages]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:kSegueFindText]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setText:self.textView.text];
    } else if ([segue.identifier isEqualToString:@"showAppearancePopover"]) {
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *) segue;
        TextViewAppearancePopoverViewController *destinationViewController = (TextViewAppearancePopoverViewController *) segue.destinationViewController;
        destinationViewController.textView = self.textView;
        destinationViewController.contentSizeForViewInPopover = CGSizeMake(100, 44);
        _wyPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        _wyPopoverController.delegate = self;
    }
}

- (IBAction)onShareButtonClick:(UIBarButtonItem *)sender {
    NSString *text = self.textView.text;
    NSArray *items = @[text];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[vkontakteActivity]];
    [self presentViewController:activity animated:YES completion:nil];
}

#pragma mark Реализация протокола SearchDelegate

- (void)onTextFoundInRange:(NSRange)range {
    //Сохраняем позицию найденного текста. Потом, в viewWillAppear мы отмотаем туда наш textView и перетащим туда курсор
    _selectedRangeValue = [NSValue valueWithRange:range];
}

@end
