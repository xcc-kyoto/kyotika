//
//  KMFirstViewController.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMLandmarkListController.h"

@interface KMLandmarkListController ()

@end

@implementation KMLandmarkListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"landmarkList", @"landmark list");
        self.tabBarItem.image = [UIImage imageNamed:@"landmarkList"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    CGRect frame = self.view.bounds;
    frame.size.height = 20;
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithHue:0.6 saturation:0.1 brightness:0.95 alpha:1];
    frame = view.bounds;
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 2;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"項目をタップすると地図で場所が表示されます";
    [view addSubview:label];
    self.tableView.tableHeaderView = view;
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_landmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    id obj = [_landmarks objectAtIndex:indexPath.row];
    NSString* title = [_landmarksDelegate landmarkListControllerLandmark:self fromObject:obj];
    if (title)
        cell.textLabel.text = title;
    else
        cell.textLabel.text = @"？";
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [_landmarks objectAtIndex:indexPath.row];
    [_landmarksDelegate landmarkListControllerShowLocation:self object:obj];
}


@end
