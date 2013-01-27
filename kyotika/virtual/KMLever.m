//
//  KMLever.m
//  prospector
//
//  Created by kunii on 2013/01/20.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMLever.h"

static const float PAI = 3.14159265358979;
const static float LeverImageSize = 44.0;

@implementation KMLever {
    CAGradientLayer* _leverImage;
    float            _radius;
    NSTimer*            _timer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //  画面中心を原点にする。
        CGSize size = self.bounds.size;
        _radius = (size.width > size.height) ? size.height : size.width;
        _radius /= 2.0;
        self.bounds = CGRectMake(-_radius, -_radius, _radius * 2.0, _radius * 2.0);
        
        //  可動範囲
        CALayer* ereaLayer = [CALayer layer];
        ereaLayer.backgroundColor = [UIColor grayColor].CGColor;
        ereaLayer.opacity = 0.5;
        ereaLayer.frame = self.bounds;
        ereaLayer.borderColor = [UIColor whiteColor].CGColor;
        ereaLayer.borderWidth = 2.0;
        ereaLayer.cornerRadius = ereaLayer.bounds.size.width / 2.0;
        [self.layer addSublayer:ereaLayer];
        
        //  レバー
        _leverImage = [CAGradientLayer layer];
        
        UIColor* normalTop = [UIColor colorWithHue:0.0
                                        saturation:0.0
                                        brightness:0.5
                                             alpha:1];
        UIColor* normalBottom = [UIColor colorWithHue:0.0
                                           saturation:0.0
                                           brightness:0.2
                                                alpha:1];
        NSArray *colors = [NSArray arrayWithObjects:
                           (__bridge id)normalTop.CGColor,
                           (__bridge id)normalBottom.CGColor, nil];
        _leverImage.colors = colors;
        
        
        _leverImage.bounds = CGRectMake(-LeverImageSize/2.0, -LeverImageSize/2.0, LeverImageSize, LeverImageSize);
        _leverImage.backgroundColor = [UIColor grayColor].CGColor;
        _leverImage.borderColor = [UIColor lightGrayColor].CGColor;
        _leverImage.borderWidth = 4;
        _leverImage.cornerRadius = _leverImage.bounds.size.width / 2.0;
        _leverImage.shadowOpacity = 1.0;
        _leverImage.shadowOffset = CGSizeMake(0, 2);
        [self.layer addSublayer:_leverImage];
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateMove) userInfo:nil repeats:YES];
    [self sendActionsForControlEvents:UIControlEventTouchDragEnter];
    return [self continueTrackingWithTouch:touch withEvent:event];
}

- (void)updateMove
{
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
   [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint pt = [touch locationInView:self];
    float length = sqrt(pt.x * pt.x + pt.y * pt.y);
    if (length > _radius) {
        pt.x *= _radius / length;
        pt.y *= _radius / length;
        length = _radius;
    }
    BOOL changed = NO;
    if (length == 0.0) {
        changed = ((_vector.x != 0) || (_vector.y != 0));
        _vector = CGPointZero;
        _value = 0.0;
    } else {    
        CGPoint vector = CGPointMake(pt.x / _radius, pt.y / _radius);
        changed = ((_vector.x != vector.x) || (_vector.y != vector.y));
        _vector = vector;
        
        const CGPoint referenceVector = {1.0, 0.0}; //  右方向
        float dat = _vector.x * referenceVector.x + _vector.y * referenceVector.y; //  内積
        float cross = _vector.x * referenceVector.y - _vector.y * referenceVector.x;  //  外積
        float rotation = acos(dat);
        if (cross > 0)     //  正の方向
            rotation = 2 * PAI - rotation;
        if (_rotation != rotation) {
            changed = YES;
            _rotation = rotation;
        }    
        float value = length / _radius;
        if (_value != value) {
            changed = YES;
            _value = value;
        }
    }
    _leverImage.position = pt;
    if (changed)
        [self sendActionsForControlEvents:UIControlEventValueChanged];    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:UIControlEventTouchDragExit];
    [_timer invalidate];
    _timer = nil;
    [super endTrackingWithTouch:touch withEvent:event];
    _leverImage.position = CGPointZero;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:UIControlEventTouchDragExit];
    [_timer invalidate];
    _timer = nil;
    [super cancelTrackingWithEvent:event];
    _leverImage.position = CGPointZero;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
