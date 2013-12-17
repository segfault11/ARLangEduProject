//
//  artoolkit.h
//  example2-3
//
//  Created by 加藤 博一 on 11/09/04.
//  Copyright 2011 奈良先端科学技術大学院大学. All rights reserved.
//

#import <AR/ar.h>
#import <AR/gsub2.h>

void artoolkitInit( int imageXsize, int imageYsize, int iPadFlag );
int artoolkitQRReader(ARUint8 *imageY, ARUint8 *imageUV, int xsize, int ysize, int overSampleScale, ARUint8 *outImage);
