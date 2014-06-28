//
//  RecordTextEditorController.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 12.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordTextEditorController.h"
#import "NSString+WordCount.h"
#import "Record.h"
#import "KeyboardLettersExtension.h"
#import "History.h"
#import "TextView.h"
#import "TextViewAppearancePopoverViewController.h"
#import "WYPopoverController.h"
#import "WYStoryboardPopoverSegue.h"

static NSString *const kSegueFindText = @"findText";

@implementation RecordTextEditorController {
    KeyboardLettersExtension *_keyboardExtension;
    NSValue *_selectedRangeValue;
    WYPopoverController *_wyPopoverController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showText];
    [self updateStatus];
    [self observeKeyboardSizeChanges];
    [self initializeKeyboardExtension];
    [self startEditing];
    [self resizeToolbars:0];
}

- (void)showText {
    self.textView.text = self.record.text;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scrollToSearchResult];
    self.textView.becomeFirstResponder;
}

//Пропихиваем в навконтроллер экран просмотра записи.
//В лог пишется предупреждение о том, что пытаемся править UI, который не показан на экране
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isNewRecord) {
        self.isNewRecord = NO;
        [self.recordsNavigationController pushViewController:self.recordPreviewController animated:NO];
    }
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

- (void)startEditing {
    self.textView.selectedRange = NSMakeRange(0, 0);
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateStatus];
}

- (void)updateStatus {
    int wordsCount = (int) self.textView.text.wordCount;
    int charsCount = (int) self.textView.text.length;
    NSString *statusTemplate = NSLocalizedString(@"StatisticsTemplate", @"Знаков:%d   Слов:%d");
    self.statusLabel.text = [NSString stringWithFormat:statusTemplate, charsCount, wordsCount];
}

- (void)observeKeyboardSizeChanges {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//Уменьшаем размер текстовой области так, чтобы она не закрывалась клавиатурой
- (void)keyboardWillShow:(NSNotification *)notification {
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSValue *keyboardFrame = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = keyboardFrame.CGRectValue.size;
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? keyboardSize.height : keyboardSize.width;
    self.textPaddingBottom.constant = height;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

//Восстановливаем размер текстовой области после скрытия клавиатуры
- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval animationDuration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    self.textPaddingBottom.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)initializeKeyboardExtension {
    _keyboardExtension = [[KeyboardLettersExtension alloc] initWithTargetTextView:self.textView
                                                                          symbols:@[@".", @",", @"!", @"?", @"'", @"\"", @":", @";", @"-"]
                                                                           height:self.toolbarHeightForCurrentOrientation
                                                                            width:self.view.frame.size.width];
}

- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender {
    [self.textView.undoManager undo];
}

- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender {
    [self.textView.undoManager redo];
}

- (IBAction)onSwitchKeyboardExtensionClick:(UIBarButtonItem *)sender {
    self.textView.inputAccessoryView = self.textView.inputAccessoryView == nil ? _keyboardExtension : nil;
    [self.textView reloadInputViews];
}

- (IBAction)onDoneButtonClick:(UIBarButtonItem *)sender {
    if (![self.textView.text isEqualToString:self.record.text])
        [self saveText];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveText {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:self.managedObjectContext];
    History *history = [[History alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    history.text = self.textView.text;
    history.changeDate = [NSDate date];
    history.record = self.record;
    self.record.text = self.textView.text;
    self.record.changeDate = [NSDate date];
    [self.managedObjectContext save:nil];
    [self.record removeOldHistoryItems];
    [self.managedObjectContext save:nil];
}

//Меняем размер панелей при повороте экрана
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self resizeToolbars:duration];
}

- (void)resizeToolbars:(NSTimeInterval)duration {
    CGFloat newHeight = self.toolbarHeightForCurrentOrientation;
    [UIView animateWithDuration:duration animations:^{
        self.toolbarHeight.constant = newHeight; //Похоже, единственный способ изменить размер панели инструментов
        _keyboardExtension.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
    }];
}

- (CGFloat)toolbarHeightForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 44 : 32;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueFindText]) {
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

#pragma mark Реализация протокола SearchDelegate

- (void)onTextFoundInRange:(NSRange)range {
    //Сохраняем позицию найденного текста. Потом, в viewWillAppear мы отмотаем туда наш textView и перетащим туда курсор
    _selectedRangeValue = [NSValue valueWithRange:NSMakeRange(range.location, 0)];
}

@end
