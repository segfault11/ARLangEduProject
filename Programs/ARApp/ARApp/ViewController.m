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
#import "MarkerManager.h"
#import "ContentManager.h"
#import "SpriteManager.h"
#import "SpriteRenderer.h"
#import "GLUEProgram.h"
#import <CoreMotion/CoreMotion.h>
//------------------------------------------------------------------------------
#define VIDEO_FRAME_WIDTH 640
#define VIDEO_FRAME_HEIGHT 480
#define BAD_AR 0
#define NUM_NOISE 10000
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
static float cube[] = {
        1.0, -1.0, -1.0,
        1.0, -1.0,  1.0,
        -1.0, -1.0,  1.0,
        -1.0,  -1.0,  -1.0,
        1.0,  1.0, -1.0,
        1.0, 1.0, 1.0,
        -1.0, 1.0, 1.0,
        -1.0,  1.0, -1.0
    };
//------------------------------------------------------------------------------
//static float cube[] = {
//        1.0, -1.0, -1.0,
//        1.0, -1.0,  1.0,
//        -1.0, -1.0,  1.0,
//        -1.0,  -1.0,  -1.0,
//        1.0,  1.0, -1.0,
//        1.0, 1.0, 1.0,
//        -1.0, 1.0, 1.0,
//        -1.0,  1.0, -1.0
//    };
//------------------------------------------------------------------------------
//static float cube[] = {
//        0.0, 0.0, 0.0,
//        1.0, 0.0, 0.0,
//        0.0, 1.0, 0.0,
//        0.0, 0.0, 0.0,
//        -1.0, 0.0, 0.0,
//        0.0, -1.0, 0.0,
//        0.0, 0.0, 0.0,
//        0.0, 0.0, 0.0
//    };
//------------------------------------------------------------------------------
static GLushort cubeIndices[] = {
        4, 7, 6,
        0, 4, 5,
        1, 5, 2,
        2, 6, 3,
        4, 0, 3,
        5, 4, 6,
        1, 0, 5,
        5, 6, 2,
        6, 7, 3,
        7, 4, 3,
        0, 1, 2,
        3, 0, 2
    };
