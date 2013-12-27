//
//  SpriteRenderer.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

typedef struct
{
    float scale;
    float aspect;
}
Sprite;

@interface SpriteRenderer : NSObject
- (id)init;
- (void)render;
@end
