//------------------------------------------------------------------------------
//
//  ViewController.m
//  MMApp
//
//  Created by Arno in Wolde Lübke on 17.01.14.
//  Copyright (c) 2014 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ViewController.h"
#import "ContentManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "Logger.h"
//------------------------------------------------------------------------------
@interface ViewController ()
{
    NSString* _profileName;
    int _currentContentIdx;
    BOOL _shallDisplayTranslation;
}
@property (weak, nonatomic) IBOutlet UILabel *sentence;
@property (weak, nonatomic) IBOutlet UILabel *translation;
@property (weak, nonatomic) IBOutlet UILabel *currentContent;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property(strong, nonatomic) AVAudioPlayer* audioPlayer;
@property(strong, nonatomic) CMMotionManager* manager;
@property(strong, nonatomic) Logger* logger;
- (void)displayCurrentContent;
@end
//------------------------------------------------------------------------------
@implementation ViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentContentIdx = 0;
    _shallDisplayTranslation = NO;
    [self displayCurrentContent];
    
    // set up motion capture
    self.manager = [[CMMotionManager alloc] init];
    self.manager.deviceMotionUpdateInterval = 1.0/60.0;
    self.manager.showsDeviceMovementDisplay = YES;

    CMDeviceMotionHandler  motionHandler = ^(CMDeviceMotion *motion, NSError *error)
    {
    
    [self.logger
        logOrientationForMarker:_currentContentIdx
        WithYaw:self.manager.deviceMotion.attitude.yaw
        AndWithPitch:self.manager.deviceMotion.attitude.pitch
        AndWithRoll:self.manager.deviceMotion.attitude.roll];
    
    [self.logger
        logAccelerationForMarker:_currentContentIdx
        WithX:self.manager.deviceMotion.userAcceleration.x
        AndWithY:self.manager.deviceMotion.userAcceleration.y
        AndWithZ:self.manager.deviceMotion.userAcceleration.z];
    };

    [self.manager
        startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical
        toQueue:[NSOperationQueue currentQueue]
        withHandler:motionHandler];
    
    // set up logger
    self.logger = [[Logger alloc] initWithProfileName:_profileName];
}
//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
//------------------------------------------------------------------------------
- (IBAction)changeSentence:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_currentContentIdx
        WithLabel:b.titleLabel.text];
        
    Content* c = [[ContentManager instance] getContentAtIndex:_currentContentIdx];
    c.activeSentence = (c.activeSentence + 1) % c.sentences.count;
    [self displayCurrentContent];
}
//------------------------------------------------------------------------------
- (IBAction)playAudio:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_currentContentIdx
        WithLabel:b.titleLabel.text];
    
    Content* c = [[ContentManager instance] getContentAtIndex:_currentContentIdx];
    NSString* filename = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] stringByAppendingString:c.sound];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filename];

    self.audioPlayer = [[AVAudioPlayer alloc]
        initWithContentsOfURL:url error:nil];
    
    self.audioPlayer.volume = 1;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}
//------------------------------------------------------------------------------
- (IBAction)translate:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_currentContentIdx
        WithLabel:b.titleLabel.text];
    
    _shallDisplayTranslation = !_shallDisplayTranslation;
    [self displayCurrentContent];    
}
//------------------------------------------------------------------------------
- (IBAction)displayNextContent:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_currentContentIdx
        WithLabel:b.titleLabel.text];
    
    int numContents = [[ContentManager instance] getNumContents];
    _currentContentIdx = (_currentContentIdx + 1) % numContents;
    _shallDisplayTranslation = NO;
    [self displayCurrentContent];
}
//------------------------------------------------------------------------------
- (IBAction)displayPreviousContent:(id)sender
{
    UIButton* b = sender;
    [self.logger
        logButtonPressForMarker:_currentContentIdx
        WithLabel:b.titleLabel.text];
    
    int numContents = [[ContentManager instance] getNumContents];
    _currentContentIdx = (_currentContentIdx - 1 + numContents) % numContents;
    _shallDisplayTranslation = NO;
    [self displayCurrentContent];
}
//------------------------------------------------------------------------------
- (void)displayCurrentContent
{
    Content* c = [[ContentManager instance] getContentAtIndex:_currentContentIdx];
    
    if (!c)
    {
        return;
    }
    
    self.sentence.text = [c.sentences objectAtIndex:c.activeSentence];
    self.translation.text = c.translation;
    NSString* filename = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] stringByAppendingString:c.bgImage];
    
    self.backgroundImage.image = [UIImage imageWithContentsOfFile:filename];
    self.currentContent.text = [NSString stringWithFormat:@"%d/%d", _currentContentIdx + 1, [[ContentManager instance] getNumContents]];
    
    if (_shallDisplayTranslation)
    {
        self.translation.hidden = NO;
    }
    else
    {
        self.translation.hidden = YES;
    }
}
//------------------------------------------------------------------------------
- (void)setProfileName:(NSString*)profileName
{
    _profileName = profileName;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------