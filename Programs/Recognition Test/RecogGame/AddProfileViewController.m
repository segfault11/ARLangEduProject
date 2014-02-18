//
//  AddProfileViewController.m
//  RecogGame
//
//  Created by Marc Ericson Santos on 2/7/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#import "AddProfileViewController.h"
#import "ProfileManager.h"

@interface AddProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;

@end

@implementation AddProfileViewController

- (IBAction)createProfile:(id)sender
{
    ProfileManager* pm = [ProfileManager instance];
    [pm addProfileWithFirstName: self.firstNameTextfield.text andLastName:self.lastNameTextfield.text];
    [self.navigationController popViewControllerAnimated:YES];
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
