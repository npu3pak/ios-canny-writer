//
//  RecordSearchController.h
//  CannyWriter
//
//  Created by Евгений Сафронов on 12.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextView;

@protocol SearchDelegate

- (void)onTextFoundInRange:(NSRange)range;

@end


@interface RecordSearchController : UIViewController <UISearchBarDelegate>

@property IBOutlet UISearchBar *searchBar;
@property IBOutlet TextView *textView;
@property IBOutlet NSLayoutConstraint *toolbarHeight;
@property IBOutlet NSLayoutConstraint *textPaddingBottom;

@property id <SearchDelegate> delegate;
@property NSString *text;

@end
