//
//  HistoryViewController.m
//  Notes
//
//  Created by Евгений Сафронов on 03.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "HistoryViewController.h"
#import "Record.h"
#import "HistoryPageContentViewController.h"
#import "History.h"
#import "RecordDetailViewController.h"

@implementation HistoryViewController {
    NSArray *_historyArray;
    NSUInteger _currentIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"changeDate" ascending:NO];
    _historyArray = [_record.history.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];

    HistoryPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    if (startingViewController == nil) {
        _emptyHistoryLabel.hidden = NO;
        return;
    }

    _emptyHistoryLabel.hidden = YES;

    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}


- (HistoryPageContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (_historyArray == nil || _historyArray.count == 0)
        return nil;
    HistoryPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HistoryPageContentViewController"];
    pageContentViewController.historyItem = [_historyArray objectAtIndex:index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        _currentIndex = [((HistoryPageContentViewController *)[self.pageViewController.viewControllers lastObject]) pageIndex];
    }
}

#pragma mark - Page View Controller Data Source


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((HistoryPageContentViewController *) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((HistoryPageContentViewController *) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;

    if (index == [_historyArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [_historyArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (IBAction)onRestoreButtonClick:(UIBarButtonItem *)sender {
    History *currentHistoryState = [_historyArray objectAtIndex:_currentIndex];
    currentHistoryState.changeDate = [NSDate date];
    _recordDetailViewController.record.text = currentHistoryState.text;
    _record.text = currentHistoryState.text;
    _record.changeDate = currentHistoryState.changeDate;
    [_managedObjectContext save:nil];
    [_recordDetailViewController refreshView];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
