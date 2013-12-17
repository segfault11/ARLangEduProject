//
//  artoolkit.c
//  example2-3
//
//  Created by 加藤 博一 on 11/09/04.
//  Copyright 2011 奈良先端科学技術大学院大学. All rights reserved.
//
#include <stdio.h>
#include <string.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "artoolkit.h"


static int                  initF = 0;
static ARParam              cparam;
static ARParamLT           *cparamLT;
static ARG2ViewportHandle  *vp;
static ARHandle            *arHandle;
static int                  winXsize, winYsize;


void artoolkitInit( int imageXsize, int imageYsize, int iPadFlag )
{
    ARG2Viewport    viewport;
    int             pixFormat;
    char           *machine;
    
    if( initF ) return;    
    initF = 1;
    
    pixFormat = AR_PIXEL_FORMAT_MONO;
    assert(GL_NO_ERROR == glGetError());
    
    machine = arUtilGetMachineType();
    if( strcmp(machine, "iPad2,7") == 0 ) {
        if( imageXsize == 640 && imageYsize == 480 ) {
            NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/camera_para_ipadmini640x480"];
            if( arParamLoad((char*)[path UTF8String], "dat", 1, &cparam) < 0 ) {
                printf("Error0: cannot read camera parameter.");
                exit(0);
            }
        }
        else {
            printf("No camera parameters.\n");
            exit(0);
        }
    }
    else if( iPadFlag ) {
        if( imageXsize == 480 && imageYsize == 360 ) {
            if( arParamLoad("CameraParameters/camera_para_ipad_medium", "dat", 1, &cparam) < 0 ) {
                printf("Error1: cannot read camera parameter.");
                exit(0);
            }
        }
        else {
            if( arParamLoad("CameraParameters/camera_para_ipad640x480", "dat", 1, &cparam) < 0 ) {
                printf("Error2: cannot read camera parameter.");
                exit(0);
            }
        }
    }
    else {
        if( arParamLoad("CameraParameters/camera_para_iphone", "dat", 1, &cparam) < 0 ) {
            printf("Error3 : cannot read camera parameter.");
            exit(0);
        }
    }
    free( machine );
    assert(GL_NO_ERROR == glGetError());
    
    arParamChangeSize( &cparam, imageXsize, imageYsize, &cparam );
    printf("*** Camera Parameter ***\n");
    arParamDisp( &cparam );
    printf("Create cparam lookup table.\n");
    cparamLT = arParamLTCreate(&cparam, AR_PARAM_LT_DEFAULT_OFFSET);
    printf("  Done.\n");
    assert(GL_NO_ERROR == glGetError());

    if( (arHandle = arCreateHandle(cparamLT)) == NULL ) {
        printf("Error: arCreateHandle.");
        exit(0);
    }
    assert(GL_NO_ERROR == glGetError());

    arSetPixelFormat    ( arHandle, pixFormat);
    assert(GL_NO_ERROR == glGetError());

    arSetImageProcMode  ( arHandle, AR_IMAGE_PROC_FIELD_IMAGE );

    assert(GL_NO_ERROR == glGetError());
    arSetLabelingThresh ( arHandle, 100 );
    assert(GL_NO_ERROR == glGetError());
    
    arSetDebugMode      ( arHandle, 0 );
    assert(GL_NO_ERROR == glGetError());
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH,  &winXsize);
    printf("WIN X SIZE %d", winXsize);
    assert(GL_NO_ERROR == glGetError());

    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &winYsize);
    assert(GL_NO_ERROR == glGetError());

    viewport.sx = 0;
    viewport.sy = 0;
    viewport.xsize = winXsize;
    viewport.ysize = winYsize;
    
    assert(GL_NO_ERROR == glGetError());

    vp = arg2CreateViewport          ( &viewport );
    assert(GL_NO_ERROR == glGetError());

    arg2ViewportSetCparam            ( vp, &cparam );
    assert(GL_NO_ERROR == glGetError());

    arg2ViewportSetPixFormat         ( vp, pixFormat );
    assert(GL_NO_ERROR == glGetError());

    arg2ViewportSetDispMethod        ( vp, AR_GL_DISP_METHOD_TEXTURE_MAPPING_FRAME );
    assert(GL_NO_ERROR == glGetError());

    arg2ViewportSetDistortionMode    ( vp, AR_GL_DISTORTION_COMPENSATE_ENABLE );
    //arg2ViewportSetDispMode          ( vp, AR_GL_DISP_MODE_FIT_TO_VIEWPORT );
    //arg2ViewportSetDispMode          ( vp, AR_GL_DISP_MODE_FIT_TO_VIEWPORT_KEEP_ACPECT_RATIO );
    //arg2ViewportSetDispMode          ( vp, AR_GL_DISP_MODE_FIT_TO_VIEWPORT_HEIGHT_KEEP_ACPECT_RATIO );
    arg2ViewportSetDispMode          ( vp, AR_GL_DISP_MODE_FIT_TO_VIEWPORT_WIDTH_KEEP_ACPECT_RATIO );
    
    return;
}

int artoolkitQRReader(ARUint8 *imageY, ARUint8 *imageUV, int xsize, int ysize, int overSampleScale, ARUint8 *outImage)
{
    ARMarkerInfo           *markerInfo;
    int                     markerNum;
    ARPattRectInfo          rect;
    int                     j, k;
    
    if( initF == 0 ) {
        printf("Error. no initialization.\n");
        exit(0);
    }
    
    if( arDetectMarker(arHandle, imageY) < 0 ) exit(0);
    markerNum = arGetMarkerNum( arHandle );
    markerInfo =  arGetMarker( arHandle );
    if( markerNum == 0 ) return -1;
    
    k = 0;
    for( j = 1; j < markerNum; j++ ) {
        if( markerInfo[k].area < markerInfo[j].area ) k = j;
    }
    if( markerInfo[k].area < 400 ) return -1;
    
    rect.topLeftX = 0.15;
    rect.topLeftY = 0.15;
    rect.bottomRightX = 0.85;
    rect.bottomRightY = 0.85;
    return arPattGetImage3(arHandle, k, imageY, &rect, xsize, ysize, overSampleScale, outImage);
}

