//
//  Converter.h
//  Vaults
//
//  Created by Yasuhiro Usutani on 2/1/13.
//  Copyright (c) 2013 Yasuhiro Usutani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Converter : NSObject

+ (void)createSeeds:(NSManagedObjectContext *)moc;
+ (void)displayInRegion:(NSManagedObjectContext *)moc;

@end
