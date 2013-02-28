//
//  KMEventViewController.m
//  kyotika
//
//  Created by kunii on 2013/02/03.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "KMEventViewController.h"

@interface KMEventViewController () {
    int _stage;
    UIImageView* _imageView;
}
@property (assign) IBOutlet UITextView* textView;
@property (assign) IBOutlet UILabel* helpLabel;
@end

@implementation KMEventViewController

@synthesize progress = _progress;

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
    _imageView = [[UIImageView alloc] init];
    [self.view insertSubview:_imageView belowSubview:_textView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
    [super viewWillAppear:animated];

    CGRect frame = self.view.bounds;
    frame.origin.y += frame.size.height - frame.size.width;
    frame.size.height = frame.size.width;
    _imageView.frame = frame;
    _imageView.layer.anchorPoint = CGPointMake(1.0,1.0);
    _imageView.layer.frame = frame;

    if (_progress.isJustComplete) {
        _textView.text = NSLocalizedString(@"Complite Message", @"Complite Message");
        return;
    }
    
    _imageView.image = [UIImage imageNamed:@"rainbow"];
    CAKeyframeAnimation * animation =[CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    float a0 = 0.1;
    float a1 = _progress.complete;
    animation.values = @[
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(a0, a0, 1.0)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(a1, a1, 1.0)]
                         ];
    animation.keyTimes = @[
                           @0.0,
                           @1.0
                           ];
    
    CAKeyframeAnimation * alphaanimation =[CAKeyframeAnimation
                                           animationWithKeyPath:@"opacity"];
    alphaanimation.values = @[
                              [NSNumber numberWithFloat:a0],
                              [NSNumber numberWithFloat:a1]
                              ];
    alphaanimation.keyTimes = animation.keyTimes;
    CAAnimationGroup *theGroup = [CAAnimationGroup animation];
    theGroup.animations = @[animation, alphaanimation];
    
    theGroup.duration= 2;
    theGroup.repeatCount = HUGE_VALF;
    theGroup.autoreverses = YES;
    [_imageView.layer addAnimation:theGroup forKey:@"puyopuyo"];
    
    NSString* messages[] = {
        NSLocalizedString(@"Event Message 0", @"Event Message 0"),
        NSLocalizedString(@"Event Message 1", @"Event Message 1"),
        NSLocalizedString(@"Event Message 2", @"Event Message 2"),
        NSLocalizedString(@"Event Message 3", @"Event Message 3"),
        NSLocalizedString(@"Event Message 4", @"Event Message 4")
    };
    _textView.text = messages[_progress.messageIndex];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });

    if (_progress.isWaitingForNero) {
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _helpLabel.alpha = 0;
            _helpLabel.hidden = NO;
            [UIView animateWithDuration:1 animations:^{
                _helpLabel.alpha = 1;
            }];
        });
    }
}
- (IBAction)tap
{
    if (_progress.isCompleted) {
        ;
    } else if (_progress.isTogetherWithNero) {
        if (_stage == 0) {
            _stage++;
            _textView.text = NSLocalizedString(@"Meet Message 1", @"Meet Message 1");
            [_imageView.layer removeAnimationForKey:@"puyopuyo"];
            UIImage* image = [UIImage imageNamed:@"meet-again-1"];
            _imageView.image = image;
            return;
        } else if (_stage == 1) {
            _stage++;
            _textView.text = NSLocalizedString(@"Meet Message 2", @"Meet Message 2");
            UIImage* image = [UIImage imageNamed:@"meet-again-2"];
            _imageView.image = image;
            return;
        } else if (_stage == 2) {
            _imageView.image = nil;
            _stage++;
            _textView.text = NSLocalizedString(@"Meet Message 3", @"Meet Message 3");
            return;
        }
    }
    [_delegate eventViewControllerDone:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
