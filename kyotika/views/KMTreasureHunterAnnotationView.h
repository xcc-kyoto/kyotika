//
//  KMTreasureHunterAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@class KMTreasureHunterAnnotation;

@interface KMTreasureHunterAnnotationView : MKAnnotationView
- (void)startAnimation;
- (void)stopAnimation;
- (void)setCourse:(CLLocationDirection)course;
- (void)setRegion:(MKCoordinateRegion)region;

@property (assign) KMTreasureHunterAnnotation* hunterAnnotation;
@end

