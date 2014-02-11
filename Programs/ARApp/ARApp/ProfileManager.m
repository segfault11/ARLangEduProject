//
//  ProfileManager.m
//  RecogGame
//
//  Created by Marc Ericson Santos on 2/7/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#import "ProfileManager.h"
#import <stdio.h>

#define FILE_NAME "profiles.dat"

@interface ProfileManager ()
- (id)init;
- (void)dealloc;
- (void)saveProfiles;
- (void)loadProfiles;
@property (strong, nonatomic) NSMutableArray* profiles;

@end

@implementation ProfileManager

- (void)saveProfiles
{
    NSArray* documentDirectoryList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    const char* path = [[documentDirectoryList objectAtIndex:0] UTF8String];
    
    char fileName[1024];
    sprintf(fileName, "%s/%s", path, FILE_NAME);
    
    FILE* file = fopen(fileName, "w");
    
    for (Profile* profile in self.profiles)
    {
        fprintf(file, "%s %s\n", [profile.firstName UTF8String], [profile.lastName UTF8String]);
    }
    
    fclose(file);
}

- (void)loadProfiles
{
    NSArray* documentDirectoryList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    const char* path = [[documentDirectoryList objectAtIndex:0] UTF8String];
    
    char fileName[1024];
    sprintf(fileName, "%s/%s", path, FILE_NAME);
    
    FILE* file = fopen(fileName, "r");
    char firstName[1024];
    char lastName[1024];
    
    if (!file)
    {
        return;
    }
    
    while (EOF != fscanf(file, "%s %s\n", firstName, lastName))
    {
        Profile* profile = [[Profile alloc] init];
        profile.firstName = [NSString stringWithUTF8String:firstName];
        profile.lastName = [NSString stringWithUTF8String:lastName];
        [self.profiles addObject:profile];
    }
    
    fclose(file);
}

-(id)init
{
    self = [super init];
    self.profiles = [[NSMutableArray alloc] init];
    [self loadProfiles];
    return self;
}

-(void)dealloc
{
    
}

+(ProfileManager*)instance
{
    static ProfileManager* instance = nil;
    
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

-(void)addProfileWithFirstName:(NSString*)firstName andLastName:(NSString*)lastName
{
    Profile* profile = [[Profile alloc] init];
    profile.firstName = firstName;
    profile.lastName = lastName;
    [self.profiles addObject:profile];
    [self saveProfiles];    
}

-(Profile*)getProfileAtIndex:(int)index
{
    return [self.profiles objectAtIndex:index];
}

-(int)getProfilesCount
{
    return self.profiles.count;
}

@end
