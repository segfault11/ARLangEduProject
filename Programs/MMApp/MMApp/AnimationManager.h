//
//  AnimationManager.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 27.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animation.h"

@interface AnimationManager : NSObject
+ (AnimationManager*)instance;
- (Animation*)getAnimationWithId:(int)id;
@end
