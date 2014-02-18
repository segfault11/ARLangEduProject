//------------------------------------------------------------------------------
//
//  ContentManager.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ContentManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
static const char* FILE_NAME = "/Contents.json";
//------------------------------------------------------------------------------
@interface ContentManager ()
@property (nonatomic, strong) NSMutableDictionary* contents;
- (id)init;
- (void)loadContents;
@end
//------------------------------------------------------------------------------
@implementation ContentManager
//------------------------------------------------------------------------------
+ (ContentManager*)instance
{
    static ContentManager* instance = nil;

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
    [self loadContents];
    return self;
}
//------------------------------------------------------------------------------
- (Content*)getContentWithId:(int)id
{
    return [self.contents objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
- (Content*)getContentAtIndex:(int)idx
{
    NSArray* keys = self.contents.allKeys;
 
    if (idx >= keys.count)
    {
        return nil;
    }
    
    NSNumber* id = [keys objectAtIndex:idx];
    
    return [self.contents objectForKey:id];
}
//------------------------------------------------------------------------------
- (int)getNumContents
{
    return self.contents.allKeys.count;
}
//------------------------------------------------------------------------------
- (void)loadContents
{
    NSString* filename = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingString:[NSString stringWithUTF8String:FILE_NAME]];

    NSData* d = [[NSData alloc] initWithContentsOfFile:filename];
    
    if (!d)
    {
        NSLog(@"Could not load content");
        exit(0);
    }
    
    NSArray* a = [d objectFromJSONData];
    
    if (!a)
    {
        NSLog(@"Invalid file [Contents.json]");
        exit(0);
    }

    self.contents = [[NSMutableDictionary alloc] init];

    for (NSDictionary* entry in a)
    {
        Content* s = [[Content alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        NSArray* arr = [entry objectForKey:@"sentences"];
        s.sentences = arr;
        
        NSString* str = [entry objectForKey:@"sound"];
        s.sound = str;
        
        str = [entry objectForKey:@"word"];
        s.word = str;
        
        str = [entry objectForKey:@"bgImage"];
        s.bgImage = str;
        
        if (arr.count > 0)
        {
            s.activeSentence = 0;
        }
        else
        {
            s.activeSentence = -1;
        }
        
        str = [entry objectForKey:@"translation"];
        s.translation = str;
        s.isTranslationDisplayed = NO;
        
        [self.contents setObject:s forKey:[NSNumber numberWithInt:s.id]];
    }
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------