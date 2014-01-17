//------------------------------------------------------------------------------
//
//  SpriteManager.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "SpriteManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
static const char* FILE_NAME = "/Sprites.json";
//------------------------------------------------------------------------------
@interface SpriteManager ()
@property (nonatomic, strong) NSMutableDictionary* sprites;
- (id)init;
- (void)loadSprites;
@end
//------------------------------------------------------------------------------
@implementation SpriteManager
//------------------------------------------------------------------------------
+ (SpriteManager*)instance
{
    static SpriteManager* instance = NULL;
    
    @synchronized(self)
    {
        if (instance == NULL)
            instance = [[self alloc] init];
    }

    return instance;
}
//------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    [self loadSprites];
    return self;
}
//------------------------------------------------------------------------------
- (void)loadSprites
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
        NSLog(@"Invalid file [Sprites.json]");
        exit(0);
    }
    
    self.sprites = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* entry in a)
    {
        Sprite* s = [[Sprite alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        n = [entry objectForKey:@"spriteSheet"];
        s.spriteSheet = [n integerValue];

        n = [entry objectForKey:@"frame"];
        s.frame = [n integerValue];
        
        n = [entry objectForKey:@"animation"];
        s.animation = [n integerValue];
        
        n = [entry objectForKey:@"size"];
        s.size = [n floatValue];
        
        NSArray* arr = [entry objectForKey:@"translation"];
        Vec3 t;
        t.x = [[arr objectAtIndex:0] floatValue];
        t.y = [[arr objectAtIndex:1] floatValue];
        t.z = [[arr objectAtIndex:2] floatValue];
        s.translation = t;

        arr = [entry objectForKey:@"rotation"];
        Vec3 rot;
        rot.x = [[arr objectAtIndex:0] floatValue];
        rot.y = [[arr objectAtIndex:1] floatValue];
        rot.z = [[arr objectAtIndex:2] floatValue];
        s.rotation = rot;


        
        [self.sprites setObject:s forKey:[NSNumber numberWithInt:s.id]];
    } 
    
}
//------------------------------------------------------------------------------
- (Sprite*)getSpriteWithId:(int)id
{
    return [self.sprites objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
