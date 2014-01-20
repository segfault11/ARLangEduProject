//
//  SpriteSheetManager.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 27.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteSheet.h"

@interface SpriteSheetManager : NSObject
+ (SpriteSheetManager*)instance;
- (SpriteSheet*)getSpriteSheetWithId:(int)id;
- (SpriteSheet*)getSpriteSheetAtIndex:(int)idx;
- (NSUInteger)getNumSpriteSheets;
@end
