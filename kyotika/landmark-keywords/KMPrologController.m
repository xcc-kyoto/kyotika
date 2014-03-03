//
//  KMPrologController.m
//  kyotika
//
//  Created by kunii on 2013/02/02.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMPrologController.h"
#import "KMTreasureHunterAnnotationView.h"

@interface KMPrologController ()
@property (assign) IBOutlet UIScrollView* scrollView;
@property (strong) IBOutlet UIView* contentsView;
@property (assign) IBOutlet KMTreasureHunterView* v0;
@property (assign) IBOutlet KMTreasureHunterView* v1;
@property (assign) IBOutlet KMTreasureHunterView* v2;
@property (assign) IBOutlet KMTreasureHunterView* v3;
@end

@implementation KMPrologController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"About", @"About");
        self.tabBarItem.image = [UIImage imageNamed:@"About"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = _contentsView.frame;
    frame.origin.x = (self.view.bounds.size.width - _scrollView.contentSize.width) / 2;
    _contentsView.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_scrollView flashScrollIndicators];
    _scrollView.contentSize = _contentsView.bounds.size;
    CGRect frame = _contentsView.frame;
    frame.origin.x = (self.view.bounds.size.width - _scrollView.contentSize.width) / 2;
    _contentsView.frame = frame;
    [_scrollView addSubview:_contentsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
