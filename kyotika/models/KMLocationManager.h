//
//  KMLocationManager.h
//  kyotika
//
//  Created by kunii on 2013/02/01.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KMLocationManager;

@protocol KMLocationManagerDelegate <NSObject>
- (void)locationManagerUpdate:(KMLocationManager*)locationManager;
@end

@interface KMLocationManager : NSObject
- (void)start;
- (void)stop;
@property (assign) id<KMLocationManagerDelegate> delegate;
@property (readonly, retain) CLLocation* curtLocation;
@end
