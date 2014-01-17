//
//  ContentManager.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Content.h"

@interface ContentManager : NSObject
+ (ContentManager*)instance;
- (Content*)getContentWithId:(int)id;
- (Content*)getContentAtIndex:(int)idx;
- (int)getNumContents;
@end
