//
//  KMAnnotationView.h
//  kyotika
//
//  Created by kunii on 2013/02/09.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMAnnotationView : MKAnnotationView
- (void)startAnimation;
- (void)restoreAnimation;
@end