//------------------------------------------------------------------------------
static void arg2ConvGLcpara(
    ARParam *cparam,
    ARG2ClipPlane clipPlane,
    GLfloat m[16]
);
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
    ARPattHandle* _pattHandle2;
    int _pattId;
    int _pattId2;
    ARUint8 _imgY[VIDEO_FRAME_WIDTH*VIDEO_FRAME_HEIGHT];
    AR3DHandle* _ar3DHandle;
    GLfloat _proj[16];
    BOOL _cont;
    NSString* _profileName;
    int _curMarkerID;
    
    struct
    {
        GLuint vertexArray;
        GLuint buffer;
        GLuint indexBuffer;
    }
    _cube;
}
@property(nonatomic, strong) NSMutableDictionary* marker; // maps artoolkit id to maker id
@property(nonatomic, strong) SpriteRenderer* spriteRenderer;
@property(nonatomic, strong) GLUEProgram* program;
@property(nonatomic, strong) GLUEProgram* program2;
@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureDevice* backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput* input;
@property(nonatomic, strong) AVCaptureVideoDataOutput* output;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property(strong, nonatomic) EAGLContext *context;
@property (weak, nonatomic) IBOutlet UITextField *profileNameTextfield;
@property(weak, nonatomic) IBOutlet UILabel *sentence;
@property (weak, nonatomic) IBOutlet UILabel *translation;
@property(strong, nonatomic) Content* currentContent;
@property(strong, nonatomic) AVAudioPlayer* audioPlayer;
@property(strong, nonatomic) CMMotionManager* manager;
@property(strong, nonatomic) Logger* logger;
- (void)initMarkerDetection;
- (void)setupGL;
- (void)initCaptureSession;
- (void)tearDownGL;
- (void)renderVideo;
- (void)renderCubeWithView:(GLfloat*)view AndProjection:(GLfloat*)proj;
- (void)resetCurrentContent;
- (void)playSound:(NSString*)filename;
//- (void)logUserData;
@end
//------------------------------------------------------------------------------
@implementation ViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.profileNameTextfield.text = _profileName;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    _cont = NO;
    _curMarkerID = -1;
    
    [self setupGL];
    [self initMarkerDetection];
    [self initCaptureSession];
    self.spriteRenderer = [[SpriteRenderer alloc] init];
    self.currentContent = nil;
    
    self.navigationItem.title = @"Augmented Reality View";
    
    [ContentManager instance];

    // set up motion capture
    self.manager = [[CMMotionManager alloc] init];
    self.manager.deviceMotionUpdateInterval = 1.0/60.0;
    self.manager.showsDeviceMovementDisplay = YES;

    [self.manager
        startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
        toQueue:[NSOperationQueue currentQueue]
        withHandler:nil];
    
    // set up logger
    self.logger = [[Logger alloc] initWithProfileName:_profileName];
}
//------------------------------------------------------------------------------
- (void)initMarkerDetection
{
    //
    //  Set up AR Toolkit
    //

    char* machine = arUtilGetMachineType();

    // load camera parameters
    NSString* path;
    
    if (strcmp(machine, "iPad2,7") == 0)
    {
        path = [[[NSBundle mainBundle] resourcePath]
            stringByAppendingString:@"/camera_para_ipadmini640x480"];
    }
    else
    {
        path = [[[NSBundle mainBundle] resourcePath]
            stringByAppendingString:@"/camera_para_ipad640x480"];
    }
    
    
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
    
    arParamDisp(&_cparam);

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
    
    // load all marker
    MarkerManager* mm = [MarkerManager instance];
    unsigned int numMarker = [mm getNumMarker];
    
    self.marker = [[NSMutableDictionary alloc] init];
    
    for (unsigned int i = 0; i < numMarker; i++)
    {
        Marker* m = [mm getMarkerAtIndex:i];

        int mid = m.id;
        int pid = arPattLoad(
                _pattHandle,
                (char*)[m.filename UTF8String],
                (char*)[m.suffix UTF8String]
            );

//        NSLog(@"pid = %d", pid);

        [self.marker
            setObject:[NSNumber numberWithInt:mid]
            forKey:[NSNumber numberWithInt:pid]];

        if (0 > pid)
        {
            NSLog(@"Could not load pattern");
            exit(0);
        }

    }

//    _pattId = arPattLoad(_pattHandle, "1", "dat");
//    _pattId2 = arPattLoad(_pattHandle, "2", "dat");

    
//    if (0 > _pattId)
//    {
//        NSLog(@"Could not load pattern");
//        exit(0);
//    }
    
    arPattAttach(_arHandle, _pattHandle);

    //
    //  Create a 3D handle
    //
    _ar3DHandle = ar3DCreateHandle(&_cparam);
    
    // prepare projection matrix
    ARG2ClipPlane clip;
    clip.nearClip = 0.01f;
    clip.farClip = 10000.0f;
    arg2ConvGLcpara(&_cparam, clip, _proj);
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

    // start the session
    [self.session startRunning];
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [self.manager stopDeviceMotionUpdates];
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
    
    //
    // Prepare OpenGL stuff for rendering the video
    //
    
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
    
    glGenBuffers(1, &_cube.indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cube.indexBuffer);

    glBufferData(
        GL_ELEMENT_ARRAY_BUFFER,
        sizeof(cubeIndices),
        cubeIndices,
        GL_STATIC_DRAW
    );
    
    glGenVertexArraysOES(1, &_cube.vertexArray);
    glBindVertexArrayOES(_cube.vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _cube.buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _cube.indexBuffer);
    
    self.program2 = [[GLUEProgram alloc] init];
    [self.program2 attachShaderOfType:GL_VERTEX_SHADER FromFile:@"CubeVS.glsl"];
    [self.program2 attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"CubeFS.glsl"];
    [self.program2 bindAttribLocation:0 ToVariable:@"pos"];
    [self.program2 compile];
    
    glDisable(GL_DEPTH_TEST);
    
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
    // start logging
    [self.logger
        logOrientationForMarker:_curMarkerID
        WithYaw:self.manager.deviceMotion.attitude.yaw
        AndWithPitch:self.manager.deviceMotion.attitude.pitch
        AndWithRoll:self.manager.deviceMotion.attitude.roll];
    
    [self.logger
        logAccelerationForMarker:_curMarkerID
        WithX:self.manager.deviceMotion.userAcceleration.x
        AndWithY:self.manager.deviceMotion.userAcceleration.y
        AndWithZ:self.manager.deviceMotion.userAcceleration.z];
    

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    //
    // Process luminance input of the video
    //
    uint8_t* baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(
            imageBuffer, 0
        );
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    size_t widthy = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t heighty = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);

    if (NULL == baseAddress
        || widthy != VIDEO_FRAME_WIDTH
        || heighty != VIDEO_FRAME_HEIGHT
    )
    {
        NSLog(@"Couldnt get image");
    }

    memcpy(_imgY, baseAddress, VIDEO_FRAME_WIDTH*VIDEO_FRAME_HEIGHT);

    //
    // Process chrominance input of the video
    //
    baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    //size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 1);
    //size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTex);
    
    glTexSubImage2D(
        GL_TEXTURE_2D, 0, 0, 0, VIDEO_FRAME_WIDTH/2, VIDEO_FRAME_HEIGHT/2,
        GL_RG_EXT, GL_UNSIGNED_BYTE, baseAddress
    );
    
    assert(glGetError() == GL_NO_ERROR);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _luminanceTex);
    glTexSubImage2D(
        GL_TEXTURE_2D, 0, 0, 0, VIDEO_FRAME_WIDTH, VIDEO_FRAME_HEIGHT,
        GL_RED_EXT, GL_UNSIGNED_BYTE, _imgY
    );
    
