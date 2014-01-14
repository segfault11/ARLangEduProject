//------------------------------------------------------------------------------
//
//  MarkerManager.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "MarkerManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
static const char* FILE_NAME = "/Marker.json";
//------------------------------------------------------------------------------
@interface MarkerManager ()
@property (nonatomic, strong) NSMutableDictionary* marker;
@property (nonatomic, strong) NSArray* keyArray;
- (id)init;
- (void)loadMarker;
@end
//------------------------------------------------------------------------------
@implementation MarkerManager
//------------------------------------------------------------------------------
+ (MarkerManager*)instance
{
    static MarkerManager* instance = nil;

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
    self = [super self];
    [self loadMarker];
    return self;
}
//------------------------------------------------------------------------------
- (void)loadMarker
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
        NSLog(@"Invalid file [Markers.json]");
        exit(0);
    }

    self.marker = [[NSMutableDictionary alloc] init];

    for (NSDictionary* entry in a)
    {
        Marker* s = [[Marker alloc] init];

        NSNumber* n = [entry objectForKey:@"id"];
        s.id = [n integerValue];
        
        n = [entry objectForKey:@"content"];
        s.content = [n integerValue];

        n = [entry objectForKey:@"size"];
        s.size = [n floatValue];
        

        NSString* str = [entry objectForKey:@"filename"];
        s.filename = str;

        str = [entry objectForKey:@"suffix"];
        s.suffix = str;
        
        [self.marker setObject:s forKey:[NSNumber numberWithInt:s.id]];
    }
    
    self.keyArray = self.marker.allKeys;
}
//------------------------------------------------------------------------------
- (Marker*)getMarkerForId:(int)id
{
    return [self.marker objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
- (NSUInteger)getNumMarker
{
    return self.keyArray.count;
}
//------------------------------------------------------------------------------
- (Marker*)getMarkerAtIndex:(int)idx
{
    if (idx >= self.keyArray.count)
    {
        return nil;
    }
    
    return [self.marker objectForKey:[self.keyArray objectAtIndex:idx]];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------