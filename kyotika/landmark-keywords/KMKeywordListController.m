//
//  KMSecondViewController.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMKeywordListController.h"
#import "KMLandmarkListController.h"

@interface KMKeywordListController () {
    KMLandmarkListController *viewController1;
    int _index;
}

@end

@implementation KMKeywordListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Keywords", @"Keywords");
        self.tabBarItem.image = [UIImage imageNamed:@"keywordList"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_keywords count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    id obj = [_keywords objectAtIndex:indexPath.row];
    cell.textLabel.text = [_keywordsDelegate keywordListControllerKeyword:self fromObject:obj];
    
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _index = indexPath.row;
    id obj = [_keywords objectAtIndex:indexPath.row];
    viewController1 = [[KMLandmarkListController alloc] initWithStyle:UITableViewStylePlain];
    viewController1.landmarks = [_keywordsDelegate keywordListControllerLandmarks:self fromObject:obj];
    viewController1.landmarksDelegate = _keywordsDelegate;
    viewController1.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Show in map" style:
                                                         UIBarButtonItemStyleBordered target:self action:@selector(showMap)];
    
    viewController1.title = [_keywordsDelegate keywordListControllerKeyword:self fromObject:obj];
    [self.navigationController pushViewController:viewController1 animated:YES];
}

- (void)showMap
{
    id obj = [_keywords objectAtIndex:_index];
    [_keywordsDelegate keywordListControllerShowLocation:self object:obj];
}
@end
