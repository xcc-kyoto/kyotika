//
//  KMTreasureAnnotationView.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface KMTreasureAnnotation : MKPointAnnotation
@property BOOL passed;
@property BOOL find;
@property (copy) NSArray* keywords;
@property (retain) NSDate* lastAtackDate;

- (NSString*)question;
- (NSArray*)answers;
- (int)correctAnswerIndex;
@end
