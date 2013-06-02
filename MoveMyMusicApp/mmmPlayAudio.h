//
//  mmmPlayAudio.h
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/2/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface mmmPlayAudio : NSObject
{
    bool isPlaying;
    AudioComponentInstance toneUnit;
    NSDictionary *mmm_toneNotes;
@public
	double frequency;
	double sampleRate;
	double theta;
    int currentNoteIndex;
}

@property (nonatomic,retain) NSArray *mmm_notes;

- (void)play;
- (void)pause;
- (void)stop;

@end
