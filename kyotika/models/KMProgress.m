//
//  KMProgress.m
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/27/13.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMProgress.h"

@implementation KMProgress

- (id)initWithUserDefaults
{
    _complete = [[NSUserDefaults standardUserDefaults] floatForKey:@"complete"];
    return self;
}

- (void)updateAnnotations:(NSUInteger)amount passed:(int)totalPassedCount
{
    if (_complete < 1.0) {
        float progress = (float)totalPassedCount / (float)amount * 4;
        int times = progress / 0.2 + 1;
        float value = 0.2 * times;
        if (value >= _complete) {
            _complete = value;
        }
    } else if ((_complete < 2.0) && (_complete >= 1.0)) {
        if (totalPassedCount == amount) {
            _complete = 2.0;
        }
    }
}

- (void)save
{
    [[NSUserDefaults standardUserDefaults] setFloat:_complete forKey:@"complete"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isWaitingForNero
{
    return (_complete < 0.4f);
}

- (BOOL)canStandbyNero
{
    return (_complete == 1.0f);
}

- (BOOL)isTogetherWithNero
{
    return (_complete >= 1.0f);
}

- (BOOL)isJustComplete
{
    return (_complete == 2.0f);
}

- (BOOL)isCompleted
{
    return (_complete >= 2.0f);
}

- (int)messageIndex
{
    int index = (int)(_complete * 10.0) / 2 - 1;
    if (index < 0) index = 0;
    if (index >= 5) index = 4;
    return index;
}

@end
