//
//  mmmTeacherOnboardingViewController.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmTeacherOnboardingViewController.h"

static const int kTableTextField     = 1000;
static const int kNameTextField      = 1001;
static const int kEmailTextField     = 1002;
static const int kPasswordTextField  = 1003;

@interface mmmTeacherOnboardingViewController ()

@end

@implementation mmmTeacherOnboardingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Teacher Signup";
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
            [[cell textLabel] setText:@"Password"];
            [textField setTag:kPasswordTextField];
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
    NSDictionary *teacherInfo = @{
                                  @"name"     : [(UITextField *)[self.view viewWithTag:kNameTextField] text],
                                  @"email"    : [(UITextField *)[self.view viewWithTag:kEmailTextField] text],
                                  @"password" : [(UITextField *)[self.view viewWithTag:kPasswordTextField] text]
                                };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teacherSaveComplete:) name:@"AddTeacher" object:nil];
    
    APIUtility *api = [[APIUtility alloc] init];
    [api createTeacher:teacherInfo];
}

- (void)teacherSaveComplete:(NSNotification *)notif
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddTeacher" object:nil];
    if ([notif.userInfo isKindOfClass:[NSDictionary class]])
    {
        if ([[(NSDictionary *)notif.userInfo allKeys] containsObject:@"token"])
        {
            NSMutableDictionary *dict = [(NSDictionary *)notif.userInfo mutableCopy];
            NSUserDefaults *defaults  = [NSUserDefaults standardUserDefaults];
            [dict setValue:@"teacher" forKey:@"type"];
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
        [(UITextField *)[self.view viewWithTag:kPasswordTextField] becomeFirstResponder];
    
    return YES;
}


@end
