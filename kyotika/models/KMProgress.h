//
//  KMProgress.h
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/27/13.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMProgress : NSObject
- (id)initWithUserDefaults;
- (void)updateAnnotations:(NSUInteger)amount passed:(int)totalPassedCount;
- (void)save;

- (BOOL)isWaitingForNero;
- (BOOL)canStandbyNero;
- (BOOL)isTogetherWithNero;
- (BOOL)isJustComplete;
- (BOOL)isCompleted;
- (int)messageIndex;

@property (assign) float complete;
@end
