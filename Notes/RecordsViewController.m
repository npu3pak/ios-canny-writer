//
//  RecordsViewController.m
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import "RecordsViewController.h"
#import "RecordDetailViewController.h"
#import "Record.h"
#import "NSDate-Utilities.h"
#import "RecordsItemCell.h"
#import "RecordsItemCellNoTitle.h"

@implementation RecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRecord:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)addRecord:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    Record *newRecord = [[Record alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    //    newRecord.title = @"Test";
    newRecord.text = @"Я думаю об утре Вашей славы,\nОб утре Ваших дней,\nКогда очнулись демоном от сна Вы\nИ богом для людей.\nЯ думаю о том, как Ваши брови\nСошлись над факелами Ваших глаз,\nО том, как лава древней крови\nПо Вашим жилам разлилась.";
    newRecord.creationDate = [self getDate];
    newRecord.changeDate = [NSDate date];
    [self saveContext:context];
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
//    Дату пишет не по-нашему
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
        RecordsItemCellNoTitle *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordsCellNoTitle" forIndexPath:indexPath];
        cell.preview.text = record.text;
        cell.statusImage.hidden = !hasPhotos;
        return cell;
    } else {
        RecordsItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordsCell" forIndexPath:indexPath];
        cell.title.text = record.title;
        cell.preview.text = record.text;
        cell.statusImage.hidden = !hasPhotos;
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        [self saveContext:context];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Record *record = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setRecord:record];
        [[segue destinationViewController] setManagedObjectContext:_managedObjectContext];
    }
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
                                                                                                           cacheName:@"Master"];
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
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
