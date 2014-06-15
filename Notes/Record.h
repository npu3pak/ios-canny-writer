//
//  Record.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Record : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * changeDate;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *history;
@property (nonatomic, retain) NSSet *photos;

- (void)removeOldHistoryItems;

- (void)removeFromDiskPhoto:(Photo *)photo clearCache:(BOOL)clearCache;

- (void)removeAllPhotosFromDisk;

@end

@interface Record (CoreDataGeneratedAccessors)

- (void)addHistoryObject:(NSManagedObject *)value;
- (void)removeHistoryObject:(NSManagedObject *)value;
- (void)addHistory:(NSSet *)values;
- (void)removeHistory:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
