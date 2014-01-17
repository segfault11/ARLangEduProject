//------------------------------------------------------------------------------
//
//  SpriteSheetManager.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 27.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "SpriteSheetManager.h"
#import "SpriteSheet.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
static const char* FILE_NAME = "/SpriteSheets.json";
//------------------------------------------------------------------------------
@interface SpriteSheetManager ()
@property (strong, nonatomic) NSMutableDictionary* spriteSheets;
@property (strong, nonatomic) NSArray* keyArray;
- (id)init;
- (void)loadSpriteSheets;
@end
//------------------------------------------------------------------------------
@implementation SpriteSheetManager
//------------------------------------------------------------------------------
+ (SpriteSheetManager*)instance
{
    static SpriteSheetManager* instance = nil;
    
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
    [self loadSpriteSheets];
    return self;
}
//------------------------------------------------------------------------------
- (void)loadSpriteSheets
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
        NSLog(@"Invalid file [SpriteSheets.json]");
        exit(0);
    }
    
    self.spriteSheets = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* entry in a)
    {
        SpriteSheet* s = [[SpriteSheet alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        NSString* str = [entry objectForKey:@"fileName"];
        s.fileName = str;

        n = [entry objectForKey:@"numFrames"];
        s.numFrames = [n integerValue];
        
        [self.spriteSheets setObject:s forKey:[NSNumber numberWithInt:s.id]];
    }
    
    self.keyArray = self.spriteSheets.allKeys;
}
//------------------------------------------------------------------------------
- (NSUInteger)getNumSpriteSheets
{
    return self.spriteSheets.count;
}
//------------------------------------------------------------------------------
- (SpriteSheet*)getSpriteSheetWithId:(int)id
{
    return [self.spriteSheets objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
- (SpriteSheet*)getSpriteSheetAtIndex:(int)idx
{
    if (idx >= self.keyArray.count)
    {
        return nil;
    }
    
    return [self.spriteSheets objectForKey:[self.keyArray objectAtIndex:idx]];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------