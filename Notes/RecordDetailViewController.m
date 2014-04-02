//
//  RecordDetailViewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordDetailViewController.h"
#import "Record.h"

@implementation RecordDetailViewController

- (void)viewDidLoad {
    NSLog(@"%@",@"ViewDidLoad");
    [super viewDidLoad];
    [self observeKeyboard];
    [self configureView];
}

- (void)configureView {
    if (self.record) {
        _textView.text = _record.text;
    }
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
    //Прячем нижнюю панель - она скрывается за клавиатурой
    self.bottomToolbar.hidden = YES;
    //Корректируем отступ текстовой области
    CGFloat topBarHeight = self.bottomToolbar.frame.size.height;
    self.textPaddingTop.constant = topBarHeight;
    //Скрываем панель навигации и вместо нее показываем панель инструментов
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    self.topToolbar.hidden = NO;
    //Включаем возможность редактировать содержимое текстового поля
    self.textView.editable = true;
    //Перемещаем курсор в начало текста
    self.textView.selectedRange = NSMakeRange(0, 0);
    //Передаем фокус текстовому полю, показываем клавиатуру
    [self.textView becomeFirstResponder];
}

- (IBAction)onEditDoneButtonClick:(UIBarButtonItem *)sender {
    self.bottomToolbar.hidden = NO;
    self.textView.editable = false;
    self.topToolbar.hidden = YES;
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    self.textPaddingTop.constant = 0;
}

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender {
}

- (IBAction)onSearchFromEditClick:(id)sender {
}

- (IBAction)onUndoButtonClick:(UIBarButtonItem *)sender {
    [self.undoManager undo];
}

- (IBAction)onRedoButtonClick:(UIBarButtonItem *)sender {
    [self.undoManager redo];
}

- (IBAction)onCameraButtonClick:(UIBarButtonItem *)sender {
}
@end
