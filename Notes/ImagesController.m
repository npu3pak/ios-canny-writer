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
#import "Photo.h"

@implementation ImagesController {
    NSArray *_photosArray;
    NSUInteger _currentIndex;
}

- (void)viewWillAppear:(BOOL)animated {
    [self showBottomToolbar:animated];
}


- (void)showBottomToolbar:(BOOL)animated {
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItem)];;
    [self setToolbarItems:@[delete]];

    BOOL hasImages = _photosArray != nil && _photosArray.count > 0;
    [self.navigationController setToolbarHidden:!hasImages animated:animated];
}

- (void)deleteItem {
    Photo *photo = _photosArray[_currentIndex];
    if (photo) {
        [_record removePhotosObject:photo];
        [self.managedObjectContext save:nil];
        [self showPhotos];
        [self showBottomToolbar:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagesPageViewController"];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;

    [self showPhotos];

}

- (void)showPhotos {

    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];


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

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
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
    [self pickPhotoFromLibrary];
}

- (void)pickPhotoFromLibrary {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    Photo *photo = [[Photo alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

    photo.creationDate = [NSDate date];
    photo.photo = UIImagePNGRepresentation(image);

    [self.record addPhotosObject:photo];
    [self.managedObjectContext save:nil];//TODO Если кончилось место - тут будет ошибка. Надо ловить
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showPhotos];
    [self showBottomToolbar:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
