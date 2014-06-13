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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:self.generateImageFileName];
    NSString *thumbnailPath = [documentsPath stringByAppendingPathComponent:self.generateThumbnailFileName];

    NSData *photoData = UIImageJPEGRepresentation(image, 1.0);
    BOOL imageWriteSuccess = [photoData writeToFile:filePath atomically:YES];
    BOOL thumbnailWriteSuccess = NO;

    if(imageWriteSuccess){
        NSData *thumbnailData = UIImageJPEGRepresentation(thumbnail, 1.0);
        thumbnailWriteSuccess = [thumbnailData writeToFile:thumbnailPath atomically:YES];
    }

    if (thumbnailWriteSuccess) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        Photo *photo = [[Photo alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
        photo.creationDate = [NSDate date];
        photo.thumbnailUri = thumbnailPath;
        photo.photoUri = filePath;

        [self.record addPhotosObject:photo];
        [self.managedObjectContext save:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self showPhotos];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Не удалось сохранить изображение. Возможно закончилось свободное место"
                                                       delegate:self
                                              cancelButtonTitle:@"Закрыть"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (NSString *)generateImageFileName {
    double millis = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%f.jpg", millis];
}

- (NSString *)generateThumbnailFileName {
    double millis = [NSDate date].timeIntervalSince1970;
    return [NSString stringWithFormat:@"%f-thumb.jpg", millis];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showImage"]) {
        NSIndexPath *selectedPath = self.collectionView.indexPathsForSelectedItems[0];
        Photo *selected = _photos[selectedPath.row];
        ImageController *photoController = segue.destinationViewController;
        photoController.photo = selected;
        photoController.record = self.record;
        photoController.managedObjectContext = self.managedObjectContext;
    }
}

@end
