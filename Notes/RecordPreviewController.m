//
//  RecordPreviewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <WYPopoverController/WYStoryboardPopoverSegue.h>
#import "RecordPreviewController.h"
#import "Record.h"
#import "History.h"
#import "HistoryController.h"
#import "VKontakteActivity.h"
#import "TextView.h"
#import "RecordTextEditorController.h"
#import "TextViewAppearancePopoverViewController.h"
#import "Photo.h"
#import "UIImage+Resize.h"
#import "CopyAllActivity.h"
#import "CopyTextOnlyActivity.h"

static NSInteger const kToolbarItemWidth = 10;

static NSString *const kSegueEditText = @"editText";
static NSString *const kSegueFindText = @"findText";
static NSString *const kSegueShowHistory = @"showHistory";
static NSString *const kSegueShowImages = @"showImages";

@implementation RecordPreviewController {
    NSValue *_selectedRangeValue;
    WYPopoverController *_wyPopoverController;
    NSArray *_photos;
    MWPhotoBrowser *_photoBrowser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.record.text == nil)
        [self editRecordText];
    [self enableKeyboardHideOnTap];
}

//Прячем клавиатуру по тапу по текстовому полю
- (void)enableKeyboardHideOnTap {
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endTitleEditing)];
    [self.textView addGestureRecognizer:tapRecognizer];
}

//Прячем клавиатуру по нажатию кнопки "Done"
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endTitleEditing];
    return YES;
}

//Вызываем коллбэк textFieldShouldEndEditing
- (void)endTitleEditing {
    [self.view endEditing:YES];
}

//После окончания редактирования заголовка сохраняемся
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self saveTitle];
    return YES;
}

- (void)saveTitle {
    self.record.title = self.titleTextField.text;
    [self.managedObjectContext save:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showRecord];
    [self showBottomToolbar:animated];
    [self scrollToSearchResult];
}


//Если мы перешли сюда из окна поиска - показываем результат поиска
- (void)scrollToSearchResult {
    if (_selectedRangeValue) {
        NSRange range = _selectedRangeValue.rangeValue;
        self.textView.selectedRange = range;
        [self.textView scrollRangeToVisible:range];
        _selectedRangeValue = nil;
    }
}

- (void)showRecord {
    [self updatePhotos];
    [self.titleTextField setText:self.record.title];
    [self.textView setText:self.record.text];
}

- (void)updatePhotos {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    _photos = [self.record.photos.allObjects sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)showBottomToolbar:(BOOL)animated {
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarSearch"] style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButtonClick:)];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    [fixedSpace setWidth:kToolbarItemWidth];
    UIBarButtonItem *history = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarTimeMachine"] style:UIBarButtonItemStylePlain target:self action:@selector(onShowHistoryButtonClick:)];
    UIBarButtonItem *separator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarShare"] style:UIBarButtonItemStylePlain target:self action:@selector(onShareButtonClick:)];
    UIBarButtonItem *changeAppearance = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarFontSize"] style:UIBarButtonItemStylePlain target:self action:@selector(onChangeTextViewAppearance:)];
    UIBarButtonItem *showImages = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarPhotos"] style:UIBarButtonItemStylePlain target:self action:@selector(onShowImages)];;
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ToolbarDelete"] style:UIBarButtonItemStylePlain target:self action:@selector(askRecordDeletion)];;
    [self setToolbarItems:@[delete, fixedSpace, history, fixedSpace, search, fixedSpace, changeAppearance, fixedSpace, showImages, separator, share]];
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)askRecordDeletion {
    UIActionSheet *actSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"actionSheetAddCancel", @"Отмена")
                                            destructiveButtonTitle:NSLocalizedString(@"actionSheetDeleteRecord", @"Удалить запись")
                                                 otherButtonTitles:nil];
    [actSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.record removeAllPhotosFromDisk];
        [self.managedObjectContext deleteObject:self.record];
        [self.managedObjectContext save:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)onShowImages {
    _photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    _photoBrowser.displayActionButton = YES;
    _photoBrowser.displayNavArrows = NO;
    _photoBrowser.displaySelectionButtons = NO;
    _photoBrowser.alwaysShowControls = NO;
    _photoBrowser.displayCommentButton = YES;
    _photoBrowser.zoomPhotosToFill = YES;
    _photoBrowser.showAddButton = YES;
    _photoBrowser.showRemoveButton = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    _photoBrowser.wantsFullScreenLayout = YES;
#endif
    _photoBrowser.enableGrid = NO;
    _photoBrowser.enableSwipeToDismiss = NO;
    [_photoBrowser setCurrentPhotoIndex:0];
    [self.navigationController pushViewController:_photoBrowser animated:YES];
}

