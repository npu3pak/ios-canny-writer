//
//  HistoryPageContentController.h
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class History;

@interface HistoryPageContentController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *timeStampText;
@property NSUInteger pageIndex;
@property History *historyItem;

@end
