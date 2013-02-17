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

@interface KMPrologController () {
    UIImageView *_imageView;
}
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


- (void)popMayumaro
{
    if (_imageView == nil) {
        UIImage *image = [UIImage imageNamed:@"mayumaro"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        [self.navigationController.view addSubview:_imageView];
    }
    CGRect rect = CGRectZero;
    rect.size = _imageView.image.size;
    _imageView.frame = CGRectOffset(rect, self.view.bounds.size.width - rect.size.width, 30);
    [_imageView.layer removeAnimationForKey:@"opacity"];
    _imageView.layer.opacity = 1.0;

    CAKeyframeAnimation * popAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSArray* keyAttributes = @[
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity],
                               [NSValue valueWithCATransform3D:CATransform3DIdentity]
                               ];
    popAnimation.values = keyAttributes;
    popAnimation.keyTimes = @[
                                     @0.0,
                                     @0.2,
                                     @0.25,
                                     @0.3,
                                     @1.0];
    popAnimation.duration= 2;
    popAnimation.delegate = self;
    [_imageView.layer addAnimation:popAnimation forKey:@"popAnimation"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (theAnimation == [_imageView.layer animationForKey:@"opacity"]) {
        _imageView.layer.opacity = 0.0;
        [_imageView.layer removeAnimationForKey:@"opacity"];
        return;
    }
    if (flag == NO) {//  中断
        _imageView.layer.opacity = 0.0;
        return;
    }
    CABasicAnimation* fadeoutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeoutAnimation.toValue = @0.0;
    fadeoutAnimation.duration= 2;
    fadeoutAnimation.fillMode = kCAFillModeForwards;
    fadeoutAnimation.removedOnCompletion = NO;
    fadeoutAnimation.delegate = self;
    [_imageView.layer addAnimation:fadeoutAnimation forKey:@"opacity"];
    return;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_scrollView flashScrollIndicators];
    _scrollView.contentSize = _contentsView.bounds.size;
    [_scrollView addSubview:_contentsView];
    if (_pop)
        [self popMayumaro];
    _pop = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
