//------------------------------------------------------------------------------
//
//  SpriteRenderer.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>


// NOTE: This class needs an GL Context be set up before it is used
@interface SpriteRenderer : NSObject
- (id)init;
- (void)dealloc;
- (void)renderSprite:(int)id WithView:(GLfloat*)view AndProjection:(GLfloat*)proj;
@end
