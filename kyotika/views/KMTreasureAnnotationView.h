//
//  KMTreasureAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMTreasureAnnotationView : MKAnnotationView
- (void)startAnimation;
- (void)stopAnimation;
- (void)enterNotification;

- (BOOL)enter:(CLLocationCoordinate2D)location;
@end
