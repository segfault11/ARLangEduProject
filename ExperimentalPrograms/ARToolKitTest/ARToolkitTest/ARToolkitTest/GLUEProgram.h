//
//  GLAProgram.h
//  Toudaiju
//
//  Created by Arno in Wolde Lübke on 15.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GLUEProgram : NSObject
- (id)init;
- (void)dealloc;
- (BOOL)attachShaderOfType:(GLenum)type FromFile:(NSString*) filename;
- (BOOL)bindAttribLocation:(GLuint)index ToVariable:(NSString*) name;
- (BOOL)compile;
- (BOOL)validate;
- (void)bind;
- (void)setUniform:(NSString*)name WithInt:(GLint)v;
- (void)setUniform:(NSString*)name WithFloat:(GLfloat)v;
- (void)setUniform:(NSString*)name WithMat4:(const float*)v;
@end
