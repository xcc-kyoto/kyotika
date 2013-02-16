//
//  KMTreasureAnnotationView.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMTreasureAnnotation.h"
#import "Landmark.h"

const NSTimeInterval KMTreasureAnnotationPenaltyDuration = 120;

@implementation KMTreasureAnnotation

@synthesize landmark = _landmark;

- (void)setPassed:(BOOL)passed
{
    _landmark.passed = [NSNumber numberWithBool:passed];
}
- (BOOL)passed
{
    return [_landmark.passed boolValue];
}

- (void)setFind:(BOOL)find
{
    _landmark.found = [NSNumber numberWithBool:find];
}
- (BOOL)find
{
    return [_landmark.found boolValue];
}

- (NSArray *)keywords
{
    return [_landmark.tags allObjects];
}

- (NSString*)question
{
    return _landmark.question;
}

- (NSArray*)answers
{
    return @[_landmark.answer1, _landmark.answer2, _landmark.answer3];
}

- (int)correctAnswerIndex
{
    return [_landmark.correct intValue] - 1;
}

- (BOOL)locking
{
    if (self.passed == NO) {
        if (self.lastAtackDate && [[NSDate date] timeIntervalSinceDate:self.lastAtackDate] < KMTreasureAnnotationPenaltyDuration) {  //  前回のトライから時間が経過していない
            return YES;
        }
    }
    return NO;
}
- (void)notificationHitIfNeed
{
    if (self.find == NO)
        return;
    if (self.locking) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KMTreasureAnnotationHitNotification" object:self userInfo:@{@"annotation" : self}];
}

@end
