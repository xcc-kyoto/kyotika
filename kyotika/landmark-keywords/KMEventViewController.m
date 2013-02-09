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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _complite = 0.2;
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

    if (_complite == 2.0) {
        _textView.text = @"これで現在、登録されているスポットはすべて訪ね終わりました。京都チカチカツアーのご利用、誠にありがとうございました。\nでも、二人の旅は始まったばかりだ！";
        return;
    }
    
    _imageView.image = [UIImage imageNamed:@"rainbow"];
    CAKeyframeAnimation * animation =[CAKeyframeAnimation
                                      animationWithKeyPath:@"transform"];
    
    float a0 = 0.1;
    float a1 = _complite;
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
        @"な、なんだか思い出せそうだワン",
        @"あ、あれは確か…、\nそうか、ここが…",
        @"お、思いだっ、ぎゃわん、頭が…\n急に頭がぁああ\nやっぱり思い出せないワォオオオン",
        @"こ、ここは",
        @"お、思い出したワン！\nここが、あの…\n\n「パ、破闘羅主」"
    };
    int index = (int)(_complite * 10.0) / 2 - 1;
    if (index < 0) index = 0;
    if (index >= 5) index = 4;
    _textView.text = messages[index];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });

    if (_complite < 0.4) {
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
    if (_complite >= 2.0) {
        ;
    } else if (_complite >= 1.0) {
        if (_stage == 0) {
            _stage++;
            _textView.text = @"そんな、まさか、でも\n間違いない…\n懐かしいみすぼらしいチョッキの小僧。\n\n寝露、寝露、寝露ォオオオ";
            [_imageView.layer removeAnimationForKey:@"puyopuyo"];
            UIImage* image = [UIImage imageNamed:@"meet-again-1"];
            _imageView.image = image;
            return;
        } else if (_stage == 1) {
            _stage++;
            _textView.text = @"「破闘羅主ーーー」\n「アォオオオオオーーーン」\nもう大丈夫だー。心配ない寝露、これからはいつでも一緒だああ。";
            UIImage* image = [UIImage imageNamed:@"meet-again-2"];
            _imageView.image = image;
            return;
        } else if (_stage == 2) {
            _imageView.image = nil;
            _stage++;
            _textView.text = @"「どこ行ってたんだよぉ、勝手にいなくなってえええ。どんだけ心配かけさせたら気が済むんだこの駄犬があぁああ。」\n\nええええええええええ\n「ワキャン、キャン、キャィイイン」\n\n寝露が破闘羅主のお尻を叩く。\n「いっつも迷惑ばっかかけてええ」\n叩きながらもそれでも寝露は嬉しそうだ。\n破闘羅主も笑っている。お日様も笑ってるぅ、る〜るる、るるっる〜♩\nとにかく二人は再会できた。さあ、これからは二人で京都見学だ。\n\nレッツゴー京都！";
            return;
        }
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
