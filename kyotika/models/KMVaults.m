//
//  KMVaults.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMVaults.h"
#import "KMTreasureAnnotationView.h"

@implementation KMVaults {
    NSMutableArray* _annotations;
    NSMutableSet* _curtAnnotations;
    
}

- (NSString*)landmarksPath
{
    static NSString* landmarksPath = nil;
    if (landmarksPath == nil) {
        landmarksPath = [[NSBundle mainBundle] resourcePath];
        landmarksPath = [landmarksPath stringByAppendingPathComponent:@"landmarks.plist"];
    }
    return landmarksPath;
}

- (void)load
{
    NSArray* a = [NSArray arrayWithContentsOfFile:self.landmarksPath];
    for (id dic in a) {
        double latitude = [[dic valueForKey:@"latitude"] doubleValue];
        double longitude = [[dic valueForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        KMTreasureAnnotation* pin = [[KMTreasureAnnotation alloc] init];
        pin.title = [dic valueForKey:@"title"];
        pin.coordinate = coordinate;
        pin.keywords = [dic valueForKey:@"keywords"];
        [_annotations addObject:pin];
    }
}

- (void)dummy
{
    for (int i = 0; i < 100; i++) {
        KMTreasureAnnotation* pin = [[KMTreasureAnnotation alloc] init];
        float latitude = (float)(rand() % 10000) / 10000.0;
        float longitude = (float)(rand() % 10000) / 10000.0;
        latitude -= 0.5;
        longitude -= 0.5;
        pin.coordinate = CLLocationCoordinate2DMake(35.0212466 + latitude * 0.05,
                                                  135.7555968 + longitude * 0.05);
        pin.title = [NSString stringWithFormat:@"title %d", i];
        pin.keywords = [NSArray arrayWithObjects:
                        [NSNumber numberWithInt:rand() % 10],
                        [NSNumber numberWithInt:rand() % 10],
                        [NSNumber numberWithInt:rand() % 10],
                        nil];
        [_annotations addObject:pin];
    }
}

- (id)init
{
    self = [super init];
    if (self ) {
        _annotations = [ NSMutableArray array];
        _curtAnnotations = [ NSMutableArray array];
        [self dummy];
    }
    return self;
}

- (NSSet*)treasureAnnotationsInRegion:(MKCoordinateRegion)region
{
    float minlatitude = region.center.latitude - region.span.latitudeDelta;
    float maxlatitude = region.center.latitude + region.span.latitudeDelta;
    float minlongitude = region.center.longitude - region.span.longitudeDelta;
    float maxlongitude = region.center.longitude + region.span.longitudeDelta;

    MKCoordinateRegion peekregion = MKCoordinateRegionMakeWithDistance(region.center, 200.0, 200.0);
    float peekminlatitude = peekregion.center.latitude - peekregion.span.latitudeDelta;
    float peekmaxlatitude = peekregion.center.latitude + peekregion.span.latitudeDelta;
    float peekminlongitude = peekregion.center.longitude - peekregion.span.longitudeDelta;
    float peekmaxlongitude = peekregion.center.longitude + peekregion.span.longitudeDelta;
    
    NSMutableSet* set = [NSMutableSet set];
    for (KMTreasureAnnotation* a in _annotations) {
        if (a.coordinate.longitude < minlongitude) continue;
        if (a.coordinate.longitude > maxlongitude) continue;
        if (a.coordinate.latitude < minlatitude) continue;
        if (a.coordinate.latitude > maxlatitude) continue;
        if (a.find) {
            [set addObject:a];
            continue;
        }
        if (region.span.latitudeDelta > 0.0050)
            continue;
        if (a.coordinate.longitude < peekminlongitude) continue;
        if (a.coordinate.longitude > peekmaxlongitude) continue;
        if (a.coordinate.latitude < peekminlatitude) continue;
        if (a.coordinate.latitude > peekmaxlatitude) continue;
        a.find = YES;
        [set addObject:a];
    }
    _curtAnnotations = set;
    return _curtAnnotations;
}

- (NSArray*)landmarksForKey:(id)key
{
    NSMutableArray*landmarks = [NSMutableArray array];
    int keyNumber = [key intValue];
    for (KMTreasureAnnotation* a in _annotations) {
        if (a.passed) {
            for (NSNumber* keyword in a.keywords) {
                if (keyNumber == [keyword intValue]) {
                    [landmarks addObject:a];
                    break;
                }
            }
        }
    }
    return landmarks;
}

- (NSArray*)keywords
{
    NSMutableArray*keywords = [NSMutableArray array];
    for (KMTreasureAnnotation* a in _annotations) {
        if (a.passed) {
            [keywords addObjectsFromArray:a.keywords];
        }
    }
    return keywords;
}

- (NSArray*)landmarks
{
    NSMutableArray*landmarks = [NSMutableArray array];
    for (KMTreasureAnnotation* a in _annotations) {
        if (a.passed) {
            [landmarks addObject:a];
        }
    }
    return landmarks;
}
@end

//  MKMetersBetweenMapPoints