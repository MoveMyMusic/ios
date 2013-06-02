//
//  APIUtility.h
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIUtility : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
    NSMutableDictionary *dataDict;
    NSString *currentDomain;
    NSMutableArray *d_requestsQueue;
    NSOperationQueue *d_operationQueue;
}

- (void)cancelConnectionWithCallback:(NSString *)callback;
- (void)cancelAllConnections;
- (void)processData:(NSData *)data andSendNotification:(NSString *)callback;

- (NSString *)uuid;
+ (NSString *)uuid;

@end
