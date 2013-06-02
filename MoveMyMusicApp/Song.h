//
//  Song.h
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSNumber * song_id;
@property (nonatomic, retain) NSData * notes;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * created;

@end
