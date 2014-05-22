//
//  ImagesController.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImagesController.h"
#import "Record.h"
#import "ImagesPageContentController.h"


@implementation ImagesController {
    NSArray *_photosArray;
    NSUInteger _currentIndex;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setToolbarHidden:YES animated:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagesPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    [self showPhotos];

}

- (void)showPhotos {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    _photosArray = [_record.photos.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];

    ImagesPageContentController *startingViewController = [self viewControllerAtIndex:0];
    if (startingViewController == nil) {
        _emptyImagesLabel.hidden = NO;
        return;
    }

    _emptyImagesLabel.hidden = YES;

    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (ImagesPageContentController *)viewControllerAtIndex:(NSUInteger)index {
    if (_photosArray == nil || _photosArray.count == 0)
        return nil;
    ImagesPageContentController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagesPageContentViewController"];
    pageContentViewController.photo = [_photosArray objectAtIndex:index];
    pageContentViewController.pageIndex = index;
    return pageContentViewController;
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        _currentIndex = [((ImagesPageContentController *) [self.pageViewController.viewControllers lastObject]) pageIndex];
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((ImagesPageContentController *) viewController).pageIndex;

    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = ((ImagesPageContentController *) viewController).pageIndex;

    if (index == NSNotFound) {
        return nil;
    }

    index++;

    if (index == [_photosArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [_photosArray count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (IBAction)onAddButtonClick:(UIBarButtonItem *)sender {

}

@end
