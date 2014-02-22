//
//  Logger.h
//  BadARApp
//
//  Created by Arno in Wolde Lübke on 21.01.14.
//  Copyright (c) 2014 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject
- (id)initWithProfileName:(const NSString*)profileName;
- (void)dealloc;
- (void)logOrientationForMarker:(int)id WithYaw:(float)yaw AndWithPitch:(float)pitch AndWithRoll:(float)roll;
- (void)logAccelerationForMarker:(int)id WithX:(float)x AndWithY:(float)y AndWithZ:(float)z;
- (void)logButtonPressForMarker:(int)id WithLabel:(NSString*)label WithWord:(NSString*)word;
@end
