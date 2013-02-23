//
//  KMTreasureHunterAnnotationView.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMTreasureHunterAnnotationView.h"
#import "KMTreasureHunterAnnotation.h"

@interface KMTreasureHunterAnnotationView() {
    CALayer* _walker;
    CALayer*     _searcher;
    int _direction;
    BOOL    _standbyNero;
    UIView*                         _searchAnimationView;
    UIView*                         _searchAnimationView2;
    id      _searchNotifierTarget;
     SEL     _searchNotifierAction;
}
@end


@implementation KMTreasureHunterAnnotationView
+ (UIImage*)imageWithNero:(BOOL)standbyNero
{
    int index = standbyNero?1:0;
    static UIImage* walkerImage[2];
    if (walkerImage[index] == nil)
        walkerImage[index] = [UIImage imageNamed:(index == 0) ? @"patorash" : @"patorash_nero"];
    return walkerImage[index];
}

+ (NSArray*)contentsRectArrayStandbyNero:(BOOL)standbyNero
{
    int index = standbyNero?1:0;
    static NSMutableArray* arrays[2];
    if (arrays[index] == nil) {
        arrays[index] = [NSMutableArray arrayWithCapacity:4];
        CGRect r = {0,0,0.25,0.25};
        if (index == 1) r.size.width = 1;
        for (int i = 0; i < 4; i++) {
            [arrays[index] addObject:[NSValue valueWithCGRect:r]];
            r.origin.y += 0.25;
        }
    }
    return arrays[index];
}

+ (NSArray*)contentsRectArrayWalkWithDirection:(int)direction
{
    static NSArray* array[] = {nil, nil, nil, nil};
    if (array[direction] == nil) {
        NSMutableArray* tmparray = [NSMutableArray arrayWithCapacity:4];
        CGRect r = {0,0,0.25,0.25};
        r.origin.y = 0.25 * direction;
        for (int i = 0; i < 4; i++) {
            [tmparray addObject:[NSValue valueWithCGRect:r]];
            r.origin.x += 0.25;
        }
        array[direction] = tmparray;
    }
    return array[direction];
}


- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // フレームサイズを適切な値に設定する
        CGRect myFrame = self.frame;
        myFrame.size.width = 48;
        myFrame.size.height = 48;
        self.frame = myFrame;
        // 不透過プロパティをNOに設定することで、地図コンテンツが、レンダリング対象外のビューの領域を透かして見えるようになる。
        self.opaque = NO;
        
        _walker = [CALayer layer];
        //  contentsScale = [UIScreen mainScreen].scale は特に必要ない contentsGravity = kCAGravityResizeなので
        _walker.frame = CGRectMake(0, 0, 48, 48);
        _walker.contents = (id)[[self class] imageWithNero:_standbyNero].CGImage;
        _walker.contentsRect = [(NSValue*)[[[self class] contentsRectArrayStandbyNero:_standbyNero] objectAtIndex:0] CGRectValue];
        _direction = -1;
        
        self.layer.cornerRadius = myFrame.size.width / 2;
        [self.layer addSublayer:_walker];
        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)tap
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KMTreasureHunterAnnotationViewTapNotification" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:_hunterAnnotation, @"annotation", nil]];
}

- (void)startAnimation
{
    CAKeyframeAnimation * walkAnimation =[CAKeyframeAnimation animationWithKeyPath:@"contentsRect"];
    walkAnimation.values = [[self class] contentsRectArrayStandbyNero:_standbyNero];
    walkAnimation.calculationMode = kCAAnimationDiscrete;
    
    walkAnimation.duration= 1;
    walkAnimation.repeatCount = HUGE_VALF;
    walkAnimation.removedOnCompletion = NO;
    [_walker addAnimation:walkAnimation forKey:@"walk"];
}

- (void)setSearcherHidden:(BOOL)hidden
{
    if (hidden) {
        [_searcher removeFromSuperlayer];
        return;
    }
    if (_searcher.superlayer) {
        return;
    }
    if (_searcher == nil) {
        _searcher = [CALayer layer];
        //  contentsScale = [UIScreen mainScreen].scale は特に必要ない contentsGravity = kCAGravityResizeなので
        _searcher.frame = CGRectInset(self.bounds, -20, -20);
        _searcher.contents = (id)[UIImage imageNamed:@"searcher"].CGImage;
    }
    [self.layer insertSublayer:_searcher below:_walker];

    CAKeyframeAnimation * searchAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSArray* keyAttributes = @[
                               [NSValue valueWithCATransform3D:CATransform3DIdentity],
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.14, 0, 0, 1) ],
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.14 * 2, 0, 0, 1)]
                               ];
    searchAnimation.values = keyAttributes;
    searchAnimation.duration= 3;
    searchAnimation.repeatCount = HUGE_VALF;
    searchAnimation.removedOnCompletion = NO;
    [_searcher addAnimation:searchAnimation forKey:@"searcher"];
}

