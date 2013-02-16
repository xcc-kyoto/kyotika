//
//  KMPrologController.m
//  kyotika
//
//  Created by kunii on 2013/02/02.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMPrologController.h"

@interface KMPrologController ()
@property (assign) IBOutlet UIScrollView* scrollView;
@property (strong) IBOutlet UIView* contentsView;
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

- (void)popMayumaro
{
    UIImage *image = [UIImage imageNamed:@"mayumaro2"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    
    CAKeyframeAnimation * popAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSArray* keyAttributes = @[
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]
                               ];
    popAnimation.values = keyAttributes;
    popAnimation.duration= 1;
    [imageView.layer addAnimation:popAnimation forKey:@"popAnimation"];
    [self.view addSubview:imageView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_scrollView flashScrollIndicators];
    _scrollView.contentSize = _contentsView.bounds.size;
    [_scrollView addSubview:_contentsView];
    [self popMayumaro];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
