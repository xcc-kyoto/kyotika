//
//  KMVaultViewController.h
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMKeywordListController.h"

@class KMVaultViewController;

@protocol KMVaultViewControllerDelegate <KMKeywordListControllerDelegate>
-(void)vaultViewControllerDone:(KMVaultViewController*)viewController;
@end

@interface KMVaultViewController : UITabBarController
@property (copy) NSArray* keywords;
@property (copy) NSArray* landmarks;
@property (assign) id<KMVaultViewControllerDelegate> vaultsDelegate;

@end