#if BAD_AR
    // insert random noise
    for (int i = 0; i < NUM_NOISE; i++)
    {
        int rn = arc4random() % (widthy*heighty);
        _imgY[rn] = 0;
    }
#endif
    
    
    // render the video
    [self renderVideo];
    
    //
    //  FIND THE MARKER, MR PROGRAM CODE!!
    //
    static int cont = 0;
    
    arDetectMarker(_arHandle, _imgY);
    ARMarkerInfo* markerInfo = arGetMarker(_arHandle);
    int numMarkers = arGetMarkerNum(_arHandle);

    if (numMarkers == 0)
    {
        cont = 0;
        return;
    }
    
    static float trans[3][4];
    GLfloat view[16];
    NSNumber* activeMid = nil;
    int currMid;

    for (int i = 0; i < numMarkers; i++)
    {
        NSNumber* mid = [self.marker
                objectForKey:[NSNumber numberWithInt:markerInfo[i].id]];
        
        
        if (mid != nil && markerInfo[i].cf > 0.95f)
        {
            currMid = i;
            activeMid = mid;
        }

    }
    
    if (!activeMid)
    {
        [self resetCurrentContent];
        self.currentContent = nil;
        _curMarkerID = -1;
        return; // no marker found
    }
    
    // get content for marker
    _curMarkerID = [activeMid integerValue];
    Marker* m = [[MarkerManager instance] getMarkerForId:[activeMid integerValue]];
    Content* c = [[ContentManager instance] getContentWithId:m.content];
    
    if (self.currentContent != c)
    {
        [self resetCurrentContent];
        self.currentContent = c;
    }
    
    // compute matrices
    if (!_cont)
    {
        arGetTransMatSquare(
            _ar3DHandle,
            &(markerInfo[currMid]),
            m.size,
            trans
        );
    }
    else
    {
        arGetTransMatSquareCont(
            _ar3DHandle,
            &(markerInfo[currMid]),
            trans,
            m.size,
            trans
        );
    }
    
    // prepare view matrix
    arg2ConvGlpara(trans, view);
    _cont = YES;

    // display content
    Sprite* s = [[SpriteManager instance]
            getSpriteWithId:self.currentContent.sprite];
    
    [self.spriteRenderer renderSprite:s.id WithView:view AndProjection:_proj];

    self.sentence.text = [c.sentences objectAtIndex:c.activeSentence];
    
    if (self.currentContent.isTranslationDisplayed)
    {
        self.translation.hidden = NO;
        self.translation.text = self.currentContent.translation;
    }
    else
    {
        self.translation.hidden = YES;
    }
    
    assert(glGetError() == GL_NO_ERROR);
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
//-----------------------------------------------------------------------------
- (void)update
{


}
//------------------------------------------------------------------------------
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{


}
//------------------------------------------------------------------------------
- (void)resetCurrentContent
{
    _cont = NO;
    //self.currentContent.activeSentence = 0;
    //self.currentContent.isTranslationDisplayed = NO;
    self.translation.hidden = YES;
    self.sentence.text = @"";
}
//------------------------------------------------------------------------------
- (void)playSound:(NSString*)filename
{
    // PLAYS A SOUND REFERENCED BY [filename]. NOTE [filename] SHOULD NOT
    // CONTAIN THE PATH AS THE SOURCE PATH IS APPENDED IN THIS FUNCTION.
    
    NSString* file = [[[[NSBundle mainBundle] resourcePath]
        stringByAppendingString:@"/"]
        stringByAppendingString:filename];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:file];

    NSLog(@"%@", url);

    self.audioPlayer  = [[AVAudioPlayer alloc]
        initWithContentsOfURL:url error:nil];
    
    self.audioPlayer.volume = 1;
    [self.audioPlayer prepareToPlay];

    [self.audioPlayer play];
}
//------------------------------------------------------------------------------
- (IBAction)playAudio:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_curMarkerID
        WithLabel:b.titleLabel.text];

