//------------------------------------------------------------------------------
//
//  Logger.m
//  BadARApp
//
//  Created by Arno in Wolde Lübke on 21.01.14.
//  Copyright (c) 2014 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "Logger.h"
#import <stdio.h>
#import <stdlib.h>
//------------------------------------------------------------------------------
@interface Logger ()
{
    char _fnAcc[256];
    char _fnOri[256];
    char _fnBut[256];
    FILE* _fileAcc;
    FILE* _fileOri;
    FILE* _fileBut;
}
@end
//------------------------------------------------------------------------------
@implementation Logger
//------------------------------------------------------------------------------
- (id)initWithProfileName:(const NSString*)profileName
{
    self = [super init];
    
//    const char* path = [[[NSBundle mainBundle] resourcePath] UTF8String];
    NSArray  *documentDirList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    const char* path = [[documentDirList objectAtIndex:0] UTF8String];
    
    // create the filename
    sprintf(_fnAcc, "%s/%sAccData.dat", path, [profileName UTF8String]);
    sprintf(_fnOri, "%s/%sOriData.dat", path, [profileName UTF8String]);
    sprintf(_fnBut, "%s/%sButData.dat", path, [profileName UTF8String]);
    
    printf("%s", _fnOri);
    
    // open files (append if necessary)
    _fileAcc = fopen(_fnAcc, "a");
    _fileOri = fopen(_fnOri, "a");
    _fileBut = fopen(_fnBut, "a");
    
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    NSLog(@"dealloc");
    
    // close files
    fclose(_fileAcc);
    fclose(_fileOri);
    fclose(_fileBut);
}
//------------------------------------------------------------------------------
- (void)logOrientationForMarker:(int) id WithYaw:(float)yaw AndWithPitch:(float)pitch AndWithRoll:(float)roll
{
    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss.SSS"];

    dateString = [formatter stringFromDate:[NSDate date]];

    fprintf(
        _fileOri,
        "%s;%d;%f;%f;%f\n",
        [dateString UTF8String],
        id, yaw, pitch, roll
    );
    
    fflush(_fileOri);
}
//------------------------------------------------------------------------------
- (void)logAccelerationForMarker:(int) id WithX:(float)x AndWithY:(float)y AndWithZ:(float)z
{
    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss.SSS"];

    dateString = [formatter stringFromDate:[NSDate date]];

    fprintf(
        _fileAcc,
        "%s;%d;%f;%f;%f\n",
        [dateString UTF8String],
        id, x, y, z
    );
    
    fflush(_fileAcc);
}
//------------------------------------------------------------------------------
- (void)logButtonPressForMarker:(int)id WithLabel:(NSString*)label 
{
    NSDateFormatter *formatter;
    NSString        *dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss.SSS"];

    dateString = [formatter stringFromDate:[NSDate date]];

    fprintf(
        _fileBut,
        "%s;%d;%s\n",
        [dateString UTF8String],
        id,
        [label UTF8String]
    );

    
    fflush(_fileBut);
}
@end
//------------------------------------------------------------------------------