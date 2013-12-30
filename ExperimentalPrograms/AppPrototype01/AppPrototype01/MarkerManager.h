//
//  MarkerManager.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Marker.h"

@interface MarkerManager : NSObject
+ (MarkerManager*)instance;
- (Marker*)getMarkerForId:(int)id;
- (Marker*)getMarkerAtIndex:(int)idx;
- (NSUInteger)getNumMarker;
@end
