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
- (void)renderSprite:(int)id WithView:(GLfloat*)view AndProjection:(GLfloat*)proj;
{
    static NSDate* prevTime = nil;
    NSTimeInterval dTime;

    if (prevTime)
    {
        dTime = [[NSDate date] timeIntervalSinceDate:prevTime];
//        NSLog(@"dTime = %lf", dTime);
    }

    prevTime = [NSDate date];

    glClear(GL_DEPTH_BUFFER_BIT);

    static float elapsed = 0.0;
    static float prevId = -1;
    
    if (prevId == id)
    {
        elapsed += dTime;
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


    // create rotation matrix for the sprite
    GLKMatrix4 rotX = GLKMatrix4MakeRotation(
            GLKMathDegreesToRadians(s.rotation.x),
            1.0, 0.0, 0.0
        );
    
    GLKMatrix4 rotY = GLKMatrix4MakeRotation(
            GLKMathDegreesToRadians(s.rotation.y),
            0.0, 1.0, 0.0
        );
    
    GLKMatrix4 rotZ = GLKMatrix4MakeRotation(
            GLKMathDegreesToRadians(s.rotation.z),
            0.0, 0.0, 1.0
        );

    GLKMatrix4 rot = GLKMatrix4Multiply(rotX, rotY);
    rot = GLKMatrix4Multiply(rot, rotZ);


    GLKTextureInfo* texInfo = [self.sheetTextures
        objectForKey:[NSNumber numberWithInt:ss.id]];

    [self.program bind];
    
    float asp = texInfo.width/(texInfo.height*ss.numFrames);
    [self.program setUniform:@"frameAspect" WithFloat:asp];
    [self.program setUniform:@"numFrames" WithInt:ss.numFrames];
    [self.program setUniform:@"V" WithMat4:view];
    [self.program setUniform:@"P" WithMat4:proj];
    [self.program setUniform:@"size" WithFloat:s.size];
    [self.program setUniform:@"translation"
        WithVec3WithX:s.translation.x
        AndWithY:s.translation.y
        AndWithZ:s.translation.z];
    [self.program setUniform:@"R" WithMat4:rot.m];
    
    int currentFrame = ((int)(elapsed/a.duration*ss.numFrames) + s.frame) % ss.numFrames;
    
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