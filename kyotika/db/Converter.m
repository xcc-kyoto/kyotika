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
        NSUInteger landmarkNo = [[items objectAtIndex:1] unsignedIntValue] - 1;
        NSUInteger TagNo = [[items objectAtIndex:2] unsignedIntValue] - 1;
        Landmark *l = [landmarks objectAtIndex:landmarkNo];
        Tag *t = [tags objectAtIndex:TagNo];
        [l addTagsObject:t];
        if (![moc save:nil]) {
            // FIXME
        }
    }
}

+ (void)createSeeds:(NSManagedObjectContext *)moc
{
    [Landmark deleteAll:moc];
    NSMutableArray *sortedLandmarks = [self insertNewLandmarks:moc];
    NSMutableArray *sortedTags = [self insertNewTags:moc];
    [self bindEntities:moc Landmarks:sortedLandmarks Tag:sortedTags];
    
    // FIXME
    MKCoordinateRegion r;
    r.center.latitude = 34.9875;
    r.center.longitude = 135.759;
    r.span.latitudeDelta = 0;
    r.span.longitudeDelta = 0;
    for (Landmark *l in [Landmark locations:moc inRegion:r]) {
        NSLog(@"%@ %@ %@", l.name, l.latitude, l.hiragana);
        for (Tag *t in l.tags) {
            NSLog(@"- %@", t.name);
        }
    }
}

@end
