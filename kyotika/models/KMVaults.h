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
#import "KMProgress.h"

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
 
 @in region  領域指定
 @in hunter  パトラッシュの位置
 @in hitTreasureAnnotation  パトラッシュと交差したとみなすKMTreasureAnnotation（1つ）
 
 @return    指定された領域のKMTreasureAnnotationのセット
 */
- (NSSet*)treasureAnnotationsInRegion:(MKCoordinateRegion)region hunter:(CLLocationCoordinate2D)hunter hitTreasureAnnotation:(KMTreasureAnnotation**)hitTreasureAnnotation;

/**
 指定された中心から、指定された半径の円範囲のランドマークのfindをYESにする。
 @in center  中心 緯度経度
 @in radiusMeter 半径 m
 */
- (void)search:(CLLocationCoordinate2D)center radiusMeter:(CLLocationDistance)radiusMeter;

- (int)totalLandmarkCount;

- (NSArray*)landmarksForKey:(Tag *)tag;
- (NSArray*)keywords;
- (NSArray*)landmarks;
- (void)setPassedAnnotation:(KMTreasureAnnotation*)annotation;
- (void)save;
+ (int)gropuIndexForRegion:(MKCoordinateRegion)region;

@property (strong, nonatomic) KMProgress *progress;
@property (readonly) int totalPassedCount;
@end


typedef struct {
    CLLocationDegrees  minlatitude;
    CLLocationDegrees  maxlatitude;
    CLLocationDegrees  minlongitude;
    CLLocationDegrees  maxlongitude;
} KMRegion;

KMRegion KMRegionFromMKCoordinateRegion(MKCoordinateRegion region);
BOOL MKCoordinateInKMRegion(CLLocationCoordinate2D coordinate, KMRegion region);
