//
//  mmmStudentOnboardingViewController.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmStudentOnboardingViewController.h"

static const int kTableTextField     = 1000;
static const int kNameTextField      = 1001;
static const int kEmailTextField     = 1002;
static const int kTeacherTextField   = 1003;

@interface mmmStudentOnboardingViewController ()

@end

@implementation mmmStudentOnboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Student Signup";
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(200.0f, 7.5f, 200.0f, 30.0f)];
    [textField setBorderStyle:UITextBorderStyleRoundedRect];
    [textField setDelegate:self];
    
    switch (indexPath.row) {
        case 0:
            [[cell textLabel] setText:@"Name"];
            [textField setTag:kNameTextField];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
            [textField setReturnKeyType:UIReturnKeyNext];
            break;
            
        case 1:
            [[cell textLabel] setText:@"E-mail"];
            [textField setTag:kEmailTextField];
            [textField setKeyboardType:UIKeyboardTypeEmailAddress];
            [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            [textField setReturnKeyType:UIReturnKeyNext];
            break;
            
        case 2:
            [[cell textLabel] setText:@"Teacher"];
            [textField setTag:kTeacherTextField];
            [textField setSecureTextEntry:YES];
            [textField setReturnKeyType:UIReturnKeyDone];
            break;
            
        default:
            break;
    }
    
    [cell addSubview:textField];
    
    return cell;
}

- (IBAction)saveTeacher:(id)sender
{
    NSDictionary *studentInfo = @{
                                  @"name"     : [(UITextField *)[self.view viewWithTag:kNameTextField] text],
                                  @"email"    : [(UITextField *)[self.view viewWithTag:kEmailTextField] text]};
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(studentSaveComplete:) name:@"AddStudent" object:nil];
    
    APIUtility *api = [[APIUtility alloc] init];
    [api createStudent:studentInfo];
}

- (void)studentSaveComplete:(NSNotification *)notif
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddStudent" object:nil];
    if ([notif.userInfo isKindOfClass:[NSDictionary class]])
    {
        if ([[(NSDictionary *)notif.userInfo allKeys] containsObject:@"token"])
        {
            NSMutableDictionary *dict = [(NSDictionary *)notif.userInfo mutableCopy];
            NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
            [dict setValue:@"student" forKey:@"type"];
            [defaults setObject:notif.userInfo forKey:@"userDetails"];
            [defaults setBool:YES forKey:@"hasOnboarded"];
            [defaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.tag == kNameTextField)
        [(UITextField *)[self.view viewWithTag:kEmailTextField] becomeFirstResponder];
    else if (textField.tag == kEmailTextField)
        [(UITextField *)[self.view viewWithTag:kTeacherTextField] becomeFirstResponder];
    
    return YES;
}

@end
