//
//  Photo.h
//  Notes
//
//  Created by Евгений Сафронов on 01.04.14.
//  Copyright (c) 2014 Евгений Сафронов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Record;
@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSData * photo;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) Record *record;

@end
