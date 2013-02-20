//
//  KMViewController.h
//  KyotoMap
//
//  Created by kunii on 2013/01/11.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KMVaults;

@interface KMViewController : UIViewController
@property (retain, nonatomic) KMVaults* vaults;
@property BOOL prologue;                      /// 一度だけYESになる
@end
