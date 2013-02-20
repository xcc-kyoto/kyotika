//
//  KMEventViewController.h
//  kyotika
//
//  Created by kunii on 2013/02/03.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KMEventViewController;
@protocol KMEventViewControllerDelegate <NSObject>
- (void)eventViewControllerDone:(KMEventViewController*)viewController;
@end

@interface KMEventViewController : UIViewController
@property (assign) float complete;
@property (assign) id<KMEventViewControllerDelegate> delegate;
@end
