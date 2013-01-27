//
//  KMFirstViewController.h
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMLandmarkListController;

@protocol KMLandmarkListControllerDelegate <NSObject>
- (void)landmarkListControllerShowLocation:(KMLandmarkListController*)controller object:(id)object;
- (NSString*)landmarkListControllerLandmark:(KMLandmarkListController*)controller fromObject:(id)object;
@end

@interface KMLandmarkListController : UITableViewController
@property (copy) NSArray* landmarks;
@property (assign) id<KMLandmarkListControllerDelegate> landmarksDelegate;
@end
