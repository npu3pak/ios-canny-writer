//
//  ImagesController.m
//  CannyWriter
//
//  Created by Евгений Сафронов on 18.05.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "ImagesController.h"
#import "Record.h"
#import "PhotosCollectionCell.h"
#import "Photo.h"
#import "UIImage+Resize.h"
#import "ImageController.h"

@implementation ImagesController {
    NSMutableArray *_photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showPhotos];
}

- (void)showPhotos {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSArray *photos = [_record.photos.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
    _photos = [NSMutableArray arrayWithArray:photos];
    [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotosCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photosCell" forIndexPath:indexPath];
    [cell showPhoto:_photos[indexPath.row]];
    return cell;
}


- (IBAction)onAddClick:(id)sender {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"actionSheetAddTitle", @"Прикрепить изображение")
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actionSheetAddCancel", @"Отмена")
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"actionSheetAddFromCamera", @"Из камеры"),
                                                                   NSLocalizedString(@"actionSheetAddFromLibrary", @"Из библиотеки"), nil];
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0)
        [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
    else if (buttonIndex == 1)
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
    UIImage *thumbnail = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(155, 155) interpolationQuality:kCGInterpolationDefault];


    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    Photo *photo = [[Photo alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];

    photo.creationDate = [NSDate date];
    photo.photo = UIImageJPEGRepresentation(image, 1.0);
    photo.thumbnail = UIImageJPEGRepresentation(thumbnail, 1.0);

    [self.record addPhotosObject:photo];
    [self.managedObjectContext save:nil];//TODO Если кончилось место - тут будет ошибка. Надо ловить
    [self dismissViewControllerAnimated:YES completion:nil];
    [self showPhotos];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImage"]) {
        NSIndexPath *selectedPath = self.collectionView.indexPathsForSelectedItems[0];
        Photo *selected = _photos[selectedPath.row];
        ImageController *photoController = segue.destinationViewController;
        [photoController setPhoto:selected];
    }
}

@end
