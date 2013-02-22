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
- (void)setSearcherHidden:(BOOL)hidden;
- (void)setStandbyNero:(BOOL)standbyNero;
- (void)searchAnimationOnView:(UIView*)view target:(id)target action:(SEL)action;
@property (assign) KMTreasureHunterAnnotation* hunterAnnotation;
@end

@interface KMTreasureHunterView : UIView
- (void)startAnimation;
@end
