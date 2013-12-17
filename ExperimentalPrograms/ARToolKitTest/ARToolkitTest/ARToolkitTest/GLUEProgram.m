//
//  GLAProgram.m
//  Toudaiju
//
//  Created by Arno in Wolde Lübke on 15.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "GLUEProgram.h"

@interface GLUEProgram ()
{
    BOOL _isInitialized;
    BOOL _isCompiled;
    GLuint _program;
    NSMutableArray* _shader;
}
@end

@implementation GLUEProgram

-(id)init
{
    self = [super init];
    
    _program = glCreateProgram();
    _isCompiled = NO;
    
    if (0 == _program) {
        _isInitialized = NO;
        NSLog(@"Could not create program");
        return Nil;
    }
    
    _shader = [[NSMutableArray alloc] init];
    
    _isInitialized = YES;
    return self;
}

-(void)dealloc
{
    if (_isInitialized) {
        return;
    }
    
    glDeleteProgram(_program);
}

-(BOOL)attachShaderOfType:(GLenum)type FromFile:(NSString*) filename
{
    if (_isCompiled) {
        return NO;
    }
    
    if (!_isInitialized) {
        return NO;
    }
    
    // load shader from file
    NSString *fullName = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] stringByAppendingString:filename];
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:fullName encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        NSLog(@"Failed to load shader");
        return NO;
    }
    
    // create shader
    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    // print log and check for errors
    GLint status;
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(shader);
        return NO;
    }
    
    // attach the shader
    glAttachShader(_program, shader);
    
    // save the shader so we can delete it after the program was linked
    [_shader addObject: [NSNumber numberWithUnsignedInteger:shader]];
    
    return YES;
}

-(BOOL)bindAttribLocation:(GLuint)index ToVariable:(NSString*) name
{
    if (_isCompiled) {
        return NO;
    }
    
    glBindAttribLocation(_program, index, [name UTF8String]);
    return YES;
}

-(BOOL)compile
{
    if (_isCompiled) {
        return NO;
    }
    
    GLint status;
    glLinkProgram(_program);

    GLint logLength;
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
    
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_program, GL_LINK_STATUS, &status);
    
    if (status == 0) {
        return NO;
    }
    
    // detach and delete all shader
    for (unsigned int i = 0; i < _shader.count; i++) {
        GLuint shader = [[_shader objectAtIndex:i] unsignedIntegerValue];
        
        glDetachShader(_program, shader);
    }
    
    _isCompiled = TRUE;
    
    return YES;
}

-(BOOL)validate
{
    if (!_isCompiled) {
        return NO;
    }
    
    GLint logLength, status;
    
    glValidateProgram(_program);
    glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);

    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_program, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_program, GL_VALIDATE_STATUS, &status);
    
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

-(void)bind
{
    glUseProgram(_program);
}

- (void)setUniform:(NSString*)name WithInt:(GLint)v;
{
    [self bind];
    GLint loc = glGetUniformLocation(_program, (const char*)[name UTF8String]);
    
    if (-1 == loc) {
        NSLog(@"Could not find location");
        return;
    }
    
    glUniform1i(loc, v);
}

- (void)setUniform:(NSString*)name WithFloat:(GLfloat)v;
{
    [self bind];
    GLint loc = glGetUniformLocation(_program, (const char*)[name UTF8String]);
    
    if (-1 == loc) {
        NSLog(@"Could not find location");
        return;
    }
    
    glUniform1f(loc, v);
}


- (void)setUniform:(NSString*)name WithMat4:(const float*)v;
{
    [self bind];
    GLint loc = glGetUniformLocation(_program, (const char*)[name UTF8String]);
    
    if (-1 == loc) {
        NSLog(@"Could not find location");
        return;
    }
    
    glUniformMatrix4fv(loc, 1, GL_FALSE, v);
}

@end
