//
//  KMAppDelegate.h
//  kyotika
//
//  Created by kunii on 2013/01/27.
//  Copyright (c) 2013年 國居貴浩. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
