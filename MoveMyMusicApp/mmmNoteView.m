//
//  mmmNoteView.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/2/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmNoteView.h"

@implementation mmmNoteView

@synthesize duration;
@synthesize originalImage;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressDetected:)];
        [pressRecognizer setMinimumPressDuration:0.5];
        [pressRecognizer setDelegate:self];
        [self addGestureRecognizer:pressRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeNote:)];
        [self addGestureRecognizer:tapRecognizer];

        beginLocation = self.frame.origin;
        originalImage = self.image;
        
        noteColors = @[UIColorFromRGB(0xC80046),
                       UIColorFromRGB(0xC81600),
                       UIColorFromRGB(0xC86500),
                       UIColorFromRGB(0xC8B400),
                       UIColorFromRGB(0x7EC800),
                       UIColorFromRGB(0x24C800),
                       UIColorFromRGB(0x00C744),
                       UIColorFromRGB(0x00C89B),
                       UIColorFromRGB(0x0097C8),
                       UIColorFromRGB(0x004CC7),
                       UIColorFromRGB(0x0900C8),
                       UIColorFromRGB(0x6200C8)];
        
        notePositions = @[@"G5", @"F5", @"E5", @"D5", @"C5", @"B4", @"A4", @"G4", @"F4", @"E4", @"D4", @"C4"];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressDetected:)];
        [pressRecognizer setMinimumPressDuration:0.5];
        [pressRecognizer setDelegate:self];
        [self addGestureRecognizer:pressRecognizer];
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeNote:)];
        [self addGestureRecognizer:tapRecognizer];
        
        beginLocation = self.frame.origin;
        
        noteColors = @[UIColorFromRGB(0xC80046),
                       UIColorFromRGB(0xC81600),
                       UIColorFromRGB(0xC86500),
                       UIColorFromRGB(0xC8B400),
                       UIColorFromRGB(0x7EC800),
                       UIColorFromRGB(0x24C800),
                       UIColorFromRGB(0x00C744),
                       UIColorFromRGB(0x00C89B),
                       UIColorFromRGB(0x0097C8),
                       UIColorFromRGB(0x004CC7),
                       UIColorFromRGB(0x0900C8),
                       UIColorFromRGB(0x6200C8)];
        
        notePositions = @[@"G5", @"F5", @"E5", @"D5", @"C5", @"B4", @"A4", @"G4", @"F4", @"E4", @"D4", @"C4"];
    }
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)embiggen:(UILongPressGestureRecognizer *)gesture {
    [self setAlpha:0.75f];
    [self.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [self.layer setShadowOpacity:0.75];
    [self.layer setShadowRadius:5.0f];
    [self setFrame:CGRectMake(self.frame.origin.x - 20.0f, self.frame.origin.y - 20.0f, self.frame.size.width + 40.0f, self.frame.size.height + 40.0f)];
}

- (IBAction)pressDetected:(UILongPressGestureRecognizer *)gesture {
    [UIView beginAnimations:nil context:nil];
    if ([gesture state]==UIGestureRecognizerStateBegan) {
        [self setImage:originalImage];
        startLocation = CGPointMake(self.frame.origin.x - 10.0f, self.frame.origin.y - 10.0f);
        if (startLocation.y < 180.0f) // create a new note view...
            [self createNewNote:gesture];
        [self embiggen:gesture];
    } else if ([gesture state]==UIGestureRecognizerStateChanged) {
        [self setImage:[APIUtility colorizeImage:originalImage color:[self colorAtCurrentPosition]]];
        [self noteAtCurrentPosition];
        CGPoint location = [gesture locationInView:self.superview];
        [self setFrame:CGRectMake(location.x - (self.frame.size.width / 2) + 15.0f, location.y - (self.frame.size.height) + 40.0f, self.frame.size.width, self.frame.size.height)];
    } else if ([gesture state]==UIGestureRecognizerStateEnded) {
        if (self.frame.origin.y < 150.0f)
        {
            [self setFrame:CGRectMake(beginLocation.x, beginLocation.y, self.frame.size.width - 40.0f, self.frame.size.height - 40.0f)];
            [self setAlpha:0.0f];
        } else {
            [self setAlpha:1.0f];
            NSLog(@"%.2f", self.frame.origin.y + 20.0f);
            [self setFrame:CGRectMake(self.frame.origin.x + 20.0f, self.frame.origin.y + 20.0f, self.frame.size.width - 40.0f, self.frame.size.height - 40.0f)];
        }
        [self.layer setShadowColor:nil];
        [self.layer setShadowOffset:CGSizeMake(0, 0)];
        [self.layer setShadowOpacity:0.0];
        [self.layer setShadowRadius:0.0];
    }
    [UIView commitAnimations];
}

- (void)removeNote:(UITapGestureRecognizer *)gesture
{
    [UIView beginAnimations:nil context:nil];
    
    [self setFrame:CGRectMake(beginLocation.x, beginLocation.y, self.frame.size.width - 40.0f, self.frame.size.height - 40.0f)];
    [self setAlpha:0.0f];
    
    [UIView commitAnimations];
}

- (void)createNewNote:(UILongPressGestureRecognizer *)gesture {
    mmmNoteView *newNote = [[mmmNoteView alloc] initWithFrame:[self frame]];
    [newNote setTag:[self tag]+10];
    [newNote setImage:[self image]];
    [newNote setOriginalImage:originalImage];
    [newNote setDuration:[self duration]];
    [newNote setUserInteractionEnabled:YES];
    [self.superview addSubview:newNote];
}

- (UIColor *)colorAtCurrentPosition
{
    double position = (self.frame.origin.y - 250) / 25;
    //float closeness = (int)(self.frame.origin.y - 225) % 325;
    if ((int)position >= 0 && (int)position < [noteColors count])
        return [noteColors objectAtIndex:(int)position];
    return [UIColor clearColor];
}

- (NSString *)noteAtCurrentPosition
{
    double position = (self.frame.origin.y - 250) / 25;
    if ((int)position >= 0 && (int)position < [notePositions count])
    {
        NSLog(@"%@", [notePositions objectAtIndex:(int)position]);
        return [notePositions objectAtIndex:(int)position];
    }
    
    return @"";
}

@end
