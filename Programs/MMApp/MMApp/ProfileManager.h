//
//  ProfileManager.h
//  GUIPrototype
//
//  Created by Arno in Wolde Lübke on 25.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileManager : NSObject
+ (ProfileManager*)instance;
- (void)addProfile:(NSString*)name;
- (NSUInteger)getNumberOfProfiles;
- (NSString*)getProfileAtIndex:(NSUInteger)index;
@end
