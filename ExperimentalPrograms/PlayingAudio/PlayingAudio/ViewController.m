//
//  ViewController.m
//  PlayingAudio
//
//  Created by Arno in Wolde Lübke on 02.01.14.
//  Copyright (c) 2014 Arno in Wolde Lübke. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (strong, nonatomic) AVAudioPlayer* a;
@end

@implementation ViewController

- (IBAction)play:(id)sender
{
    NSLog(@"button pressed");
    NSString* file = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/piano.m4a"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:file];

    NSLog(@"%@", url);

    self.a  = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    if (!self.a)
    {
        NSLog(@"did not work");
    }
    else
    {
        NSLog(@"did work!!");
    }
    
    self.a.volume = 1;
    [self.a prepareToPlay];

    [self.a play];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
