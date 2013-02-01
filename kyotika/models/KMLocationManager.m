//
//  KMLocationManager.m
//  kyotika
//
//  Created by kunii on 2013/02/01.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "KMLocationManager.h"

@interface KMLocationManager()<CLLocationManagerDelegate>
@end

@implementation KMLocationManager {
    CLLocationManager*  _locationManager;
}

- (void)start
{
    if (_locationManager == nil)
        _locationManager = [[CLLocationManager alloc] init];
    if (_locationManager.delegate)  //  スタート済み
        return;
    _locationManager.delegate = self;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;    デフォルトをそのまま使う
    _locationManager.distanceFilter = 10.0;  //  10m以上の移動で通知
    [_locationManager startUpdatingLocation];
}

- (void)stop
{
    if (_locationManager.delegate == nil)   //  停止済み
        return;
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
}

/*
    位置が変わった
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.horizontalAccuracy < 0) //  負の値はあてにならない事を意味する
        return;
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0)                  //  5秒以上時間が経っている：キャッシュデータ
        return;
    if (_curtLocation) {
        CLLocationDistance distance = [newLocation distanceFromLocation:_curtLocation];
        if (distance < _locationManager.desiredAccuracy)
            return;
    }
    _curtLocation = [newLocation copy];
    [_delegate locationManagerUpdate:self];
}

/*
    失敗レポート
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error code] != kCLErrorLocationUnknown) {
        [self stop];
    }
}


@end
