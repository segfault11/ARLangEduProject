//
//  NewProfileViewController.m
//  GUIPrototype
//
//  Created by Arno in Wolde Lübke on 25.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "NewProfileViewController.h"
#import "ProfileManager.h"

@interface NewProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField* nameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@end

@implementation NewProfileViewController

- (IBAction)addProfile:(id)sender
{
    ProfileManager* pm = [ProfileManager instance];
    [pm addProfileWithFirstName: self.nameField.text andLastName:self.lastNameTextField.text];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.nameField.text = @" ";
    self.lastNameTextField.text = @" ";
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
