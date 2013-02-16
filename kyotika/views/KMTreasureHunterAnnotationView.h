//
//  KMTreasureHunterAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "KMAnnotationView.h"

@class KMTreasureHunterAnnotation;

@interface KMTreasureHunterAnnotationView : KMAnnotationView
- (void)setRegion:(MKCoordinateRegion)region;
- (void)setStandbyNero:(BOOL)standbyNero;
@property (assign) KMTreasureHunterAnnotation* hunterAnnotation;
@end

