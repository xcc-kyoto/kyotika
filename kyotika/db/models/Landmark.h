//
//  Landmark.h
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/6/13.
//  Copyright (c) 2013 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@class Tag;

@interface Landmark : NSManagedObject

@property (nonatomic, retain) NSString * answer1;
@property (nonatomic, retain) NSString * answer2;
@property (nonatomic, retain) NSString * answer3;
@property (nonatomic, retain) NSNumber * correct;
@property (nonatomic, retain) NSNumber * found;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * passed;
@property (nonatomic, retain) NSString * question;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Landmark (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

+ (void)deleteAll:(NSManagedObjectContext *)moc;

+ (NSArray *)locations:(NSManagedObjectContext *)moc
              inRegion:(MKCoordinateRegion)region;
+ (NSArray *)all:(NSManagedObjectContext *)moc;
+ (NSArray *)allFound:(NSManagedObjectContext *)moc;
+ (NSArray *)tagsPassed:(NSManagedObjectContext *)moc;

@end
