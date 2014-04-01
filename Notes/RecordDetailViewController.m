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

- (void)setRecord:(id)newRecord {
    if (_record != newRecord) {
        _record = newRecord;
        [self configureView];
    }
}

- (void)configureView {
    if (self.record) {
        self.detailDescriptionLabel.text = [_record.creationDate description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

@end
