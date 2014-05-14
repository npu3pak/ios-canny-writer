//
//  HistoryPageContentController.m
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "HistoryPageContentController.h"
#import "History.h"

@implementation HistoryPageContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView.text = _historyItem.text;

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd.MM.yyyy     HH:mm:ss"];

    _timeStampText.text = [dateFormat stringFromDate:_historyItem.changeDate];
}

@end
