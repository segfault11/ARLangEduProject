//
//  Content.h
//  AppPrototype01
//
//  Created by Arno in Wolde Lübke on 30.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Content : NSObject
{
    int _id;
    int _sprite;
    NSArray* _sentences;
    int _activeSentence;
    BOOL _isTranslationDisplayed;
    NSString* _translation;
    NSString* _sound;
}
@property int id, sprite, activeSentence;
@property NSArray* sentences;
@property NSString* sound, *translation;
@property BOOL isTranslationDisplayed;
@end
