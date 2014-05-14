//
//  RecordPreviewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordPreviewController.h"
#import "Record.h"
#import "History.h"
#import "HistoryController.h"
#import "VKontakteActivity.h"
#import "TextView.h"
#import "RecordTextEditorController.h"

static NSInteger const kToolbarItemWidth = 10;

static NSString *const kSegueEditText = @"editText";
static NSString *const kSegueFindText = @"findText";
static NSString *const kSegueShowHistory = @"showHistory";

@implementation RecordPreviewController {
    NSValue *_selectedRangeValue;
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
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(onSearchButtonClick:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:kToolbarItemWidth];
    UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarTimeMachine"] style:UIBarButtonItemStylePlain target:self action:@selector(onShowHistoryButtonClick:)];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShareButtonClick:)];
    [self setToolbarItems:@[search, fixedSpace, history, separator, share]];
    [self.navigationController setToolbarHidden:NO animated:animated];
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
    } else if ([segue.identifier isEqualToString:kSegueFindText]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setText:self.textView.text];
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
