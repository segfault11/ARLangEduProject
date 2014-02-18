//
//  ProfileManager.h
//  RecogGame
//
//  Created by Marc Ericson Santos on 2/7/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@interface ProfileManager : NSObject
+(ProfileManager*)instance;
-(void)addProfileWithFirstName:(NSString*)firstName andLastName:(NSString*)lastName;
-(Profile*)getProfileAtIndex:(int)index;
-(int)getProfilesCount;
@end
