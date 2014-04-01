//
//  RecordDetailViewController.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Record;

@interface RecordDetailViewController : UIViewController

@property (strong, nonatomic) Record* record;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
