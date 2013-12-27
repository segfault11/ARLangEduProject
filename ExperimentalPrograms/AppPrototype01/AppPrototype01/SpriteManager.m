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
@property (nonatomic, strong) NSMutableArray* sprites;
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
        NSLog(@"Invalid sprite data");
        exit(0);
    }
    
    self.sprites = [[NSMutableArray alloc] init];
    
    for (NSDictionary* entry in a)
    {
        Sprite* s = [[Sprite alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        n = [entry objectForKey:@"spriteSheet"];
        s.spriteSheet = [n integerValue];

        n = [entry objectForKey:@"frame"];
        s.frame = [n integerValue];

    }
    
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
