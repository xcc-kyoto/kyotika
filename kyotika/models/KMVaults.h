//
//  KMVaults.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Tag.h"

@class KMTreasureAnnotation;

@interface KMVaults : NSObject
- (NSSet*)treasureAnnotationsInRegion:(NSManagedObjectContext *)moc :(MKCoordinateRegion)region;
- (NSArray*)landmarksForKey:(NSManagedObjectContext *)moc :(Tag *)tag;
- (NSArray*)keywords:(NSManagedObjectContext *)moc;
- (NSArray*)landmarks:(NSManagedObjectContext *)moc;
- (void)setPassedAnnotation:(NSManagedObjectContext *)moc
                           :(KMTreasureAnnotation*)annotation;
- (void)save:(NSManagedObjectContext *)moc;
@property (assign) float complite;
@end
