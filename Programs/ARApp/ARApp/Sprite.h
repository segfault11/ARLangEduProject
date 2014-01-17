//
//  Sprite.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct
{
    float x, y, z;
}
Vec3;

@interface Sprite : NSObject
{
    int _id;
    int _spriteSheet;
    int _frame;
    int _animation;
    float _size;
    Vec3 _translation;
    Vec3 _rotation;
}
@property int id, spriteSheet, frame, animation;
@property float size;
@property Vec3 translation;
@property Vec3 rotation;
@end
