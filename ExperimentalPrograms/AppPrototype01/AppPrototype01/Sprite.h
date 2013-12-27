//
//  Sprite.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sprite : NSObject
{
    int _id;
    int _spriteSheet;
    int _frame;
    int _animation;
}
@property int id, spriteSheet, frame, animation;
@end
