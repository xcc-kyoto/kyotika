//
//  KMEventViewController.m
//  kyotika
//
//  Created by kunii on 2013/02/03.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMEventViewController.h"

@interface KMEventViewController ()
@property (assign) IBOutlet UITextView* textView;
@end

@implementation KMEventViewController

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
    if (_complite == 1.0) {
        _textView.text = @"パ、パトラッシュ";
    } else {
        _textView.text = @"な、なんだか思い出せそうだワン";
    }
}

- (IBAction)tap
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
