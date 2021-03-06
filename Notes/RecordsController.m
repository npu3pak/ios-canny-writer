//
//  RecordsController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordsController.h"
#import "RecordPreviewController.h"
#import "Record.h"
#import "NSDate-Utilities.h"
#import "RecordsItemCell.h"
#import "RecordsItemCellNoTitle.h"
#import "RecordTextEditorController.h"

@implementation RecordsController {
    NSIndexPath *_selectedCellIndex;
    NSString *_searchString;
    Record *_newRecord;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRecord:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Если после создания пользователь ничего в новую запись не добавил - удаляем ее за ненадобностью
    if (_newRecord != nil
            && (_newRecord.text == nil || [_newRecord.text isEqualToString:@""])
            && (_newRecord.title == nil || [_newRecord.title isEqualToString:@""])
            && _newRecord.history.count == 1
            && _newRecord.photos.count == 0) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:_newRecord];
        [self saveContext:context];
    }
    [self.tableView reloadData];
    [self refreshTableBackground];
}

- (void)refreshTableBackground {
    NSInteger sectionsCount = [self numberOfSectionsInTableView:self.tableView];
    if (sectionsCount > 0) {
        self.tableView.backgroundView = nil;
    } else {
        self.tableView.backgroundView = [[[NSBundle mainBundle] loadNibNamed:@"Views" owner:self options:nil] objectAtIndex:1];
    }
}

- (void)addRecord:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    _newRecord = [[Record alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    _newRecord.creationDate = [self getDate];
    _newRecord.changeDate = [NSDate date];
    [self saveContext:context];
    [self performSegueWithIdentifier:@"editNewRecord" sender:self];
}

- (NSDate *)getDate {
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (void)saveContext:(NSManagedObjectContext *)context {
    NSError *error = nil;
    if (![context save:&error]) {
        [self showErrorMessage:error];
    }
}

- (void)showErrorMessage:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:error.userInfo.description delegate:nil cancelButtonTitle:@"Закрыть" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateString = sectionInfo.name;
    NSDate *date = [dateFormat dateFromString:dateString];

    if (date.isToday)
        return @"Сегодня";
    else if (date.isYesterday)
        return @"Вчера";
    else if (date.isThisYear) {
        [dateFormat setDateFormat:@"cccc dd LLL"];
        return [dateFormat stringFromDate:date];
    }
    else {
        [dateFormat setDateFormat:@"dd.MM.yyyy"];
        return [dateFormat stringFromDate:date];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Record *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    BOOL hasPhotos = record.photos != nil && record.photos.count > 0;
    if (record.title == nil || [record.title isEqualToString:@""]) {
        RecordsItemCellNoTitle *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecordsCellNoTitle" forIndexPath:indexPath];
        cell.preview.attributedText = [self stringWithSelectionFromString:record.text maxLength:100];
        cell.statusImage.hidden = !hasPhotos;
        return cell;
    } else {
        RecordsItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"RecordsCell" forIndexPath:indexPath];
        cell.title.attributedText = [self stringWithSelectionFromString:record.title maxLength:30];
        cell.preview.attributedText = [self stringWithSelectionFromString:record.text maxLength:100];
        cell.statusImage.hidden = !hasPhotos;
        return cell;
    }
}

- (NSAttributedString *)stringWithSelectionFromString:(NSString *)string maxLength:(NSUInteger)maxLength {
    if (string == nil)
        return nil;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    if (_searchString == nil) {
        [attributedString removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, attributedString.length)];
        return attributedString;
    }
    NSRange selectionRange = [string rangeOfString:_searchString options:NSCaseInsensitiveSearch];
    if (selectionRange.location == NSNotFound)
        return attributedString;
    [attributedString addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:selectionRange];
    NSUInteger rangeStart = MAX(0, (NSInteger) selectionRange.location - (NSInteger) (maxLength / 2) + (NSInteger) (_searchString.length / 2));
    NSUInteger rangeLength = MIN(string.length - rangeStart, rangeStart + maxLength);
    return [attributedString attributedSubstringFromRange:NSMakeRange(rangeStart, rangeLength)];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        Record *record = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [record removeAllPhotosFromDisk];
        [context deleteObject:record];
        [self saveContext:context];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _selectedCellIndex = indexPath;
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        Record *record = [[self fetchedResultsController] objectAtIndexPath:_selectedCellIndex];
        [[segue destinationViewController] setRecord:record];
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
    if ([[segue identifier] isEqualToString:@"editNewRecord"]) {
        RecordPreviewController *previewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RecordPreviewController"];
        previewController.managedObjectContext = self.managedObjectContext;
        previewController.record = _newRecord;
        [[segue destinationViewController] setRecordPreviewController:previewController];

        [[segue destinationViewController] setRecordsNavigationController:self.navigationController];
        [[segue destinationViewController] setRecord:_newRecord];
        [[segue destinationViewController] setIsNewRecord:YES];
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchString {
    [self filterTableView:searchString];

}

- (void)filterTableView:(NSString *)searchString {
    _searchString = searchString;
    NSPredicate *predicate = nil;
    if (searchString != nil && ![searchString isEqualToString:@""])
        predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@ OR text contains[cd] %@", searchString, searchString];
    [self.fetchedResultsController.fetchRequest setPredicate:predicate];

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
    [self refreshTableBackground];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
    [_searchBar setShowsCancelButton:NO animated:YES];
    _searchBar.text = nil;
    _searchString = nil;
    [self.fetchedResultsController.fetchRequest setPredicate:nil];
    [[self fetchedResultsController] performFetch:nil];
    [self.tableView reloadData];
    [self refreshTableBackground];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [_searchBar setShowsCancelButton:YES animated:YES];
    if (_searchBar.text != nil)
        [self filterTableView:_searchBar.text];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Record" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptorCreationDate = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    NSSortDescriptor *sortDescriptorChangeDate = [[NSSortDescriptor alloc] initWithKey:@"changeDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorCreationDate, sortDescriptorChangeDate];
    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:self.managedObjectContext
                                                                                                  sectionNameKeyPath:@"creationDate"
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        [self showErrorMessage:error];
    }

    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadData];
            [self refreshTableBackground];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    [self refreshTableBackground];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}


@end
