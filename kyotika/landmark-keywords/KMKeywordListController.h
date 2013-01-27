//
//  KMSecondViewController.h
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KMLandmarkListControllerDelegate;
@class KMKeywordListController;

@protocol KMKeywordListControllerDelegate <NSObject, KMLandmarkListControllerDelegate>
- (void)keywordListControllerShowLocation:(KMKeywordListController*)controller object:(id)object;
- (NSString*)keywordListControllerKeyword:(KMKeywordListController*)ViewController fromObject:(id)object;
- (NSArray*)keywordListControllerLandmarks:(KMKeywordListController*)ViewController fromObject:(id)object;
@end

@interface KMKeywordListController : UITableViewController
@property (copy) NSArray* keywords;
@property (assign) id<KMKeywordListControllerDelegate> keywordsDelegate;
@end
