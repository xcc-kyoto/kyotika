//
//  KMVaults.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Tag.h"

@class KMTreasureAnnotation;

@interface KMVaults : NSObject
- (id)initWithContext:(NSManagedObjectContext *)moc;

/**
    エリア用KMAreaAnnotationの作成
 in region  この領域用のKMAreaAnnotationを作成
 */
- (void)makeArea:(MKCoordinateRegion)region;

/**
    指定された領域のKMTreasureAnnotationのセットを返す。
 
 in region  領域指定
 in hunter  パトラッシュの位置
 in power   ランドマークと近接した時に発見とみなすが、その近接しきい値（m）の倍率 0.0意外を指定するとデフォルトにpowerがかけられた値でチェックされる。
 
 out
 */
- (NSSet*)treasureAnnotationsInRegion:(MKCoordinateRegion)region hunter:(CLLocationCoordinate2D)hunter power:(float)power;

- (NSArray*)landmarksForKey:(Tag *)tag;
- (NSArray*)keywords;
- (NSArray*)landmarks;
- (void)setPassedAnnotation:(KMTreasureAnnotation*)annotation;
- (void)save;
@property (assign) float complite;
@end
