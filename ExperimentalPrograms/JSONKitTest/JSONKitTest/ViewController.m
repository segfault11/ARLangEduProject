//
//  ViewController.m
//  JSONKitTest
//
//  Created by Arno in Wolde Lübke on 26.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ViewController.h"
#import "JSONKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData* data = [[NSData alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/bla.json"]];
    
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
    
    for (NSDictionary* entry in entries)
    {
        NSLog(@"%@", [entry objectForKey:@"name"]);
    
        NSNumber* n = [entry objectForKey:@"age"];
        
        NSLog(@"%d", [n integerValue]);
    
        NSNumber* m = [entry objectForKey:@"weight"];
        
        NSLog(@"%f", [m floatValue]);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
