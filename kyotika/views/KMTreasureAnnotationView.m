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
}
@end

@implementation KMTreasureAnnotationView

- (UIImage*)imageShine
{
    static UIImage* imageShine;
    if (imageShine == nil)
        imageShine = [UIImage imageNamed:@"Shine1"];
    return imageShine;
}

- (UIImage*)imageBox
{
    static UIImage* imageBox;
    if (imageBox == nil)
        imageBox = [UIImage imageNamed:@"120815c"];
    return imageBox;
}


- (void)enterNotification
{
    _blinker.contents = (id)self.imageBox.CGImage;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KMTreasureAnnotationViewTapNotification" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.annotation, @"annotation", nil]];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    KMTreasureAnnotation* a = self.annotation;
    if (a.find == NO)
        return;
    [self enterNotification];
}

- (BOOL)enter:(CLLocationCoordinate2D)location
{
    KMTreasureAnnotation* an = self.annotation;
    if (an.passed)
        return NO;
    if (an.lastAtackDate && [[NSDate date] timeIntervalSinceDate:an.lastAtackDate] < 20)
        return NO;
    
    CLLocationCoordinate2D a = self.annotation.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(a, 50.0, 50.0);
    float peekminlatitude = region.center.latitude - region.span.latitudeDelta;
    float peekmaxlatitude = region.center.latitude + region.span.latitudeDelta;
    float peekminlongitude = region.center.longitude - region.span.longitudeDelta;
    float peekmaxlongitude = region.center.longitude + region.span.longitudeDelta;
    if (location.longitude < peekminlongitude) return NO;
    if (location.longitude > peekmaxlongitude) return NO;
    if (location.latitude < peekminlatitude) return NO;
    if (location.latitude > peekmaxlatitude) return NO;
    
    an.lastAtackDate = [NSDate date];
    return YES;
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
        
        _blinker = [CALayer layer];
        _blinker.shadowOpacity = 1.0;
        _blinker.frame = CGRectMake(0, 0, 64, 64);
        UIImage* image = nil;
        KMTreasureAnnotation* a = self.annotation;
        if (a.passed)
            image = self.imageBox;
        else
            image = self.imageShine;
        _blinker.contents = (id)image.CGImage;
        [self.layer addSublayer:_blinker];
        
    }
    return self;
}


- (void)startAnimation
{
    [_blinker removeAnimationForKey:@"transform"];
    
    KMTreasureAnnotation* a = self.annotation;
    if (a.passed)
        return;
    if (a.find == NO)
        return;
    _blinker.contents = (id)self.imageShine.CGImage;
    
    [self.layer removeAnimationForKey:@"transform"];
    CABasicAnimation* animation = [CABasicAnimation animation];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 1.0)];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    animation.duration = 1;
    animation.removedOnCompletion = YES;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    //    animation.fillMode = kCAFillModeBoth;
    [_blinker removeAnimationForKey:@"transform"];
    [_blinker addAnimation:animation forKey:@"transform"];
}
- (void)stopAnimation
{
    [_blinker removeAnimationForKey:@"transform"];
}
@end

