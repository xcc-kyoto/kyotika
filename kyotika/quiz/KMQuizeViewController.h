//
//  KMQuizeViewController.h
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KMQuizeViewControllerDelegate;

@interface KMQuizeViewController : UITableViewController
@property (strong) NSString* question;
@property (strong) NSArray* answers;
@property (assign) id userRef;
@property (readonly) int selectedIndex;
@property (assign) id<KMQuizeViewControllerDelegate> quizeDelegate;
@end

@protocol KMQuizeViewControllerDelegate <NSObject>
- (void)quizeViewControllerAnswer:(KMQuizeViewController*)controller;
@end