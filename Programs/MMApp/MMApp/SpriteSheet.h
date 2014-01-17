//
//  SpriteSheet.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 27.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpriteSheet : NSObject
{
    int _id;
    NSString* _fileName;
    int _numFrames;
}
@property int id, numFrames;
@property NSString* fileName;
@end
