//------------------------------------------------------------------------------
//
//  SpriteRenderer.m
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "SpriteRenderer.h"
#import "SpriteSheetManager.h"
#import "SpriteManager.h"
#import <GLKit/GLKit.h>
#import "GLUEProgram.h"
#import <assert.h>
#import "AnimationManager.h"
//------------------------------------------------------------------------------
static float quad[] = {
        -1.0f, 1.0f,
        1.0f, 1.0f,
        1.0f, -1.0f,
    
        -1.0f, 1.0f,
        1.0f, -1.0f,
        -1.0f, -1.0f
    };
//------------------------------------------------------------------------------
@interface SpriteRenderer ()
{
    struct
    {
       GLuint vertexArray;
       GLuint buffer;
    }
    _quad;
}
@property (nonatomic, strong) NSMutableDictionary* sheetTextures;
@property (nonatomic, strong) GLUEProgram* program;
- (void)loadSpriteSheets;
- (void)createProgram;
- (void)createQuad;
@end
//------------------------------------------------------------------------------
@implementation SpriteRenderer
//------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    self.sheetTextures = [[NSMutableDictionary alloc] init];
    [self loadSpriteSheets];
    [self createProgram];
    [self createQuad];
    return self;
}
//-------------------------------------------------------------------------------
- (void)createProgram
{
    self.program = [[GLUEProgram alloc] init];
    
    [self.program
        attachShaderOfType:GL_VERTEX_SHADER
        FromFile:@"SpriteRendererVS.glsl"];
    
    [self.program
        attachShaderOfType:GL_FRAGMENT_SHADER
        FromFile:@"SpriteRendererFS.glsl"];
    
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
    [self.program bind];
    [self.program setUniform:@"spriteSheet" WithInt:0];
    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
- (void)createQuad
{
    glGenBuffers(1, &_quad.buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _quad.buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_quad.vertexArray);
    glBindVertexArrayOES(_quad.vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _quad.buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
- (void)loadSpriteSheets
{
    SpriteSheetManager* ssm = [SpriteSheetManager instance];

    NSUInteger num = [ssm getNumSpriteSheets];
    
    for (NSUInteger i = 0; i < num; i++)
    {
        SpriteSheet* s = [ssm getSpriteSheetAtIndex:i];
        NSString* str = [[[[NSBundle mainBundle] resourcePath]
                stringByAppendingString:@"/"]
                stringByAppendingString:s.fileName];
        
        NSLog(@"load tex from file : %@", s.fileName);
        GLKTextureInfo* texInfo =
            [GLKTextureLoader
                textureWithContentsOfFile:str
                options:nil
                error:nil];
        
        if (!texInfo)
        {
            NSLog(@"Failed loading texture for filename : %@", s.fileName);
            exit(0);
        }
        
        NSLog(@"tex dimensions %d %d", texInfo.width, texInfo.height);
        
        [self.sheetTextures
            setObject:texInfo
            forKey:[NSNumber numberWithInt:s.id]];
    }
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    // delete all allocated textures
    NSArray* keys = [self.sheetTextures allKeys];
    
    for (NSNumber* key in keys)
    {
        GLKTextureInfo* texInfo = [self.sheetTextures objectForKey:key];
        
        if (!texInfo)
        {
            GLuint tex = texInfo.name;
            glDeleteTextures(1, &tex);
        }
    }

    glDeleteBuffers(1, &_quad.buffer);
    glDeleteVertexArraysOES(1, &_quad.buffer);

    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
- (void)renderSpriteWithId:(int)id
{
    static float elapsed = 0.0;
    static float prevId = -1;
    
    if (prevId == id)
    {
        elapsed += 0.02;
    }
    else
    {
        elapsed = 0.0;
    }
    

    Sprite* s = [[SpriteManager instance] getSpriteWithId:id];

    if (!s)
    {
        NSLog(@"Could not find sprite");
        exit(0);
    }

    SpriteSheet* ss = [[SpriteSheetManager instance]
        getSpriteSheetWithId:s.spriteSheet];

    if (!s)
    {
        NSLog(@"Could not find sprite sheet for sprite");
        exit(0);
    }

    Animation* a = [[AnimationManager instance] getAnimationWithId:s.animation];
    
    if (!a)
    {
        NSLog(@"Animation not found. s.animation = %d", s.animation);
        exit(0);
    }

    GLKTextureInfo* texInfo = [self.sheetTextures
        objectForKey:[NSNumber numberWithInt:ss.id]];

    [self.program bind];
    
    float asp = texInfo.width/(texInfo.height*ss.numFrames);
    [self.program setUniform:@"frameAspect" WithFloat:asp];
    [self.program setUniform:@"numFrames" WithInt:ss.numFrames];
    
    int currentFrame = ((int)(elapsed/a.duration*ss.numFrames) + s.frame)% ss.numFrames;
    [self.program setUniform:@"curFrame" WithInt:currentFrame];
    
    if (!texInfo)
    {
        NSLog(@"could not find texture");
        exit(0);
    }
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texInfo.name);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindVertexArrayOES(_quad.vertexArray);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    assert(GL_NO_ERROR == glGetError());
    
    prevId = id;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------