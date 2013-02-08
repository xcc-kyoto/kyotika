//
//  KMTreasureAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@class Landmark;

@interface KMTreasureAnnotation : MKPointAnnotation
/// ヒット通知が必要ならば通知する
- (void)notificationHitIfNeed;

@property (strong, nonatomic) Landmark *landmark;
@property BOOL passed;
@property BOOL find;
@property (readonly) NSArray* keywords;
@property (readonly) NSString* question;
@property (readonly) NSArray* answers;
@property (readonly) int correctAnswerIndex;

@property BOOL target;
@property (retain) NSDate* lastAtackDate;
@end
