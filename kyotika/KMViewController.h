//
//  KMViewController.h
//  KyotoMap
//
//  Created by kunii on 2013/01/11.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMViewController : UIViewController
@property (strong, nonatomic) NSManagedObjectContext *moc;
- (void)showProlog;
@end
