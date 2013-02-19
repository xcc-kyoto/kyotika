//
//  KMViewController.m
//  event
//
//  Created by kunii on 2013/02/05.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMViewController.h"
#import "KMEventViewController.h"

@interface KMViewController ()

@end

@implementation KMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidAppear:(BOOL)animated
{
    static float complete = 0.2;
    [super viewDidAppear:animated];
    if (complete > 1.0)
        return;

    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        KMEventViewController* eventViewController = [[KMEventViewController alloc] init];
        eventViewController.complete = complete;
        complete += 0.2;
        eventViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:eventViewController animated:YES];
    });
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
