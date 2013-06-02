//
//  mmmTeacherOnboardingViewController.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmTeacherOnboardingViewController.h"

@interface mmmTeacherOnboardingViewController ()

@end

@implementation mmmTeacherOnboardingViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(150.0f, 0.0f, 150.0f, 40.0f)];
    
    switch (indexPath.row) {
        case 0:
            [[cell textLabel] setText:@"Name"];
            break;
            
        case 1:
            [[cell textLabel] setText:@"E-mail"];
            break;
        
        case 2:
            [[cell textLabel] setText:@"Password"];
            [textField setSecureTextEntry:YES];
            break;
            
        default:
            break;
    }

    [cell addSubview:textField];

    return cell;
}

@end
