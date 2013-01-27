//
//  KMLandscapeInfoViewController.h
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMLandmarkInfoViewController : UIViewController
@property (copy) NSString* urlString;
- (void)reload;
@end
