//------------------------------------------------------------------------------
//
//  ViewController.m
//  ARToolkitTest
//
//  Created by Arno in Wolde Lübke on 13.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ViewController.h"
#import <AR/ar.h>
#import <AR/gsub2.h>
#import <assert.h>
#import <CoreVideo/CVOpenGLESTextureCache.h>
#import <assert.h>
#import "GLUEProgram.h"
//------------------------------------------------------------------------------
#define VIDEO_FRAME_WIDTH 480
#define VIDEO_FRAME_HEIGHT 640
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
static float cube[] =
    {
        0.0f, 0.0f, 0.0f
    };
//------------------------------------------------------------------------------
@interface ViewController ()
{
    GLuint _vertexArray;
    GLuint _buffer;
    GLuint _luminanceTex;
    GLuint _chrominanceTex;
    ARParam _cparam;
    ARParamLT* _cparamLT;
    ARHandle* _arHandle;
    ARPattHandle* _pattHandle;
    int _pattId;
    ARUint8 _imgY[VIDEO_FRAME_WIDTH*VIDEO_FRAME_HEIGHT];
    AR3DHandle* _ar3DHandle;
    
    struct
    {
        GLuint vertexArray;
        GLuint buffer;
    }
    _cube;
}
@property(nonatomic, strong) GLUEProgram* program;
@property(nonatomic, strong) GLUEProgram* program2;
@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureDevice* backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput* input;
@property(nonatomic, strong) AVCaptureVideoDataOutput* output;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property(strong, nonatomic) EAGLContext *context;
- (void)initMarkerDetection;
- (void)setupGL;
- (void)initCaptureSession;
- (void)tearDownGL;
- (void)renderVideo;
- (void)renderCube:(GLfloat*)view;
@end
//------------------------------------------------------------------------------
@implementation ViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    [self initMarkerDetection];
    [self initCaptureSession];
}
//------------------------------------------------------------------------------
- (void)initMarkerDetection
{
    //
    //  Set up AR Toolkit
    //


    // load camera parameters
    NSString* path = [[[NSBundle mainBundle] resourcePath]
        stringByAppendingString:@"/camera_para_ipadmini640x480"];
    
    if (arParamLoad((char*)[path UTF8String], "dat", 1, &_cparam) < 0)
    {
        NSLog(@"Could not load camera parameters");
        exit(0);
    }

    arParamChangeSize(
        &_cparam,
        VIDEO_FRAME_WIDTH,
        VIDEO_FRAME_HEIGHT,
        &_cparam
    );
    arParamDisp( &_cparam );

    _cparamLT = arParamLTCreate(&_cparam, AR_PARAM_LT_DEFAULT_OFFSET);
    _arHandle = arCreateHandle(_cparamLT);
    
    if (NULL == _arHandle)
    {
        NSLog(@"Cannot create handle");
        exit(0);
    }
    
    arSetPixelFormat(_arHandle, AR_PIXEL_FORMAT_MONO);
    arSetImageProcMode(_arHandle, AR_IMAGE_PROC_FIELD_IMAGE);
    arSetLabelingThresh(_arHandle, 100);
    arSetDebugMode(_arHandle, 0);
    
    //
    //  Load marker
    //
    _pattHandle = arPattCreateHandle();
    
    if (NULL == _pattHandle)
    {
        NSLog(@"Could not create pattern handle");
        exit(0);
    }
    
    _pattId = arPattLoad(_pattHandle, "patt", "hiro");
    
    if (0 > _pattId)
    {
        NSLog(@"Could not load pattern");
        exit(0);
    }
    
    arPattAttach(_arHandle, _pattHandle);

    //
    //  Create a 3D handle
    //
    _ar3DHandle = ar3DCreateHandle(&_cparam);
}
//------------------------------------------------------------------------------
- (void)initCaptureSession
{
    // init and configure a AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPreset640x480;
 
    // select the back camera
    NSArray *devices = [AVCaptureDevice devices];
 
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                self.backCamera = device;
            }
        }
    }
    
    [self.backCamera lockForConfiguration:NULL];
    [self.backCamera setActiveVideoMinFrameDuration:CMTimeMake(1.0f, 30.0f)];
    [self.backCamera unlockForConfiguration];
 
    // create a capture input device
    NSError* error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&error];
 
    if (!self.input) {
        NSLog(@"Failed to create capture device input");
        exit(0);
    }
 
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"Failed to add input");
        exit(0);
    }
 
    // create an output device
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    [self.output setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    self.output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) };
    [self.output setSampleBufferDelegate:self queue:dispatch_get_main_queue()]; // Set dispatch to be on the main thread so OpenGL can do things with the data
    assert([self.session canAddOutput:self.output]);
    [self.session addOutput:self.output];
 
    AVCaptureConnection* connection =
        [self.output connectionWithMediaType:AVMediaTypeVideo];
 
    if ([connection isVideoOrientationSupported])
    {
        [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
    else
    {
        NSLog(@"Could not set orientation");
        exit(0);
    }
 
    // start the session
    [self.session startRunning];
}
//------------------------------------------------------------------------------
- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}
//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}
//------------------------------------------------------------------------------
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // set up vao & buffer for our background texture quad
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quad), quad, GL_STATIC_DRAW);

    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    // create a glsl program for rendering the tex quad
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"VideoVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"VideoFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
    [self.program bind];
    [self.program setUniform:@"luminance" WithInt:0];
    [self.program setUniform:@"chrominance" WithInt:1];
    
    glGenTextures(1, &_luminanceTex);
    glBindTexture(GL_TEXTURE_2D, _luminanceTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(
        GL_TEXTURE_2D,
        0, GL_RED_EXT, VIDEO_FRAME_WIDTH, VIDEO_FRAME_HEIGHT, 0,
        GL_RED_EXT, GL_UNSIGNED_BYTE,
        NULL
    );
    
    glGenTextures(1, &_chrominanceTex);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTex);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(
        GL_TEXTURE_2D,
        0, GL_RG_EXT, VIDEO_FRAME_WIDTH/2, VIDEO_FRAME_HEIGHT/2, 0,
        GL_RG_EXT, GL_UNSIGNED_BYTE,
        NULL
    );
    
    //
    // prepare stuff for rendering a cube
    //
    glGenBuffers(1, &_cube.buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _cube.buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube), cube, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_cube.vertexArray);
    glBindVertexArrayOES(_cube.vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _cube.buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    self.program2 = [[GLUEProgram alloc] init];
    [self.program2 attachShaderOfType:GL_VERTEX_SHADER FromFile:@"CubeVS.glsl"];
    [self.program2 attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"CubeFS.glsl"];
    [self.program2 bindAttribLocation:0 ToVariable:@"pos"];
    [self.program2 compile];
    
    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
- (void)tearDownGL
{
    glDeleteVertexArraysOES(1, &_vertexArray);
    glDeleteBuffers(1, &_buffer);
    glDeleteTextures(1, &_luminanceTex);
    glDeleteTextures(1, &_chrominanceTex);
    
    assert(GL_NO_ERROR == glGetError());

    [EAGLContext setCurrentContext:self.context];
}
//------------------------------------------------------------------------------
- (void) captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //
    // Process luminance input of the video
    //
    uint8_t* baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(
            imageBuffer, 0
        );
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);

    if (NULL == baseAddress
        || width != VIDEO_FRAME_WIDTH
        || height != VIDEO_FRAME_HEIGHT
    )
    {
        NSLog(@"Couldnt get image");
    }

    memcpy(_imgY, baseAddress, VIDEO_FRAME_WIDTH*VIDEO_FRAME_HEIGHT);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _luminanceTex);
    
    glTexSubImage2D(
        GL_TEXTURE_2D, 0, 0, 0, VIDEO_FRAME_WIDTH, VIDEO_FRAME_HEIGHT,
        GL_RED_EXT, GL_UNSIGNED_BYTE, baseAddress
    );

    //
    // Process chrominance input of the video
    //
    baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    width = CVPixelBufferGetWidthOfPlane(imageBuffer, 1);
    height = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTex);
    
    glTexSubImage2D(
        GL_TEXTURE_2D, 0, 0, 0, VIDEO_FRAME_WIDTH/2, VIDEO_FRAME_HEIGHT/2,
        GL_RG_EXT, GL_UNSIGNED_BYTE, baseAddress
    );
    
    assert(glGetError() == GL_NO_ERROR);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    [self renderVideo];
    
    //
    //  FIND THE MARKER, MR PROGRAM CODE!!
    //
    static int cont = 0;
    
    arDetectMarker(_arHandle, _imgY);
    ARMarkerInfo* markerInfo = arGetMarker(_arHandle);
    int numMarkers = arGetMarkerNum(_arHandle);

    if (numMarkers  == 0)
    {
        cont = 0;
        return;
    }
    
    float trans[3][4];
    GLfloat view[16];
    
    for (int i = 0; i < numMarkers; i++)
    {
        if (_pattId == markerInfo[i].id)
        {
            if (cont == 0)
            {
                NSLog(@"%d", numMarkers);
                arGetTransMatSquare(_ar3DHandle, &(markerInfo[i]), 44.0f, trans);
            }
            else
            {
                arGetTransMatSquareCont(
                    _ar3DHandle,
                    &(markerInfo[i]),
                    trans,
                    44.0f,
                    trans
                );
            }
            
            cont = 1;

            //arg2ConvGlpara(trans, view);
//            [self renderCube:NULL];

        }
    }
}
//------------------------------------------------------------------------------
- (void)renderVideo
{
    glClearColor(0.7, 0.7, 0.7, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.program bind];
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
//------------------------------------------------------------------------------
- (void)renderCube:(GLfloat*)view
{
    [self.program2 bind];
    glBindVertexArrayOES(_cube.vertexArray);
    glDrawArrays(GL_POINTS, 0, 1);
}
//------------------------------------------------------------------------------
- (void)update
{


}
//------------------------------------------------------------------------------
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{


}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------