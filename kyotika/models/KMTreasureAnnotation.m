//
//  KMTreasureAnnotationView.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMTreasureAnnotation.h"

@implementation KMTreasureAnnotation
- (NSString*)question
{
    return @"質問";
}
- (NSArray*)answers
{
    return [NSArray arrayWithObjects:@"A1", @"A2", @"A3", nil];
}

- (int)correctAnswerIndex
{
    return 1;
}

@end
