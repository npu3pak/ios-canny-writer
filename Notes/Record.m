//
//  Record.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "Record.h"


@implementation Record

@dynamic creationDate;
@dynamic changeDate;
@dynamic text;
@dynamic title;
@dynamic history;
@dynamic photos;

- (void)removeOldHistoryItems {
    int maxHistoryItems = 10;
    if (self.history.count > maxHistoryItems) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"changeDate" ascending:NO];
        NSArray *historyArray = [self.history.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
        self.history = [NSSet setWithArray:[historyArray subarrayWithRange:NSMakeRange(0, maxHistoryItems)]];
    }
}
@end
