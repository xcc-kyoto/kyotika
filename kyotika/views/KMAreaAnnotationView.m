//
//  KMAreaAnnotationView.m
//  kyotika
//
//  Created by kunii on 2013/02/02.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMAreaAnnotationView.h"

@implementation KMAreaAnnotationView

- (UIImage*)image
{
    static UIImage* image;
    if (image == nil)
        image = [UIImage imageNamed:@"ggg"];
    return image;
}

- (NSArray*)contentsRectArray
{
    static NSArray* array = nil;
    if (array == nil) {
        NSMutableArray* tmparray = [NSMutableArray arrayWithCapacity:4];
        CGRect r = {0,0,0.5,1.0};
        for (int i = 0; i < 2; i++) {
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
        CGRect bounds = CGRectMake(0, 0, 24, 24);
        self.bounds = bounds;
        // 不透過プロパティをNOに設定することで、地図コンテンツが、レンダリング対象外のビューの領域を透かして見えるようになる。
        self.opaque = NO;
        
        CALayer* _blinker = [CALayer layer];
        _blinker.opacity = 0.5;
        [self.layer addSublayer:_blinker];
        _blinker.frame = CGRectMake(0, 0, 24, 24);
        _blinker.contents = (id)self.image.CGImage;
        _blinker.contentsRect = [(NSValue*)[self.contentsRectArray objectAtIndex:0] CGRectValue];
        _blinker.contentsGravity = kCAGravityResizeAspect;
        
        CAKeyframeAnimation * animation =[CAKeyframeAnimation animationWithKeyPath:@"contentsRect"];
        animation.values = self.contentsRectArray;
        animation.calculationMode = kCAAnimationDiscrete;
        animation.duration= 0.3;
        animation.removedOnCompletion = YES;
        animation.repeatCount = HUGE_VALF;
        [_blinker addAnimation:animation forKey:@"ggg"];
        
    }
    return self;
}
@end
