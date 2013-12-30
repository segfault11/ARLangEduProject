//
//  Marker.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Marker : NSObject
{
    int _id;
    int _content;
    NSString* _filename;
    NSString* _suffix;
}
@property int id, content;
@property NSString* filename;
@property NSString* suffix;
@end
