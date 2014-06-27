//
//  RecordsItemCell.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordsItemCell.h"

@implementation RecordsItemCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self updateTextColor:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self updateTextColor:highlighted];
}

- (void)updateTextColor:(BOOL)isSelected {
    if (isSelected) {
        self.title.textColor = [UIColor whiteColor];
        self.preview.textColor = [UIColor whiteColor];
    } else {
        self.title.textColor = [UIColor blackColor];
        self.preview.textColor = [UIColor darkGrayColor];
    }
}

@end
