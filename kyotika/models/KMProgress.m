//
//  KMProgress.m
//  kyotika
//
//  Created by Yasuhiro Usutani on 2/27/13.
//  Copyright (c) 2013 ÂúãÂ±ÖË≤¥Êµ©. All rights reserved.
//

#import "KMProgress.h"

@implementation KMProgress

- (id)initWithUserDefaults
{
    _complete = [[NSUserDefaults standardUserDefaults] floatForKey:@"complete"];
    return self;
}
@end
