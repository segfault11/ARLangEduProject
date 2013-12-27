//
//  IntroductionViewController.m
//  GUIPrototype
//
//  Created by Arno in Wolde Lübke on 25.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "IntroductionViewController.h"

@interface IntroductionViewController ()
@property (weak, nonatomic) IBOutlet UILabel *introductionText;

@end

@implementation IntroductionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
 
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.introductionText.text = @"Here are some instructions (m.b. screen shots) on\nhow\nto\nuse\nthis\napp";
    self.introductionText.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
