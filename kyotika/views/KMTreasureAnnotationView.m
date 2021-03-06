//
//  KMTreasureAnnotationView.m
//  KyotoMap
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "KMTreasureAnnotationView.h"
#import "KMTreasureAnnotation.h"

@interface KMTreasureAnnotationView() {
    CALayer* _blinker;
    CALayer*    _locker;
}
@end

@implementation KMTreasureAnnotationView

- (UIImage*)imageLock
{
    static UIImage* image;
    if (image == nil)
        image = [UIImage imageNamed:@"lock"];
    return image;
}

- (UIImage*)imageShine
{
    static UIImage* imageShine;
    if (imageShine == nil)
        imageShine = [UIImage imageNamed:@"shines"];
    return imageShine;
}

- (UIImage*)imageBox
{
    static UIImage* imageBox;
    if (imageBox == nil)
        imageBox = [UIImage imageNamed:@"Landmark"];
    return imageBox;
}

- (UIImage*)imageTargetBox
{
    static UIImage* imageBox;
    if (imageBox == nil)
        imageBox = [UIImage imageNamed:@"Landmark-target"];
    return imageBox;
}

- (UIImage*)imageTargetPassedBox
{
    static UIImage* imageBox;
    if (imageBox == nil)
        imageBox = [UIImage imageNamed:@"Landmark-target-passed"];
    return imageBox;
}

- (NSArray*)contentsRectArray
{
    static NSArray* array = nil;
    if (array == nil) {
        NSMutableArray* tmparray = [NSMutableArray arrayWithCapacity:4];
        CGRect r = {0,0,0.20,1.0};
        for (int i = 0; i < 5; i++) {
            [tmparray addObject:[NSValue valueWithCGRect:r]];
            r.origin.x += r.size.width;
        }
        array = tmparray;
    }
    return array;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        // フレームサイズを適切な値に設定する
        CGRect myFrame = self.frame;
        myFrame.size.width = 40;
        myFrame.size.height = 40;
        self.frame = myFrame;
        // 不透過プロパティをNOに設定することで、地図コンテンツが、レンダリング対象外のビューの領域を透かして見えるようになる。
        self.opaque = NO;        
        UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)tap
{
    KMTreasureAnnotation* a = self.annotation;
    [a notificationHitIfNeed];
}

- (void)startAnimation
{
    KMTreasureAnnotation* a = self.annotation;
    if (a.passed && !a.target) {
        [_locker removeFromSuperlayer];
        _locker = nil;
        [_blinker removeFromSuperlayer];
        _blinker = nil;
        self.image = self.imageBox;
        return;
    }
    if (_blinker == nil) {
        _blinker = [CALayer layer];
        _blinker.contentsScale = [UIScreen mainScreen].scale;
        [self.layer addSublayer:_blinker];
    }
    [CATransaction begin];
    self.image = nil;
    _blinker.frame = self.bounds;
    _blinker.transform = CATransform3DIdentity;
    _blinker.contentsGravity = kCAGravityCenter;
    if (a.target) {
        UIImage* image = a.passed ? self.imageTargetPassedBox : self.imageTargetBox;
        _blinker.contents = (id)image.CGImage;
        _blinker.contentsRect = CGRectMake(0,0,1,1);
                
        CABasicAnimation* animation = [CABasicAnimation animation];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)];
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        animation.duration = 1;
        animation.removedOnCompletion = NO;
        animation.autoreverses = YES;
        animation.repeatCount = HUGE_VALF;
        [_blinker removeAnimationForKey:@"shine"];
        [_blinker addAnimation:animation forKey:@"transform"];
    } else {
        _blinker.contents = (id)self.imageShine.CGImage;
        _blinker.contentsRect = [(NSValue*)[self.contentsRectArray objectAtIndex:0] CGRectValue];
        
        CAKeyframeAnimation * animation =[CAKeyframeAnimation animationWithKeyPath:@"contentsRect"];
        animation.values = self.contentsRectArray;
        animation.calculationMode = kCAAnimationDiscrete;
        animation.duration= 1;
        animation.removedOnCompletion = NO;
        animation.repeatCount = HUGE_VALF;
        [_blinker removeAnimationForKey:@"transform"];
        [_blinker addAnimation:animation forKey:@"shine"];
    }
    if (a.locking) {
        if (_locker == nil) {
            _locker = [CALayer layer];
            _locker.contentsScale = [UIScreen mainScreen].scale;
            _locker.frame = self.layer.bounds;
            _locker.contents = (id)self.imageLock.CGImage;
            _locker.contentsGravity = kCAGravityCenter;
            [self.layer addSublayer:_locker];
        }
    } else {
        [_locker removeFromSuperlayer];
        _locker = nil;        
    }
    [CATransaction commit];
}

- (void)restoreAnimation
{
    CAAnimation * animation = [_blinker animationForKey:@"shine"];
    if (animation == nil) {
        animation = [_blinker animationForKey:@"transform"];
        [_blinker addAnimation:animation forKey:@"transform"];
    } else {
        [_blinker addAnimation:animation forKey:@"shine"];
    }
}

@end

