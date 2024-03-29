//
//  mmmAppDelegate.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmAppDelegate.h"
#import "mmmMasterViewController.h"
#import "mmmSongCreatorViewController.h"
#import "mmmOnboardingViewController.h"

@implementation mmmAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize userInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    mmmMasterViewController *masterViewController = [[mmmMasterViewController alloc] initWithNibName:@"mmmMasterViewController" bundle:nil];
    UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
    [masterNavigationController setNavigationBarHidden:YES];
    
    mmmSongCreatorViewController *detailViewController = [[mmmSongCreatorViewController alloc] initWithNibName:@"mmmSongCreatorViewController" bundle:nil];
    UINavigationController *detailNavigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];    
    [detailNavigationController setNavigationBarHidden:YES];
    masterViewController.detailViewController = detailViewController;
    
    self.splitViewController = [[UISplitViewController alloc] init];
    self.splitViewController.delegate = detailViewController;
    self.splitViewController.viewControllers = @[masterNavigationController, detailNavigationController];
    masterViewController.managedObjectContext = self.managedObjectContext;
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    
    [self performSelector:@selector(checkOnboarding) withObject:nil afterDelay:0.5f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedUserDetails:) name:@"AddTeacher" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedUserDetails:) name:@"AddStudent" object:nil];
    
    [self changedUserDetails:nil];
    
    return YES;
}

- (void)changedUserDetails:(NSNotification *)notif
{
    userInfo = [(NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userDetails"] mutableCopy];
}

- (void)checkOnboarding
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasOnboarded"])
    {
        UINavigationController *onboardingView = [[UINavigationController alloc] initWithRootViewController:[[mmmOnboardingViewController alloc] initWithNibName:@"mmmOnboardingViewController" bundle:nil]];
        [onboardingView setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        [self.window.rootViewController presentViewController:onboardingView animated:YES completion:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MoveMyMusicApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MoveMyMusicApp.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

# pragma font stuff

- (void) appleShouldMakeItEasierToSetAGlobalFontForAnApp:(UIView *)view andFont:(NSString *)font {
    for (UIView *o in view.subviews) {
        if (o.tag < 10000)
        {
            if ([o isKindOfClass:[UILabel class]] || [o isKindOfClass:[UITextView class]] || [o isKindOfClass:[UITextField class]])
            {
                [(UILabel *)o setFont:[UIFont fontWithName:font size:[(UILabel *)o font].pointSize]];
            } else if ([o isKindOfClass:[UIButton class]]) {
                [[(UIButton *)o titleLabel] setFont:[UIFont fontWithName:font size:[[(UIButton *)o titleLabel] font].pointSize]];
            }
        }
        if ([[o subviews] count] > 0)
            [self appleShouldMakeItEasierToSetAGlobalFontForAnApp:o andFont:font];
    }
}

- (void) appleShouldMakeItEasierToSetAGlobalFontColorForAnApp:(UIView *)view withColor:(UIColor *)color {
    for (UIView *o in view.subviews) {
        if (o.tag < 10000)
        {
            if ([o isKindOfClass:[UILabel class]] || [o isKindOfClass:[UITextView class]] || [o isKindOfClass:[UITextField class]])
            {
                [(UILabel *)o setTextColor:color];
            } else if ([o isKindOfClass:[UIButton class]]) {
                [[(UIButton *)o titleLabel] setTextColor:color];
            }
        }
        if ([[o subviews] count] > 0)
            [self appleShouldMakeItEasierToSetAGlobalFontColorForAnApp:o withColor:color];
    }
}

- (void) appleShouldMakeItEasierToSetAClassFontColorForAnApp:(UIView *)view withColor:(UIColor *)color andClass:(Class)nameOfClass {
    for (UIView *o in view.subviews) {
        if (o.tag < 10000)
        {
            if ([o isKindOfClass:nameOfClass])
            {
                if ([o isKindOfClass:[UILabel class]] || [o isKindOfClass:[UITextView class]] || [o isKindOfClass:[UITextField class]])
                {
                    [(UILabel *)o setTextColor:color];
                } else if ([o isKindOfClass:[UIButton class]]) {
                    [[(UIButton *)o titleLabel] setTextColor:color];
                } else if ([o isKindOfClass:[UITextField class]]) {
                    [(UITextField *)o setTextColor:color];
                } else if ([o isKindOfClass:[UITextView class]]) {
                    [(UITextView *)o setTextColor:color];
                }
            }
        }
        if ([[o subviews] count] > 0)
            [self appleShouldMakeItEasierToSetAClassFontColorForAnApp:o withColor:color andClass:nameOfClass];
    }
}

- (void)bauhaus:(UIView *)view
{
    [self appleShouldMakeItEasierToSetAGlobalFontForAnApp:view andFont:BAUHAUS];
}

@end
