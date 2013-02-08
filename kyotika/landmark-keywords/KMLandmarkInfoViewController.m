//
//  KMLandscapeInfoViewController.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMLandmarkInfoViewController.h"

@interface KMLandmarkInfoViewController () {
    UIWebView*  _webView;
}

@end

@implementation KMLandmarkInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"LandmarkInfo", @"LandmarkInfo");
        self.tabBarItem.image = [UIImage imageNamed:@"landmarkList"];
    }
    return self;
}

- (void)loadView
{
    _webView = [[UIWebView alloc] init];
    self.view = _webView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_urlString)
        [_webView  loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end