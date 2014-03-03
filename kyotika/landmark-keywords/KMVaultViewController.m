//
//  KMVaultViewController.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMVaultViewController.h"
#import "KMLandmarkListController.h"
#import "KMPrologController.h"

@interface KMVaultViewController () {
    KMLandmarkListController *viewController1;
    KMKeywordListController *viewController2;
    KMPrologController *viewController3;
}

@end

@implementation KMVaultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //  iOS 7用タブバーアイコン位置調整
    if ([self.tabBar respondsToSelector:@selector(setItemPositioning:)])
        self.tabBar.itemPositioning = UITabBarItemPositioningCentered;
    
    viewController1 = [[KMLandmarkListController alloc] initWithStyle:UITableViewStylePlain];
    viewController1.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    viewController2 = [[KMKeywordListController alloc] initWithStyle:UITableViewStylePlain];
    viewController2.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    viewController3 = [[KMPrologController alloc] init];
    viewController3.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];

    UINavigationController* nav1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    UINavigationController* nav2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    UINavigationController* nav3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    self.viewControllers = @[nav1, nav2, nav3];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    viewController1.navigationItem.title = [NSString stringWithFormat:@"%@ %d/%d",
                                        viewController1.title,
                                        [_landmarks count],
                                        _totalLandmarkCount];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    viewController1.landmarks = _landmarks;
    viewController1.landmarksDelegate = _vaultsDelegate;
    [viewController1.tableView reloadData];
    
    viewController2.keywords = _keywords;
    viewController2.keywordsDelegate = _vaultsDelegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done
{
    [_vaultsDelegate vaultViewControllerDone:self];
}
@end
