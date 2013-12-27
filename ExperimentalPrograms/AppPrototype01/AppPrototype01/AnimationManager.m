//------------------------------------------------------------------------------
//
//  AnimationManager.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 27.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "AnimationManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
static const char* FILE_NAME = "/Animations.json";
//------------------------------------------------------------------------------
@interface AnimationManager ()
@property (nonatomic, strong) NSMutableDictionary* animations;
- (id)init;
- (void)loadAnimations;
@end
//------------------------------------------------------------------------------
@implementation AnimationManager
//------------------------------------------------------------------------------
+  (AnimationManager*)instance
{
    static AnimationManager* instance = nil;

    @synchronized(self)
    {
        if (instance == NULL)
        {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    [self loadAnimations];
    return self;
}
//------------------------------------------------------------------------------
- (void)loadAnimations
{
   NSString* filename = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingString:[NSString stringWithUTF8String:FILE_NAME]];

    NSData* d = [[NSData alloc] initWithContentsOfFile:filename];
    
    if (!d)
    {
        NSLog(@"Could not load sprites");
        exit(0);
    }
    
    NSArray* a = [d objectFromJSONData];
    
    if (!a)
    {
        NSLog(@"Invalid sprite data");
        exit(0);
    }

    self.animations = [[NSMutableDictionary alloc] init];

    for (NSDictionary* entry in a)
    {
        Animation* s = [[Animation alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        n = [entry objectForKey:@"duration"];
        s.duration = [n integerValue];
        
        [self.animations setObject:s forKey:[NSNumber numberWithInt:s.id]];
    }
}
//------------------------------------------------------------------------------
- (Animation*)getAnimationWithId:(int)id
{
    return [self.animations objectForKey:[NSNumber numberWithInt:id]];
}
@end
//------------------------------------------------------------------------------
