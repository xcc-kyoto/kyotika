//
//  main.m
//  Vaults
//
//  Created by Yasuhiro Usutani on 2/26/13.
//  Copyright (c) 2013 國居貴浩. All rights reserved.
//
#import "Converter.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"Vaults";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSURL *storeURL()
{
    NSString *path = [[NSProcessInfo processInfo] arguments][0];
    path = [path stringByDeletingPathExtension];
    return [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
}

static void deleteStoredFile()
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[storeURL() path]]) {
        NSError *error = nil;
        [fileManager removeItemAtURL:storeURL() error:&error];
        if (error) {
            NSLog(@"Delete failed: %@", error);
        }
    }
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:storeURL() options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        deleteStoredFile();
        
        NSManagedObjectContext *context = managedObjectContext();
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
        
        [Converter createSeeds:context];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:[storeURL() path]]) {
            NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/Vaults.sqlite"];
            NSURL *dstURL = [NSURL fileURLWithPath:path];
            [fileManager moveItemAtURL:storeURL() toURL:dstURL error:&error];
            if (error) {
                NSLog(@"Copy failed: %@", error);
            }
        }
    }
    return 0;
}

