//
//  KMVaults.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KMVaults : NSObject
- (NSSet*)treasureAnnotationsInRegion:(MKCoordinateRegion)region;
- (NSArray*)landmarksForKey:(id)key;
- (NSArray*)keywords;
- (NSArray*)landmarks;
@end
