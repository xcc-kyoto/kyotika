//
//  KMAppDelegate.m
//  vaults
//
//  Created by kunii on 2013/01/22.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import "KMAppDelegate.h"
#import "KMVaultViewController.h"
#import "KMLandmarkViewController.h"
#import "KMLandmarkListController.h"

@interface KMAppDelegate()<KMVaultViewControllerDelegate, KMLandmarkViewControllerDelegate>
@end
@implementation KMAppDelegate {
    NSMutableArray* _landmarks;
    NSMutableArray* _keywords;
}

-(void)vaultViewControllerDone:(KMVaultViewController*)viewController
{
    printf("done 1\n");
}
-(void)landmarkViewControllerDone:(KMLandmarkViewController*)viewController
{
    printf("done 2\n");
}

- (void)keywordListControllerShowLocation:(KMKeywordListController*)controller object:(id)object
{
    printf("show key %s all locations\n", [[object valueForKey:@"title"] UTF8String]);
}

- (NSString*)keywordListControllerKeyword:(KMKeywordListController*)ViewController fromObject:(id)object
{
    return [object valueForKey:@"title"];
}

- (NSArray*)keywordListControllerLandmarks:(KMKeywordListController*)ViewController fromObject:(id)object
{
    return [object valueForKey:@"landmark"];
}

- (void)landmarkListControllerShowLocation:(KMLandmarkListController*)controller object:(id)object
{
    printf("show landmark %s\n", [[object valueForKey:@"title"] UTF8String]);
}

- (NSString*)landmarkListControllerLandmark:(KMLandmarkListController*)controller fromObject:(id)object
{
    return [object valueForKey:@"title"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _landmarks = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"Landmark-%d", i], @"title",
                             nil];
        [_landmarks addObject:dic];
    }
    _keywords = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        int max = rand() % 8;
        NSMutableArray* lands = [NSMutableArray arrayWithCapacity:max];
        for (int i = 0; i < max; i++) {
            int index = rand() % [_landmarks count];
            [lands addObject:[_landmarks objectAtIndex:index]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"keyword-%d", i], @"title",
                             lands, @"landmark",
                             nil];
        [_keywords addObject:dic];
    }
    
#if 1
    KMLandmarkViewController* viewController = [[KMLandmarkViewController alloc] init];
    viewController.urlString = @"http://ameblo.jp/xcc/";
    viewController.keywords = _keywords;
    viewController.landmarkDelegate = self;
#else
    KMVaultViewController* viewController = [[KMVaultViewController alloc] init];
    viewController.keywords = _keywords;
    viewController.landmarks = _landmarks;
    viewController.vaultsDelegate = self;
#endif
    self.tabBarController = viewController;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
