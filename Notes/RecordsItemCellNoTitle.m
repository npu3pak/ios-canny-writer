//
//  RecordsItemCellNoTitle.m
//  Notes
//
//  Created by Евгений Сафронов on 02.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordsItemCellNoTitle.h"

@implementation RecordsItemCellNoTitle

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
        self.preview.textColor = [UIColor whiteColor];
    } else {
        self.preview.textColor = [UIColor darkGrayColor];
    }
}
@end
