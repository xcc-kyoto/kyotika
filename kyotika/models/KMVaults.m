//
//  KMVaults.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMVaults.h"
#import "KMTreasureAnnotation.h"
#import "Landmark.h"

@implementation KMVaults

- (NSSet *)landmarks:(NSManagedObjectContext *)moc
                    :(NSArray *)array
{
    NSMutableSet* set = [NSMutableSet set];
    for (Landmark *l in array) {
        l.found = [NSNumber numberWithBool:YES];
        KMTreasureAnnotation *a = [[KMTreasureAnnotation alloc] init];
        a.landmark = l;
        a.title = l.name;
        a.coordinate = CLLocationCoordinate2DMake([l.latitude doubleValue],
                                                  [l.longitude doubleValue]);
        [set addObject:a];
    }
    return set;
}

// 変更点
// - 引数に NSManagedObjectContext を追加
// 使い方
//    MKCoordinateRegion region;
//    region.center.latitude = 34.9875;
//    region.center.longitude = 135.759;
//    region.span.latitudeDelta = 0;
//    region.span.longitudeDelta = 0;
- (NSSet*)treasureAnnotationsInRegion:(NSManagedObjectContext *)moc
                                     :(MKCoordinateRegion)region
{
    return [self landmarks:moc :[Landmark locations:moc inRegion:region]];
}

- (NSArray*)landmarksForKey:(NSManagedObjectContext *)moc :(Tag *)tag
{
    return [[self landmarks:moc :[tag.landmarks allObjects]] allObjects];
}

- (NSArray*)keywords:(NSManagedObjectContext *)moc
{
    return [Landmark tagsPassed:moc];
}

- (NSArray*)landmarks:(NSManagedObjectContext *)moc
{
    return [[self landmarks:moc :[Landmark allFound:moc]] allObjects];
}

- (void)setPassedAnnotation:(NSManagedObjectContext *)moc
                           :(KMTreasureAnnotation*)annotation
{
    annotation.passed = YES;
}

- (void)save:(NSManagedObjectContext *)moc
{
    if (![moc save:nil]) {
        // FIXME
    }
}

@end

//  MKMetersBetweenMapPoints