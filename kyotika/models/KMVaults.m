//
//  KMVaults.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMVaults.h"
#import "KMTreasureAnnotation.h"
#import "KMAreaAnnotation.h"
#import "Landmark.h"

static const CLLocationDegrees groupThresholdDegree = 0.02;             ///  KMTreasureAnnotationではなく、KMAreaAnnotationを返すしきい値
static const CLLocationDistance nearThresholdMeter = 100.0;             ///  基本の近接範囲 m
static const CLLocationDistance hitThresholdMeter = 30.0;               ///  接触とみなす範囲 m
static const CLLocationDistance KMVaultsAreaThresholdSpan = 2000;

@implementation KMVaults {
    __weak NSManagedObjectContext* _moc;
    NSMutableArray* _treasureAnnotations;
    NSDictionary*  _groupAnnotations[3];
}

@synthesize progress = _progress;

- (id)initWithContext:(NSManagedObjectContext *)moc
{
    self = [super init];
    if (self) {
        _moc = moc;
        
        //  今回は、いったん全部KMTreasureAnnotation化し_treasureAnnotationsに蓄える。千件以上ならキャッシュ機能をつけるべき。
        NSArray* array = [Landmark allFound:_moc];
        _treasureAnnotations = [NSMutableArray arrayWithCapacity:[array count]];
        _totalPassedCount = 0;
        for (Landmark *l in array) {
            KMTreasureAnnotation *a = [[KMTreasureAnnotation alloc] init];
            if ([l.passed boolValue])
                _totalPassedCount++;
            a.landmark = l;
            a.title = l.name;
            a.coordinate = CLLocationCoordinate2DMake([l.latitude doubleValue],
                                                      [l.longitude doubleValue]);
            [_treasureAnnotations addObject:a];
        }
        //  横20 x 縦20の区画でランドマークをまとめてグループ注釈として返す

        _progress = [[KMProgress alloc] initWithUserDefaults];
    }
    return self;
}

- (void)makeArea:(MKCoordinateRegion)region
{
    _groupAnnotations[0] = [self groupAnnotations:region latitudeDivCount:20 longitudeDivCount:24];
    _groupAnnotations[1] = [self groupAnnotations:region latitudeDivCount:10 longitudeDivCount:12];
    _groupAnnotations[2] = [self groupAnnotations:region latitudeDivCount:5 longitudeDivCount:6];
}

- (NSDictionary*)groupAnnotations:(MKCoordinateRegion)region latitudeDivCount:(int)latitudeDivCount longitudeDivCount:(int)longitudeDivCount
{
    NSMutableDictionary* groupAnnotations = [NSMutableDictionary dictionaryWithCapacity:latitudeDivCount * longitudeDivCount];
    
    CLLocationDegrees top = region.center.latitude - (region.span.latitudeDelta / 2);
    CLLocationDegrees latitudeDelta = region.span.latitudeDelta / latitudeDivCount;
    
    CLLocationDegrees left = region.center.longitude - (region.span.longitudeDelta / 2);
    CLLocationDegrees longitudeDelta = region.span.longitudeDelta / longitudeDivCount;
    
    for (KMTreasureAnnotation* a in _treasureAnnotations) {
        CLLocationDegrees v = a.coordinate.latitude - top;
        v /= latitudeDelta;
        if (v < 0.0) continue;
        if (v >= latitudeDivCount) continue;
        
        CLLocationDegrees h = a.coordinate.longitude - left;
        h /= longitudeDelta;
        if (h < 0.0) continue;
        if (h >= longitudeDivCount) continue;
        
        NSString* key = [NSString stringWithFormat:@"%dx%d", (int)h, (int)v];
        if ([groupAnnotations valueForKey:key] == nil) {
            KMAreaAnnotation* pin = [[KMAreaAnnotation alloc] init];
            CLLocationDegrees latitude = (int)v * latitudeDelta;
            CLLocationDegrees longitude = (int)h * longitudeDelta;
            pin.coordinate = CLLocationCoordinate2DMake(latitude + top + (latitudeDelta / 2.0),
                                                        longitude + left + (longitudeDelta / 2.0));
            pin.title = nil;
            [groupAnnotations setValue:pin forKey:key];
        }
    }
    return groupAnnotations;
}

