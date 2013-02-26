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
@dynamic hiragana;
@dynamic tags;

+ (NSEntityDescription *)entityDescription:(NSManagedObjectContext *)moc
{
    return [NSEntityDescription entityForName:@"Landmark" inManagedObjectContext:moc];
}

+ (NSArray *)fetch:(NSManagedObjectContext *)moc predicate:(NSPredicate *)predicate
{
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:[self entityDescription:moc]];
    if (predicate)
        [req setPredicate:predicate];
    NSSortDescriptor *hiragana = [[NSSortDescriptor alloc] initWithKey:@"hiragana" ascending:YES];
    [req setSortDescriptors:[NSArray arrayWithObject:hiragana]];
    NSError *err = nil;
    NSArray *results = [moc executeFetchRequest:req error:&err];
    if (err == nil) {
        // FIXME
    }
    return results;
}

+ (NSPredicate *)found
{
    return [NSPredicate predicateWithFormat:@"found = YES"];
}

+ (NSArray *)allFound:(NSManagedObjectContext *)moc
{
    return [self fetch:moc predicate:nil];
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
    NSArray* array = [[NSSet setWithArray:result] allObjects]; // 重複を省く
    NSSortDescriptor *name = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    return [array sortedArrayUsingDescriptors:@[name]];
}

@end
