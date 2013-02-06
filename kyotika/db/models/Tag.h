//
//  Tag.h
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/6/13.
//  Copyright (c) 2013 國居貴浩. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Landmark;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *landmarks;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addLandmarksObject:(Landmark *)value;
- (void)removeLandmarksObject:(Landmark *)value;
- (void)addLandmarks:(NSSet *)values;
- (void)removeLandmarks:(NSSet *)values;

@end
