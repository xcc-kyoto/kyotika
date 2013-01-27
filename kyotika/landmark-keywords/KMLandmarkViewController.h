//
//  KMLandscapeViewController.h
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMKeywordListController.h"

@class KMLandmarkViewController;

@protocol KMLandmarkViewControllerDelegate <KMKeywordListControllerDelegate>
-(void)landmarkViewControllerDone:(KMLandmarkViewController*)viewController;
@end

@interface KMLandmarkViewController : UITabBarController
@property (copy) NSString* urlString;
@property (copy) NSArray* keywords;
@property (assign) id<KMLandmarkViewControllerDelegate> landmarkDelegate;
@end