- (void)onChangeTextViewAppearance:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"showAppearancePopover" sender:sender];
}

- (IBAction)onEditButtonClick:(UIBarButtonItem *)sender {
    [self endTitleEditing];
    [self editRecordText];
}

- (void)editRecordText {
    [self performSegueWithIdentifier:kSegueEditText sender:self];
}

- (IBAction)onSearchButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueFindText sender:self];
}

- (IBAction)onShowHistoryButtonClick:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:kSegueShowHistory sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueShowHistory]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
        [[segue destinationViewController] setRecordPreviewController:self];
    } else if ([segue.identifier isEqualToString:kSegueEditText]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:kSegueShowImages]) {
        [[segue destinationViewController] setRecord:self.record];
        [[segue destinationViewController] setManagedObjectContext:self.managedObjectContext];
    } else if ([segue.identifier isEqualToString:kSegueFindText]) {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setText:self.textView.text];
    } else if ([segue.identifier isEqualToString:@"showAppearancePopover"]) {
        WYStoryboardPopoverSegue *popoverSegue = (WYStoryboardPopoverSegue *) segue;
        TextViewAppearancePopoverViewController *destinationViewController = (TextViewAppearancePopoverViewController *) segue.destinationViewController;
        destinationViewController.textView = self.textView;
        destinationViewController.contentSizeForViewInPopover = CGSizeMake(100, 44);
        _wyPopoverController = [popoverSegue popoverControllerWithSender:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
        _wyPopoverController.delegate = self;
    }
}

- (IBAction)onShareButtonClick:(UIBarButtonItem *)sender {
    if (_record.photos == nil || _record.photos.count == 0) {
        [self shareTextOnly];
    } else
        [self shareAll];
}

- (void)shareTextOnly {
    NSString *text = self.textView.text;
    NSArray *items = @[text];
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[vkontakteActivity]];
    [self presentViewController:activity animated:YES completion:nil];
}

- (void)shareAll {
    NSString *text = self.textView.text;
    NSMutableArray *items = @[text].mutableCopy;
    for (Photo *photo in _photos) {
        UIImage *image = [UIImage imageWithContentsOfFile:photo.photoUri];
        [items addObject:image];
    }
    VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
    CopyAllActivity *copyAllActivity = [[CopyAllActivity alloc] initWithParent:self];
    CopyTextOnlyActivity *copyTextOnlyActivity = [[CopyTextOnlyActivity alloc] initWithParent:self];

    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                           applicationActivities:@[vkontakteActivity, copyAllActivity, copyTextOnlyActivity]];
    activity.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
    [self presentViewController:activity animated:YES completion:nil];
}

#pragma mark Реализация протокола SearchDelegate

- (void)onTextFoundInRange:(NSRange)range {
    //Сохраняем позицию найденного текста. Потом, в viewWillAppear мы отмотаем туда наш textView и перетащим туда курсор
    _selectedRangeValue = [NSValue valueWithRange:range];
}

#pragma mark Обработка событий просмотрщика фотографий

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos == nil ? 0 : _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    Photo *photo = _photos[index];
    MWPhoto *_photoBrowserPhoto = [[MWPhoto alloc] initWithURL:[NSURL fileURLWithPath:photo.photoUri]];
    _photoBrowserPhoto.caption = photo.comment;
    return _photoBrowserPhoto;
}

- (void)setComment:(NSString *)comment forImageWithIndex:(NSUInteger)index {
    Photo *photo = _photos[index];
    photo.comment = comment.length > 0 ? comment : nil;
    [self.managedObjectContext save:nil];
    [self updatePhotos];
    [_photoBrowser reloadData];
}

- (void)addImageFromCamera {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)addImageFromLibrary {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)removeImageWithIndex:(NSUInteger)index {
    Photo *photo = _photos[index];
    [self.record removeFromDiskPhoto:photo clearCache:YES];
    [self.record removePhotosObject:photo];
    [self.managedObjectContext save:nil];
    [self refreshPhotosInBrowser];
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

    if (imageWriteSuccess) {
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
        [self refreshPhotosInBrowser];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Не удалось сохранить изображение. Возможно закончилось свободное место"
                                                       delegate:self
                                              cancelButtonTitle:@"Закрыть"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)refreshPhotosInBrowser {
    [self updatePhotos];
    [_photoBrowser reloadDataAndShowFirst];
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


@end