- (void)setStandbyNero:(BOOL)standbyNero
{
    _standbyNero = standbyNero;
    _walker.contents = (id)[[self class] imageWithNero:_standbyNero].CGImage;
    _walker.contentsRect = [(NSValue*)[[[self class] contentsRectArrayStandbyNero:_standbyNero] objectAtIndex:0] CGRectValue];
    [self startAnimation];
}

- (id < CAAction >)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if ([key isEqualToString:@"position"]) {
        CABasicAnimation * animation =[CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration= 0.3;
        return animation;
    }
    return [super actionForLayer:layer forKey:key];
}

- (void)restoreAnimation
{
    CAAnimation * animation = [_searcher animationForKey:@"searcher"];
    [_searcher addAnimation:animation forKey:@"searcher"];
    animation = [_searcher animationForKey:@"walk"];
    [_searcher addAnimation:animation forKey:@"walk"];
}

- (void)searchAnimationOnView:(UIView*)view target:(id)target action:(SEL)action
{
    if (_searchAnimationView)
        return;
    [_searcher removeAnimationForKey:@"searcher"];
    _searcher.transform = CATransform3DMakeScale(0.1, 0.1, 1);
    _searchNotifierTarget = target;
    _searchNotifierAction = action;
    UIImage* image = [UIImage imageNamed:@"search"];
    UIImageView* v = [[UIImageView alloc] initWithImage:image];
    v.layer.anchorPoint = CGPointMake(0.0,1.0);
    CGRect frame = v.frame;
    float length = view.bounds.size.width;
    if (length < view.bounds.size.height)
        length = view.bounds.size.height;
    length /= 2;
    float scale = (length * 1.0) / frame.size.width;
    frame.size.width *= scale;
    frame.size.height *= scale;
    frame.origin.x = view.bounds.size.width / 2;
    frame.origin.y = view.bounds.size.height / 2 - frame.size.height;
    v.frame = frame;
    
    CAKeyframeAnimation * searchAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSArray* keyAttributes = @[
                               [NSValue valueWithCATransform3D:CATransform3DIdentity],
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.14 , 0, 0, 1)],
                               [NSValue valueWithCATransform3D:CATransform3DMakeRotation(3.14 * 2 , 0, 0, 1)]
                               ];
    searchAnimation.values = keyAttributes;
    searchAnimation.duration= 2;
    _searchAnimationView = v;
    
    UIImage* oraimage = [UIImage imageNamed:@"ora"];
    UIImageView* orav = [[UIImageView alloc] initWithImage:oraimage];
    orav.frame = CGRectMake(-40, view.bounds.size.height - 80, view.bounds.size.width, 80);
    CAKeyframeAnimation * oraAnimation =[CAKeyframeAnimation animationWithKeyPath:@"transform"];
    keyAttributes = @[
                      [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(orav.frame.size.width, 0, 1)],
                      [NSValue valueWithCATransform3D:CATransform3DIdentity]
                      ];
    oraAnimation.values = keyAttributes;
    oraAnimation.duration= 2;
    oraAnimation.delegate = self;
    _searchAnimationView2 = orav;

    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [view addSubview:v];
        [view addSubview:orav];
        [v.layer addAnimation:searchAnimation forKey:@"searcher"];
        [orav.layer addAnimation:oraAnimation forKey:@"ora"];
    });
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    _searcher.transform = CATransform3DIdentity;
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setSearcherHidden:YES];
        [self setSearcherHidden:NO];
    });
    [_searchAnimationView removeFromSuperview];
    _searchAnimationView = nil;
    [_searchAnimationView2 removeFromSuperview];
    _searchAnimationView2 = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_searchNotifierTarget performSelector:_searchNotifierAction withObject:self];
#pragma clang diagnostic pop
}
@end


@implementation KMTreasureHunterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.contents = (id)[KMTreasureHunterAnnotationView imageWithNero:NO].CGImage;
        self.layer.contentsRect = [(NSValue*)[[KMTreasureHunterAnnotationView contentsRectArrayStandbyNero:NO] objectAtIndex:0] CGRectValue];
        [self startAnimation];
    }
    return self;
}

- (void)startAnimation
{
    CAKeyframeAnimation * walkAnimation =[CAKeyframeAnimation animationWithKeyPath:@"contentsRect"];
    walkAnimation.values = [KMTreasureHunterAnnotationView contentsRectArrayWalkWithDirection:self.tag];
    walkAnimation.calculationMode = kCAAnimationDiscrete;    //  kCAAnimationLinear
    
    walkAnimation.duration= 1;
    walkAnimation.repeatCount = HUGE_VALF;
    walkAnimation.removedOnCompletion = NO;
    [self.layer addAnimation:walkAnimation forKey:@"walk"];
}
@end
