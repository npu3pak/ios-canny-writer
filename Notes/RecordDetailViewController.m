//
//  RecordDetailViewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordDetailViewController.h"
#import "Record.h"
#import "History.h"
#import "HistoryViewController.h"
#import "NSString+WordCount.h"
#import "VKontakteActivity.h"

@implementation RecordDetailViewController {
    NSRange _lastEditRange;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self observeKeyboard];
    [self refreshView];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTextViewTap)];
    [singleTap setNumberOfTapsRequired:1];
    [self.textView addGestureRecognizer:singleTap];
}

- (void)refreshView {
    if (self.record) {
        _textPaddingTop.constant = _titleTextField.frame.size.height;
        _titleTextField.text = _record.title;
        [self setText:_record.text];
        [self recalculateStatus];
        if (_textView.text != nil)
            _lastEditRange = NSMakeRange(0, 0);
        if (_record.text == nil)
            [self startTextEditing];
    }
}

- (void)setText:(NSString *)text {
    _textView.text = text;
    _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
}

- (void)setAttributedText:(NSAttributedString *)text {
    _textView.attributedText = text;
    _textView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
}

#pragma mark - Изменяем размер поля ввода при появлении и скрытии клавиатуры

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    BOOL isPortrait = UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation);
    CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
    self.keyboardHeight.constant = height;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat bottomBarHeight = self.bottomToolbar.frame.size.height;
    self.keyboardHeight.constant = bottomBarHeight;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender {
    [self startTextEditing];
}

- (void)startTextEditing {
//Скрываем заголовок
    _titleTextField.hidden = YES;
    //Прячем нижнюю панель - она скрывается за клавиатурой
    self.bottomToolbar.hidden = YES;
    //Корректируем отступ текстовой области
    self.textPaddingTop.constant = self.topToolbar.frame.size.height + self.statusMessage.frame.size.height;
    //Корректируем отступ панели статуса
    self.statusPaddingTop.constant = self.topToolbar.frame.size.height;
    self.statusMessage.hidden = NO;
    //Скрываем панель навигации и вместо нее показываем панель инструментов
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.topToolbar.hidden = NO;
    //Включаем возможность редактировать содержимое текстового поля
    self.textView.editable = true;
    //Передаем фокус текстовому полю, показываем клавиатуру
    [self.textView becomeFirstResponder];
    //Перемещаем курсор в начало текста
    self.textView.selectedRange = _lastEditRange;
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}

- (IBAction)onEditDoneButtonClick:(UIBarButtonItem *)sender {
    if (![self.textView.text isEqualToString:_record.text])
        [self saveText];
    self.bottomToolbar.hidden = NO;
    self.textView.editable = false;
    self.topToolbar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.textPaddingTop.constant = _titleTextField.frame.size.height;
    self.statusPaddingTop.constant = 0;
    self.statusMessage.hidden = YES;
    _lastEditRange = _textView.selectedRange;
    //Показываем заголовок
    _titleTextField.hidden = NO;
}

- (void)saveText {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:_managedObjectContext];
    History *history = [[History alloc] initWithEntity:entity insertIntoManagedObjectContext:_managedObjectContext];
    history.text = _textView.text;
    history.changeDate = [NSDate date];
    history.record = _record;
    _record.text = _textView.text;
    _record.changeDate = [NSDate date];
    [_managedObjectContext save:nil];
    [_record removeOldHistoryItems];
    [_managedObjectContext save:nil];
}

- (IBAction)onShowHistoryButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"showHistory" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showHistory"]) {
        [[segue destinationViewController] setRecord:_record];
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
        [[segue destinationViewController] setRecordDetailViewController:self];
    }
}

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender {
    //Скрываем заголовок
    _titleTextField.hidden = YES;
    self.searchBar.text = nil;
    //Прячем нижнюю панель - она скрывается за клавиатурой
    self.bottomToolbar.hidden = YES;
    //Корректируем отступ текстовой области
    if (self.statusMessage.hidden)
        self.textPaddingTop.constant = self.searchBar.frame.size.height;
    else
        self.textPaddingTop.constant = self.searchBar.frame.size.height + self.statusMessage.frame.size.height;
    //Скрываем панель навигации и вместо нее показываем панель поиска
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.topToolbar.hidden = YES;
    self.searchBar.hidden = NO;
    [self.searchBar becomeFirstResponder];
}

- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender {
    [self.textView.undoManager undo];
}

- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender {
    [self.textView.undoManager redo];
}

- (IBAction)onCameraButtonClick:(UIBarButtonItem *)sender {
}

- (IBAction)onShareButtonClick:(UIBarButtonItem *)sender {
    NSString *text = self.textView.text;
    NSArray *items = @[text];

    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];

    UIActivityViewController *activity = [[UIActivityViewController alloc]
            initWithActivityItems:items
            applicationActivities:@[vkontakteActivity]];

    [self presentViewController:activity animated:YES completion:nil];
    
    
}

- (void)textViewDidChange:(UITextView *)textView {
    [self recalculateStatus];
}

- (void)recalculateStatus {
    int wordsCount = (int) _textView.text.wordCount;
    int charsCount = (int) _textView.text.length;
    _statusMessage.text = [NSString stringWithFormat:@"Знаков:%d   Слов:%d", charsCount, wordsCount];
}

#pragma mark - Search

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (!_textView.isEditable)
        _titleTextField.hidden = NO;
    self.bottomToolbar.hidden = _textView.editable;
    self.topToolbar.hidden = !_textView.editable;

    [self.navigationController setNavigationBarHidden:_textView.editable animated:YES];

    //Корректируем отступ текстовой области
    if (self.statusMessage.hidden)
        self.textPaddingTop.constant = self.topToolbar.frame.size.height;
    else
        self.textPaddingTop.constant = self.topToolbar.frame.size.height + self.statusMessage.frame.size.height;

    self.searchBar.hidden = YES;
    [self cancelTextSelection];
    [self.textView becomeFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSString *searchSource = _textView.text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:searchSource];
        NSRange nearest = NSMakeRange(NSNotFound, 0);
        UIColor *yellowColor = [UIColor yellowColor];
        NSRange textRange = NSMakeRange(0, 0);
        while (textRange.location != NSNotFound) {
            NSRange searchRange = NSMakeRange(textRange.location + textRange.length, searchSource.length - textRange.location - textRange.length);
            textRange = [searchSource rangeOfString:searchText options:NSCaseInsensitiveSearch range:searchRange];
            if (textRange.location != NSNotFound) {
                [attributedString addAttribute:NSBackgroundColorAttributeName value:yellowColor range:textRange];
                if(nearest.length == 0 && nearest.location == NSNotFound)
                    nearest = textRange;
            }
        }
        _lastEditRange = NSMakeRange(nearest.location, 0);
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            [self setAttributedText:attributedString];
            if (nearest.location != NSNotFound && nearest.length != 0)
                [self.textView scrollRangeToVisible:nearest];
        });
    });
}

- (void)cancelTextSelection {
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.textView.text];
    [attrStr removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, self.textView.text.length)];
    [self setAttributedText:attrStr];
    return;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    if (_textView.editable) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self cancelTextSelection];
}

- (void)handleTextViewTap {
    if (!_textView.isEditable && _searchBar.hidden)
        [self.view endEditing:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    _record.title = _titleTextField.text;
    [_managedObjectContext save:nil];
    [super viewWillDisappear:animated];
}

@end
