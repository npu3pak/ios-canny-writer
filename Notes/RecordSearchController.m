//
//  RecordSearchController.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 12.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordSearchController.h"
#import "TextView.h"
#import "KeyboardSearchExtension.h"

@implementation RecordSearchController {
    KeyboardSearchExtension *_keyboardExtension;
    NSMutableArray *_allOccurrences;
    NSInteger _occurrenceIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeTextView];
    [self initializeSearchBar];
    [self observeKeyboardSizeChanges];
}

- (void)initializeTextView {
    self.textView.text = self.text;
}

- (void)initializeSearchBar {
    self.toolbarHeight.constant = self.toolbarHeightForCurrentOrientation;
    _keyboardExtension = [[KeyboardSearchExtension alloc] initWithDelegate:self
                                                          onCancelSelector:@selector(onSearchCancelled)
                                                            onNextSelector:@selector(onFindNext)
                                                        onPreviousSelector:@selector(onFindPrevious)
                                                                    height:self.toolbarHeightForCurrentOrientation
                                                                     width:self.view.frame.size.width];
    self.searchBar.inputAccessoryView = _keyboardExtension;
    self.searchBar.becomeFirstResponder;
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

- (void)onFindPrevious {
    if (_allOccurrences.count > 0) {
        if (_occurrenceIndex == 0)
            [self showOccurrenceWithIndex:_allOccurrences.count - 1];
        else {
            _occurrenceIndex--;
            [self showOccurrenceWithIndex:_occurrenceIndex];
        }
    }
}

- (void)onFindNext {
    if (_allOccurrences.count > 0) {
        if (_occurrenceIndex == _allOccurrences.count - 1)
            [self showOccurrenceWithIndex:0];
        else {
            _occurrenceIndex++;
            [self showOccurrenceWithIndex:_occurrenceIndex];
        }
    }
}

- (void)showOccurrenceWithIndex:(NSInteger)index {
    _occurrenceIndex = index;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSValue *rangeValue = _allOccurrences[index];
    NSRange range = rangeValue != nil ? rangeValue.rangeValue : NSMakeRange(NSNotFound, 0);
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
    self.textView.attributedText = attributedString;
    [self.textView scrollRangeToVisible:range];
    [_delegate onTextFoundInRange:range];
}

- (void)hideOccurrences {
    self.textView.text = self.text;
}

- (void)onSearchCancelled {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        _allOccurrences = [[NSMutableArray alloc] init];
        NSRange textRange = NSMakeRange(0, 0);
        do {
            NSRange searchRange = NSMakeRange(textRange.location + textRange.length, self.text.length - textRange.location - textRange.length);
            textRange = [self.text rangeOfString:searchText options:NSCaseInsensitiveSearch range:searchRange];
            if (textRange.location != NSNotFound) {
                [_allOccurrences addObject:[NSValue valueWithRange:textRange]];
            }
        } while (textRange.location != NSNotFound);

        dispatch_async(dispatch_get_main_queue(), ^() {
            if (_allOccurrences.count > 0) //Если поиск удачный - показываем первый найденный элемент
                [self showOccurrenceWithIndex:0];
            else
                [self hideOccurrences];
        });
    });
}

//Меняем размер панелей при повороте экрана
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    CGFloat newHeight = self.toolbarHeightForCurrentOrientation;
    [UIView animateWithDuration:duration animations:^{
        self.toolbarHeight.constant = newHeight; //Похоже, единственный способ изменить размер панели инструментов
        _keyboardExtension.frame = CGRectMake(0, 0, self.view.frame.size.width, newHeight);
    }];
}

- (CGFloat)toolbarHeightForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? 44 : 32;
}

@end