+ (int)gropuIndexForRegion:(MKCoordinateRegion)region
{
    int index = -1;
    for (int thresholdSpan = KMVaultsAreaThresholdSpan; index < 2; thresholdSpan *= 2) {
        MKCoordinateRegion threshold = MKCoordinateRegionMakeWithDistance(region.center, thresholdSpan, thresholdSpan);
        if (region.span.longitudeDelta < threshold.span.longitudeDelta) {
            break;
        }
        index++;
    }
    return index;
}

KMRegion KMRegionFromMKCoordinateRegion(MKCoordinateRegion region)
{
    KMRegion kmregion;
    kmregion.minlatitude = region.center.latitude - region.span.latitudeDelta;
    kmregion.maxlatitude = region.center.latitude + region.span.latitudeDelta;
    kmregion.minlongitude = region.center.longitude - region.span.longitudeDelta;
    kmregion.maxlongitude = region.center.longitude + region.span.longitudeDelta;
    return kmregion;
}

BOOL MKCoordinateInKMRegion(CLLocationCoordinate2D coordinate, KMRegion region)
{
    if (coordinate.longitude < region.minlongitude) return NO;
    if (coordinate.longitude > region.maxlongitude) return NO;
    if (coordinate.latitude < region.minlatitude) return NO;
    if (coordinate.latitude > region.maxlatitude) return NO;
    return YES;
}

static KMTreasureAnnotation* hitAnnotationCheck(KMTreasureAnnotation* a, KMRegion hr)
{
    if (a.passed)
        return nil;
    if (a.locking)
        return nil;
    if (MKCoordinateInKMRegion(a.coordinate, hr) == NO)
        return nil;
    return a;
}

/*
    Landmarkの数が多い場合は、与えられたregion範囲のLandmarkを検索し、
    結果を_treasureAnnotationsにキャッシュしたKMTreasureAnnotationインスタンスのLandmarkと比較し
    新しいものだけ_treasureAnnotationsにKMTreasureAnnotationとしてキャッシュする。
    そして、検索されなかったLandmarkを持つKMTreasureAnnotationは_treasureAnnotationsからとりはぶく
    といった作業が必要。
 */
- (NSSet*)treasureAnnotationsInRegion:(MKCoordinateRegion)region hunter:(CLLocationCoordinate2D)hunter hitTreasureAnnotation:(KMTreasureAnnotation**)hitTreasureAnnotation
{
    NSMutableSet* set = [NSMutableSet set];
    KMRegion r = KMRegionFromMKCoordinateRegion(region);    //  regionで指定された範囲を決定

    int index = [[self class] gropuIndexForRegion:region];
    if (index >= 0) {
        NSArray* garray = [_groupAnnotations[index] allValues];
        for (MKPointAnnotation* a in garray) {
            if (MKCoordinateInKMRegion(a.coordinate, r)) {
                [set addObject:a];
            }
        }
        for (KMTreasureAnnotation* a in _treasureAnnotations) {
            if (a.target == NO)
                continue;
            [set addObject:a];
        }
        return set;
    }
    
    //  nearThresholdMeter内の場合、無条件に発見（find）フラグをたてる。その範囲。
    MKCoordinateRegion peekregion = MKCoordinateRegionMakeWithDistance(hunter, nearThresholdMeter, nearThresholdMeter);
    KMRegion pr = KMRegionFromMKCoordinateRegion(peekregion);    //  peekregionで指定された範囲を決定
    MKCoordinateRegion hitregion = MKCoordinateRegionMakeWithDistance(hunter, hitThresholdMeter, hitThresholdMeter);
    CLLocationDegrees minlatitudeDelta = region.span.latitudeDelta / 15;
    CLLocationDegrees minlongitudeDelta = region.span.longitudeDelta / 15;
    if (hitregion.span.latitudeDelta < minlatitudeDelta) hitregion.span.latitudeDelta = minlatitudeDelta;
    if (hitregion.span.longitudeDelta < minlongitudeDelta) hitregion.span.longitudeDelta = minlongitudeDelta;
    KMRegion hr = KMRegionFromMKCoordinateRegion(hitregion);    //  hitregionで指定された範囲を決定
    
    KMTreasureAnnotation* hitAnnotation = nil;
    for (KMTreasureAnnotation* a in _treasureAnnotations) {
        if (MKCoordinateInKMRegion(a.coordinate, r) == NO)
            continue;
        if (a.find || a.target) {
            if (hitAnnotation == nil) {
                hitAnnotation = hitAnnotationCheck(a, hr);
            }
            [set addObject:a];
            continue;
        }
        if (MKCoordinateInKMRegion(a.coordinate, pr) == NO)
            continue;
        //  nearThresholdMeter内なので無条件に発見（find）フラグをたてる。
        a.find = YES;
        if (hitAnnotation == nil) {
            hitAnnotation = hitAnnotationCheck(a, hr);
        }
        [set addObject:a];
    }
    if (hitTreasureAnnotation) {
        *hitTreasureAnnotation = nil;
        if (hitAnnotation) {
            *hitTreasureAnnotation = hitAnnotation;
        }
    }
    return set;
}