//    [self.logger
//        logButtonPressForMarker:_curMarkerID
//        WithLabel:@"NASA"];

    if (!self.currentContent)
    {
        return;
    }
    
    [self playSound:self.currentContent.sound];
}
//------------------------------------------------------------------------------
- (IBAction)changeSentence:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_curMarkerID
        WithLabel:b.titleLabel.text];

    if (!self.currentContent)
    {
        return;
    }
    
    int as = self.currentContent.activeSentence;
    int numSentences = self.currentContent.sentences.count;
    
    self.currentContent.activeSentence = (as + 1) % numSentences;
}
//------------------------------------------------------------------------------
- (IBAction)translate:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_curMarkerID
        WithLabel:b.titleLabel.text];

    self.currentContent.isTranslationDisplayed =
        !self.currentContent.isTranslationDisplayed;
}
//------------------------------------------------------------------------------
- (void)setProfileName:(NSString*)profileName
{
    _profileName = profileName;
}
//------------------------------------------------------------------------------
//- (NSUInteger)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskLandscapeLeft;
//}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
void arg2ConvGLcpara(ARParam *cparam, ARG2ClipPlane clipPlane, GLfloat m[16])
{
    float   icpara[3][4];
    float   trans[3][4];
    float   p[3][3], q[4][4];
    float   farClip, nearClip;
    int      width, height;
    int      i, j;
    
    width  = cparam->xsize;
    height = cparam->ysize;
    farClip    = clipPlane.farClip;
    nearClip   = clipPlane.nearClip;
    
    if( arParamDecompMat(cparam->mat, icpara, trans) < 0 )
    {
        exit(0);
    }
    
    for( i = 0; i < 4; i++ ) {
        icpara[1][i] = (height-1)*(icpara[2][i]) - icpara[1][i];
    }
    
    
    for( i = 0; i < 3; i++ ) {
        for( j = 0; j < 3; j++ ) {
            p[i][j] = icpara[i][j] / icpara[2][2];
        }
    }
#if 0
    q[0][0] = (2.0 * p[0][0] / (width-1));
    q[0][1] = (2.0 * p[0][1] / (width-1));
    q[0][2] = ((2.0 * p[0][2] / (width-1))  - 1.0);
    q[0][3] = 0.0;
    
    q[1][0] = 0.0;
    q[1][1] = (2.0 * p[1][1] / (height-1));
    q[1][2] = ((2.0 * p[1][2] / (height-1)) - 1.0);
    q[1][3] = 0.0;
    
    q[2][0] = 0.0;
    q[2][1] = 0.0;
    q[2][2] = (farClip + nearClip)/(farClip - nearClip);
    q[2][3] = -2.0 * farClip * nearClip / (farClip - nearClip);
    
    q[3][0] = 0.0;
    q[3][1] = 0.0;
    q[3][2] = 1.0;
    q[3][3] = 0.0;
#else
    q[0][0] =  (2.0 * p[0][0] / (width-1));
    q[0][1] = -(2.0 * p[0][1] / (width-1));
    q[0][2] = -((2.0 * p[0][2] / (width-1))  - 1.0);
    q[0][3] =  0.0;
    
    q[1][0] = 0.0;
    q[1][1] = -(2.0 * p[1][1] / (height-1));
    q[1][2] = -((2.0 * p[1][2] / (height-1)) - 1.0);
    q[1][3] =  0.0;
    
    q[2][0] =  0.0;
    q[2][1] =  0.0;
    q[2][2] = -(farClip + nearClip)/(farClip - nearClip);
    q[2][3] = -2.0 * farClip * nearClip / (farClip - nearClip);
    
    q[3][0] =  0.0;
    q[3][1] =  0.0;
    q[3][2] = -1.0;
    q[3][3] =  0.0;
#endif
    
    for( i = 0; i < 4; i++ ) {
        for( j = 0; j < 3; j++ ) {
            m[i+j*4] = q[i][0] * trans[0][j]
            + q[i][1] * trans[1][j]
            + q[i][2] * trans[2][j];
        }
        m[i+3*4] = q[i][0] * trans[0][3]
        + q[i][1] * trans[1][3]
        + q[i][2] * trans[2][3]
        + q[i][3];
    }
}
//------------------------------------------------------------------------------
