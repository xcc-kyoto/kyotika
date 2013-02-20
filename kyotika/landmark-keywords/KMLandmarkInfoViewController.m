//
//  KMLandscapeInfoViewController.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMLandmarkInfoViewController.h"

@interface KMLandmarkInfoViewController ()<UIWebViewDelegate> {
    UIWebView*  _webView;
    UIActivityIndicatorView* _activitiIndicator;
    UILabel*    _errorLabel;
    NSURL*      _url;
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
    _webView.delegate = self;
    _activitiIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activitiIndicator.color = [UIColor darkGrayColor];
    [_webView addSubview:_activitiIndicator];
    
    self.view = _webView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ((_url == nil) && _urlString) {
        _activitiIndicator.frame = _webView.bounds;
        _url = [NSURL URLWithString:[_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [_webView  loadRequest:[NSURLRequest requestWithURL:_url]];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_errorLabel removeFromSuperview];
    _errorLabel = nil;
    [_activitiIndicator startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activitiIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activitiIndicator stopAnimating];
    _errorLabel = [[UILabel alloc] init];
    _errorLabel.frame = _webView.bounds;
    [_webView addSubview:_errorLabel];
    _errorLabel.text = NSLocalizedString(@"Loading failed", @"Loading failed");
}
@end