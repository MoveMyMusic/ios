//
//  mmmOnboardingViewController.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmOnboardingViewController.h"
#import "mmmTeacherOnboardingViewController.h"
#import "mmmStudentOnboardingViewController.h"

@interface mmmOnboardingViewController ()

@end

@implementation mmmOnboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Registration";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [(mmmAppDelegate *)[[UIApplication sharedApplication] delegate] bauhaus:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onboardAsStudent:(id)sender
{
    mmmStudentOnboardingViewController *viewController = [[mmmStudentOnboardingViewController alloc] initWithNibName:@"mmmStudentOnboardingViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onboardAsTeacher:(id)sender
{
    mmmTeacherOnboardingViewController *viewController = [[mmmTeacherOnboardingViewController alloc] initWithNibName:@"mmmTeacherOnboardingViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
