//
//  Landmark.m
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/6/13.
//  Copyright (c) 2013 國居貴浩. All rights reserved.
//

#import "Landmark.h"
#import "Tag.h"


@implementation Landmark

@dynamic answer1;
@dynamic answer2;
@dynamic answer3;
@dynamic correct;
@dynamic found;
@dynamic latitude;
@dynamic longitude;
@dynamic name;
@dynamic passed;
@dynamic question;
@dynamic url;
@dynamic tags;

+ (NSEntityDescription *)entityDescription:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription entityForName:@"Landmark" inManagedObjectContext:moc];
}

+ (void)deleteAll:(NSManagedObjectContext *)moc
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:[self entityDescription:moc]];
    [req setIncludesPropertyValues:NO];
    NSError *err = nil;
    NSArray *objs = [moc executeFetchRequest:req error:&err];
    for (NSManagedObject *obj in objs) {
        [moc deleteObject:obj];
    }
    [moc save:&err];
}

+ (NSPredicate *)inRegion:(MKCoordinateRegion)region
{
    double minlatitude = region.center.latitude - region.span.latitudeDelta;
    double maxlatitude = region.center.latitude + region.span.latitudeDelta;
    double minlongitude = region.center.longitude - region.span.longitudeDelta;
    double maxlongitude = region.center.longitude + region.span.longitudeDelta;
    
    return [NSPredicate predicateWithFormat:@"%lf <= latitude AND latitude <= %lf AND %lf <= longitude AND longitude <= %lf", minlatitude, maxlatitude, minlongitude, maxlongitude];
}

+ (NSArray *)fetch:(NSManagedObjectContext *)moc predicate:(NSPredicate *)predicate
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:[self entityDescription:moc]];
    [req setPredicate:predicate];
    NSError *err = nil;
    NSArray *results = [moc executeFetchRequest:req error:&err];
    if (err == nil) {
        // FIXME
    }
    return results;
}

+ (NSArray *)locations:(NSManagedObjectContext *)moc
              inRegion:(MKCoordinateRegion)region
{
    return [self fetch:moc predicate:[self inRegion:region]];
}

+ (NSArray *)all:(NSManagedObjectContext *)moc
{
    return [self fetch:moc predicate:nil];
}

+ (NSPredicate *)found
{
    return [NSPredicate predicateWithFormat:@"found = YES"];
}

+ (NSArray *)allFound:(NSManagedObjectContext *)moc
{
    return [self fetch:moc predicate:[self found]];
}

+ (NSPredicate *)passed
{
    return [NSPredicate predicateWithFormat:@"passed = YES"];
}

+ (NSArray *)allPassed:(NSManagedObjectContext *)moc
{
    return [self fetch:moc predicate:[self passed]];
}

+ (NSArray *)tagsPassed:(NSManagedObjectContext *)moc
{
    NSMutableArray *result = [NSMutableArray array];
    for (Landmark *l in [self allPassed:moc]) {
        [result addObjectsFromArray:[l.tags allObjects]];
    }
    return [[NSSet setWithArray:result] allObjects];
}

@end
