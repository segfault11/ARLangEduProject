//
//  Timer.h
//  BadARApp
//
//  Created by Arno in Wolde Lübke on 23.01.14.
//  Copyright (c) 2014 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
-(id)init;
-(void)dealloc;
-(void)start;
-(void)stop;
-(void)reset;
-(double)getElapsed;
@end
