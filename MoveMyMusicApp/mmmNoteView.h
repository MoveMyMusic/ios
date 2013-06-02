//
//  mmmNoteView.h
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/2/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface mmmNoteView : UIImageView <UIGestureRecognizerDelegate>
{
    BOOL validLocation; // if true, allow playing; if false, draw faded
    BOOL drawFlipped; // for notes with stems (true for high on staff, false for low)
    BOOL hasStem; // false for whole notes, rests, sharps and flats
    CGPoint noteCenter; // for determining if the note is in an acceptable location on the staff
    // 43 pixels from left, 138 pixels from top for 1024 pixel screens
    CGPoint startLocation; // holds location where user originally touched the image
    CGPoint beginLocation; // holds the original location of the note
    NSArray *noteColors;
    NSArray *notePositions;
}

@property (nonatomic, assign) double duration; // 1.0 for whole note, 0.5 for half note, etc
@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) UIColor * tintColor;
@property (nonatomic, retain) UIImage *originalImage;

- (void)removeNote:(UITapGestureRecognizer *)gesture;
- (void)createNewNote:(UILongPressGestureRecognizer *)gesture;

@end