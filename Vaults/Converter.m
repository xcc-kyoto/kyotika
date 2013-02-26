//
//  Converter.m
//  Vaults
//
//  Created by Yasuhiro Usutani on 2/1/13.
//  Copyright (c) 2013 Yasuhiro Usutani. All rights reserved.
//

#import "Converter.h"
#import "Landmark.h"
#import "Tag.h"

@implementation Converter

+ (NSArray *)linesWithFile:(NSString *)filename
{
    NSBundle *mb = [NSBundle mainBundle];
    NSString *path = [mb pathForResource:filename ofType:@"tab" inDirectory:nil];
    NSString *raw = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    return [raw componentsSeparatedByString:@"\n"];
}

+ (NSMutableArray *)insertNewLandmarks:(NSManagedObjectContext *)moc
{
    NSArray *lines  = [self linesWithFile:@"landmarks"];
    NSMutableArray *sortedObjs = [NSMutableArray arrayWithCapacity:[lines count]];
    for (NSString *line in lines) {
        NSArray *items = [line componentsSeparatedByString:@"\t"];
        int i = [[items objectAtIndex:0] intValue];
        if (i == 0) {
            continue;
        }
        Landmark *l = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Landmark"
                       inManagedObjectContext:moc];
        l.name = [items objectAtIndex:1];
        l.latitude = [NSNumber numberWithDouble:[[items objectAtIndex:2] doubleValue]];
        l.longitude = [NSNumber numberWithDouble:[[items objectAtIndex:3] doubleValue]];
        l.url = [items objectAtIndex:4];
        l.question = [items objectAtIndex:5];
        l.answer1= [items objectAtIndex:6];
        l.answer2= [items objectAtIndex:7];
        l.answer3= [items objectAtIndex:8];
        l.correct= [NSNumber numberWithDouble:[[items objectAtIndex:9] intValue]];
        l.hiragana = [items objectAtIndex:13];
        if (![moc save:nil]) {
            // FIXME
        }
        [sortedObjs addObject:l];
    }
    return sortedObjs;
}

+ (NSMutableArray *)insertNewTags:(NSManagedObjectContext *)moc
{
    NSArray *lines  = [self linesWithFile:@"tags"];
    NSMutableArray *sortedObjs = [NSMutableArray arrayWithCapacity:[lines count]];
    for (NSString *line in lines) {
        NSArray *items = [line componentsSeparatedByString:@"\t"];
        int i = [[items objectAtIndex:0] intValue];
        if (i == 0) {
            continue;
        }
        Tag *t = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Tag"
                  inManagedObjectContext:moc];
        t.name = [items objectAtIndex:1];
        if (![moc save:nil]) {
            // FIXME
        }
        [sortedObjs addObject:t];
    }
    return sortedObjs;
}

+ (void)bindEntities:(NSManagedObjectContext *)moc
           Landmarks:(NSArray *)landmarks Tag:(NSArray *)tags
{
    NSArray *lines  = [self linesWithFile:@"taggings"];
    for (NSString *line in lines) {
        NSArray *items = [line componentsSeparatedByString:@"\t"];
        int i = [[items objectAtIndex:0] intValue];
        if (i == 0) {
            continue;
        }
#if __IPHONE_OS_VERSION_MIN_REQUIRED
        NSUInteger landmarkNo = [[items objectAtIndex:1] unsignedIntValue] - 1;
        NSUInteger tagNo = [[items objectAtIndex:2] unsignedIntValue] - 1;
#else
        NSUInteger landmarkNo = [[items objectAtIndex:1] intValue] - 1;
        NSUInteger tagNo = [[items objectAtIndex:2] intValue] - 1;
#endif
        Landmark *l = [landmarks objectAtIndex:landmarkNo];
        Tag *t = [tags objectAtIndex:tagNo];
        [l addTagsObject:t];
        if (![moc save:nil]) {
            // FIXME
        }
    }
}

//
// sqlite> select Z_PK, ZNAME from ZLANDMARK;
//
+ (void)createSeeds:(NSManagedObjectContext *)moc
{
    NSMutableArray *sortedLandmarks = [self insertNewLandmarks:moc];
    NSMutableArray *sortedTags = [self insertNewTags:moc];
    [self bindEntities:moc Landmarks:sortedLandmarks Tag:sortedTags];
}

+ (NSPredicate *)inRegion:(MKCoordinateRegion)region
{
    double minlatitude = region.center.latitude - region.span.latitudeDelta;
    double maxlatitude = region.center.latitude + region.span.latitudeDelta;
    double minlongitude = region.center.longitude - region.span.longitudeDelta;
    double maxlongitude = region.center.longitude + region.span.longitudeDelta;
    
    return [NSPredicate predicateWithFormat:@"%lf <= latitude AND latitude <= %lf AND %lf <= longitude AND longitude <= %lf", minlatitude, maxlatitude, minlongitude, maxlongitude];
}

+ (NSArray *)locations:(NSManagedObjectContext *)moc
              inRegion:(MKCoordinateRegion)region
{
    return [Landmark fetch:moc predicate:[self inRegion:region]];
}

+ (void)displayInRegion:(NSManagedObjectContext *)moc
{
    MKCoordinateRegion r;
    r.center.latitude = 34.9875;
    r.center.longitude = 135.759;
    r.span.latitudeDelta = 0;
    r.span.longitudeDelta = 0;
    for (Landmark *l in [self locations:moc inRegion:r]) {
        NSLog(@"%@ %@ %@", l.name, l.latitude, l.hiragana);
        for (Tag *t in l.tags) {
            NSLog(@"- %@", t.name);
        }
    }
}

@end
