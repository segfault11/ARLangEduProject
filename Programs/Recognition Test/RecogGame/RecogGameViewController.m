//
//  RecogGameViewController.m
//  RecogGame
//
//  Created by Marc Ericson Santos on 2/7/14.
//  Copyright (c) 2014 Marc Ericson Santos. All rights reserved.
//

#import "RecogGameViewController.h"
#import "JSONKit.h"
#import "Logger.h"

@interface RecogGameViewController ()
{
    NSString* _userName;
}
@property (weak, nonatomic) IBOutlet UILabel *userNameTextfield;
@property (weak, nonatomic) IBOutlet UILabel *instructionTextfield;
@property (weak, nonatomic) IBOutlet UILabel *wordTextfield;
@property (weak, nonatomic) IBOutlet UILabel *progressUpdate;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property(strong, nonatomic) Logger* logger;
@end

@implementation RecogGameViewController

int currentItem;
NSMutableArray* testItems;

- (void)setUserName:(NSString*)userName
{
    _userName = userName;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSMutableArray*)shuffle:(NSArray*)array
{
    NSMutableArray* ma = [[NSMutableArray alloc] init];
    
    for (NSDictionary* entry in array)
    {
        NSMutableDictionary* md = [NSMutableDictionary dictionaryWithDictionary:entry];
        [ma addObject:md];
    }
    
    for (int i = 0; i < ma.count; i++)
    {
        int r  = arc4random() % ma.count;
        [ma exchangeObjectAtIndex:i withObjectAtIndex:r];
    }
    
    return ma;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.userNameTextfield.text = _userName;
    
    NSData* data = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/test.json"]];
    
    if (!data)
    {
        NSLog(@"Could not load data");
        exit(0);
    }
    
    NSArray* entries = [data objectFromJSONData];
    
    if (!entries)
    {
        NSLog(@"array not found");
        exit(0);
    }
    
    currentItem = 0;
    testItems = [self shuffle:entries];
    
    for (NSDictionary* entry in testItems)
    {
        NSNumber* n = [entry objectForKey:@"id"];
        NSLog(@"%d", [n integerValue]);
        
        NSLog(@"%@", [entry objectForKey:@"word"]);
    }
    
    self.logger = [[Logger alloc] initWithProfileName: [_userName stringByAppendingString:@"RecogGame"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)answerButton:(id)sender
{
    if (currentItem<[testItems count])
    {
        UIButton* button = (UIButton*)sender;
        [self.logger logButtonPressForMarker:0 WithLabel: [[button.titleLabel.text stringByAppendingString:@";"] stringByAppendingString:self.wordTextfield.text]];
        
        self.wordTextfield.text = @" ";
        self.progressUpdate.text = [NSString stringWithFormat:@"You finished %d of %d.", currentItem, [testItems count]];
        self.yesButton.hidden = YES;
        self.noButton.hidden = YES;
        self.nextButton.hidden = NO;
        
    }
    else
    {
        UIButton* button = (UIButton*)sender;
        [self.logger logButtonPressForMarker:0 WithLabel: [[button.titleLabel.text stringByAppendingString:@";"] stringByAppendingString:self.wordTextfield.text]];
        
        self.wordTextfield.text = @" ";
        self.instructionTextfield.text = @"The test is finished. Thank you for taking this test!";
        self.progressUpdate.text = [NSString stringWithFormat:@"You finished %d of %d.", currentItem, [testItems count]];
        self.yesButton.hidden = YES;
        self.noButton.hidden = YES;
        self.nextButton.hidden = YES;
    }
}

- (IBAction)nextButton:(id)sender
{
    if (currentItem<[testItems count])
    {
        UIButton* button = (UIButton*)sender;
        [self.logger logButtonPressForMarker:0 WithLabel: [[button.titleLabel.text stringByAppendingString:@";"] stringByAppendingString:self.wordTextfield.text]];
        
        NSDictionary* currentDictionary = [testItems objectAtIndex:currentItem];
        self.wordTextfield.text = [currentDictionary objectForKey:@"word"];;
        
        self.yesButton.hidden = NO;
        self.noButton.hidden = NO;
        self.nextButton.hidden = YES;
        currentItem = currentItem + 1;
    }
}

@end