- (void)search:(CLLocationCoordinate2D)center radiusMeter:(CLLocationDistance)radiusMeter
{
    MKCoordinateRegion peekregion = MKCoordinateRegionMakeWithDistance(center, radiusMeter, radiusMeter);
    KMRegion pr = KMRegionFromMKCoordinateRegion(peekregion);    //  peekregionで指定された範囲を決定
    for (KMTreasureAnnotation* a in _treasureAnnotations) {
        if (a.find)
            continue;   //  すでに設定済み
        if (MKCoordinateInKMRegion(a.coordinate, pr) == NO)
            continue;   //  範囲外
        a.find = YES;
    }
}

- (NSArray*)landmarksForKey :(Tag *)tag
{
    NSArray* array = [tag.landmarks allObjects];
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[array count]];
    for (Landmark* landmark in array) {
        int index = [_treasureAnnotations indexOfObjectPassingTest:^BOOL(KMTreasureAnnotation* obj, NSUInteger idx, BOOL *stop) {
            if ((obj.landmark == landmark) && obj.find){
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound){
            [result addObject:[_treasureAnnotations objectAtIndex:index]];
        }
    }
    return result;
}

- (NSArray*)keywords
{
    return [Landmark tagsPassed:_moc];
}

- (NSArray*)landmarks
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[_treasureAnnotations count]];
    for (KMTreasureAnnotation* a in _treasureAnnotations) {
        if (a.find) {
            [array addObject:a];
        }
    }
    return array;
}

- (int)totalLandmarkCount
{
    return [_treasureAnnotations count];
}

- (void)setFindAnnotationRelationalKeyword:(Tag*)keyword
{
    for (KMTreasureAnnotation* a in _treasureAnnotations) {
        int index = [a.keywords indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if (keyword == obj) {
                return YES;
            }
            return NO;
        }];
        if (index != NSNotFound) {
            a.find = YES;
        }
    }
}

/*
 annotationが持つキーワードと同じものを持つランドマークのfindをYESにする。
 ただし以下のキーワードは、他に検索キーワードを持ってない場合のみ使う
    寺社 文化財
 */
- (void)setPassedAnnotation:(KMTreasureAnnotation*)annotation
{
    if (annotation.passed == NO) {
        _totalPassedCount++;
        annotation.passed = YES;
    }

    const int seedKeywordCount = 5;
    NSString* seedKeywords[] = {@"寺社", @"重要文化財", @"国宝", @"公共施設", @"商業施設", nil};
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[annotation.keywords count]];
    for (Tag* keyword in annotation.keywords) {
        BOOL found = NO;
        for (int i = 0; i < seedKeywordCount; i++) {
            if (seedKeywords[i] && [keyword.name isEqualToString:seedKeywords[i]]) {
                found = YES;
                seedKeywords[i] = nil;
                break;
            }
        }
        if (!found) {
            [array addObject:keyword];
        }
    }
    if ([array count] == 0) {
        //  最初のキーワードで検索
        [self setFindAnnotationRelationalKeyword:[annotation.keywords objectAtIndex:0]];
    } else {
        for (Tag* keyword in array) {
            [self setFindAnnotationRelationalKeyword:keyword];
        }
    }
    [self handleProgress];
}

- (void)handleProgress
{
    [_progress updateAnnotations:[_treasureAnnotations count] passed:_totalPassedCount];
    [_progress save];
}

- (void)save
{
    if (![_moc save:nil]) {
        // FIXME
    }
}

@end

//  MKMetersBetweenMapPoints