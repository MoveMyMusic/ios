//
//  mmmMasterViewController.h
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mmmSongCreatorViewController;

#import <CoreData/CoreData.h>

@interface mmmMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) mmmSongCreatorViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
