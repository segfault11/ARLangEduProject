//
//  SpriteManager.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface SpriteManager : NSObject
+ (SpriteManager*)instance;
- (Sprite*)getSpriteWithId:(int)id;
@end
