//
//  ProfileManager.m
//  GUIPrototype
//
//  Created by Arno in Wolde Lübke on 25.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ProfileManager.h"

@interface ProfileManager ()
@property(strong, nonatomic) NSMutableArray* profiles;
- (id)init;
@end

@implementation ProfileManager

- (id)init
{
    self = [super init];
    
    self.profiles = [[NSMutableArray alloc] init];
    
    return self;
}

+ (ProfileManager*)instance
{
    static ProfileManager* instance = NULL;
    
    @synchronized(self)
    {
        if (instance == NULL)
            instance = [[self alloc] init];
    }

    return instance;
}

- (void)addProfile:(NSString*)name
{
    [self.profiles addObject:name];
}

- (NSString*)getProfileAtIndex:(NSUInteger)index
{
    if (index >= self.profiles.count)
    {
        return nil;
    }

    return (NSString*)[self.profiles objectAtIndex:index];
}

- (NSUInteger)getNumberOfProfiles
{
    return self.profiles.count;
}

@end
