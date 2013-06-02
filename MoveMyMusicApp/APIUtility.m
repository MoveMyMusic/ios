//
//  APIUtility.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/1/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "APIUtility.h"
#import "JSONKit.h"
#import "UIDevice+IdentifierAddition.h"
#import "mmmSpecialRequest.h"


@implementation APIUtility

- (id)init
{
    if (!self)
        self = [super init];
    
    dataDict = [[NSMutableDictionary alloc] init];
    
    currentDomain = @"morning-coast-5981.herokuapp.com";
    d_requestsQueue = [[NSMutableArray alloc] init];
    d_operationQueue = [NSOperationQueue new];
    
    return self;
}

- (BOOL)isOnline
{
    /*cbAppDelegate *delegate = (cbAppDelegate *)[[UIApplication sharedApplication] delegate];
     NetworkStatus *netStatus    = [[delegate cb_reachServer] currentReachabilityStatus];*/
    
    //return (netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN);
    return YES;
}

- (void)processData:(NSData *)data andSendNotification:(NSString *)callback
{
    NSString *jsonString      = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    JSONDecoder *json         = [[JSONDecoder alloc] init];
    NSDictionary *jsonDict    = [json objectWithData:data];
    
    // Send the notification for this event
    if ([jsonDict isKindOfClass:[NSDictionary class]] || [jsonDict isKindOfClass:[NSMutableArray class]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:callback object:nil userInfo:jsonDict];
    } else {
        if (jsonString != nil)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:jsonString forKey:@"Return"];
            [[NSNotificationCenter defaultCenter] postNotificationName:callback object:dict userInfo:[NSError errorWithDomain:@"ERROR SUCK OMG!" code:nil userInfo:nil]];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:callback object:[NSError errorWithDomain:@"ERROR SUCK OMG!" code:nil userInfo:nil] userInfo:nil];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Get the current data for this notification
    NSMutableData *objectData = [dataDict objectForKey:[(mmmSpecialRequest *)connection.currentRequest notificationCallback]];
    
    // If it doesn't exist (this shouldn't happen but a lot of things shouldn't) create it.
    if (objectData == nil)
        objectData = [[NSMutableData alloc] init];
    
    // Add the new data
    [objectData appendData:data];
    
    // Save it in the object
    [dataDict setObject:objectData forKey:[(mmmSpecialRequest *)connection.currentRequest notificationCallback]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (![connection.currentRequest isKindOfClass:[mmmSpecialRequest class]])
    {
        NSLog(@"This is a weird encounter.  We need to pay attention to this.");
        return;
    }
    
    // Get the object data
    NSMutableData *objectData = [dataDict objectForKey:[(mmmSpecialRequest *)connection.currentRequest notificationCallback]];
    [dataDict removeObjectForKey:[(mmmSpecialRequest *)connection.currentRequest notificationCallback]];
    
    // STRING!
    NSString *jsonString           = [[NSString alloc] initWithData:objectData encoding:NSASCIIStringEncoding];//[NSString stringWithUTF8String:[objectData bytes]] stringByA;
    JSONDecoder *json              = [[JSONDecoder alloc] init];
    const unsigned char *jsonConst = (const unsigned char *)[jsonString UTF8String];
    NSDictionary *jsonDict         = [json objectWithUTF8String:jsonConst length:[jsonString length]];
    
    //[dataDict setObject:[[NSMutableData alloc] init] forKey:[(DrinkrSpecialRequest *)connection.currentRequest notificationCallback]];
    // Send the notification for this event
    if ([jsonDict isKindOfClass:[NSDictionary class]] || [jsonDict isKindOfClass:[NSMutableArray class]])
        [[NSNotificationCenter defaultCenter] postNotificationName:[(mmmSpecialRequest *)connection.currentRequest notificationCallback] object:nil userInfo:jsonDict];
    else
    {
        if (jsonString != nil)
        {
            NSDictionary *dict = [NSDictionary dictionaryWithObject:jsonString forKey:@"Return"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[(mmmSpecialRequest *)connection.currentRequest notificationCallback] object:dict userInfo:dict];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[(mmmSpecialRequest *)connection.currentRequest notificationCallback] object:nil userInfo:nil];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (![[d_operationQueue operations] containsObject:connection] && ![d_requestsQueue containsObject:connection])
        return;
    [[NSNotificationCenter defaultCenter] postNotificationName:[(mmmSpecialRequest *)connection.currentRequest notificationCallback] object:error userInfo:nil];
}

- (NSString *)uuid
{
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

+ (NSString *)uuid
{
    return [[UIDevice currentDevice] uniqueDeviceIdentifier];
}

# pragma Actual API Calls

- (void)createTeacher:(NSDictionary *)dict
{
    if (![self isOnline])
        return;
    NSString *credentials = [dict JSONString];
    NSData *postData      = [credentials dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength  = [NSString stringWithFormat:@"%d", [postData length]];
    

    mmmSpecialRequest *request = [[mmmSpecialRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/teachers", currentDomain]]];
    [request setNotificationCallback:@"AddTeacher"];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:d_operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self processData:data andSendNotification:request.notificationCallback];
    }];
}

- (void)createStudent:(NSDictionary *)dict
{
    if (![self isOnline])
        return;
    NSString *credentials = [dict JSONString];
    NSData *postData      = [credentials dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSString *postLength  = [NSString stringWithFormat:@"%d", [postData length]];
    NSLog(@"%@", credentials);
    
    mmmSpecialRequest *request = [[mmmSpecialRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/students", currentDomain]]];
    [request setNotificationCallback:@"AddStudent"];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:d_operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [self processData:data andSendNotification:request.notificationCallback];
    }];    
}

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor {
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
