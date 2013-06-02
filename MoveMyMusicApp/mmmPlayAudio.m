//
//  mmmPlayAudio.m
//  MoveMyMusicApp
//
//  Created by Nicholas Krut on 6/2/13.
//  Copyright (c) 2013 movemymusic. All rights reserved.
//

#import "mmmPlayAudio.h"

OSStatus RenderTone(
                    void *inRefCon,
                    AudioUnitRenderActionFlags 	*ioActionFlags,
                    const AudioTimeStamp 		*inTimeStamp,
                    UInt32 						inBusNumber,
                    UInt32 						inNumberFrames,
                    AudioBufferList 			*ioData)

{
	// Fixed amplitude is good enough for our purposes
	const double amplitude = 0.25;
    
	// Get the tone parameters out of the view controller
	mmmPlayAudio *audioPlayer = (__bridge mmmPlayAudio *)inRefCon;
	double theta = audioPlayer->theta;
	double theta_increment = 2.0 * M_PI * audioPlayer->frequency / audioPlayer->sampleRate;
    
	// This is a mono tone generator so we only need the first buffer
	const int channel = 0;
	Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
	
	// Generate the samples
	for (UInt32 frame = 0; frame < inNumberFrames; frame++)
	{
		buffer[frame] = sin(theta) * amplitude;
		
		theta += theta_increment;
		if (theta > 2.0 * M_PI)
		{
			theta -= 2.0 * M_PI;
		}
	}
	
	// Store the theta back in the view controller
	audioPlayer->theta = theta;
    
	return noErr;
}


void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	mmmPlayAudio *audioPlayer = (__bridge mmmPlayAudio *)inClientData;
	[audioPlayer stop];
}

@implementation mmmPlayAudio

@synthesize mmm_notes;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        sampleRate = 352800;
        
        OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
        if (result == kAudioSessionNoError)
        {
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
        }
        AudioSessionSetActive(true);
        
        currentNoteIndex = 0;
        
        mmm_toneNotes = @{
                          @"C4" : [NSNumber numberWithDouble:261.6],
                          @"D4" : [NSNumber numberWithDouble:293.7],
                          @"E4" : [NSNumber numberWithDouble:329.6],
                          @"F4" : [NSNumber numberWithDouble:349.2],
                          @"G4" : [NSNumber numberWithDouble:392.0],
                          @"A4" : [NSNumber numberWithDouble:440.0],
                          @"B4" : [NSNumber numberWithDouble:493.9],
                          @"C5" : [NSNumber numberWithDouble:523.3],
                          @"D5" : [NSNumber numberWithDouble:587.3],
                          @"E5" : [NSNumber numberWithDouble:659.3],
                          @"F5" : [NSNumber numberWithDouble:698.5],
                          @"G5" : [NSNumber numberWithDouble:784.0]
                          };
        
    }
    
    return self;
}

- (void)play
{
    [self playFirstNote];
}

- (void)pause
{
    
}

- (void)stop
{
    
}

- (void)playNextNote
{
    currentNoteIndex++;
    if (currentNoteIndex < [mmm_notes count])
    {
        NSDictionary *nextNote = [mmm_notes objectAtIndex:currentNoteIndex];
        [self playFrequency:[self noteToFreq:[nextNote valueForKey:@"note"]] forLength:[[nextNote valueForKey:@"time"] doubleValue]];
    }
}

- (void)playFirstNote
{
    currentNoteIndex = 0;
    NSDictionary *nextNote = [mmm_notes objectAtIndex:currentNoteIndex];
    [self playFrequency:[self noteToFreq:[nextNote valueForKey:@"note"]] forLength:[[nextNote valueForKey:@"time"] doubleValue]];
}

- (double)noteToFreq:(NSString *)note
{
    NSLog(@"%.2f", [[mmm_toneNotes valueForKey:[note lowercaseString]] doubleValue]);
    return [[mmm_toneNotes valueForKey:[note lowercaseString]] doubleValue];
}

- (void)playFrequency:(double)freq forLength:(double)time
{
    frequency = freq;
	AudioComponentDescription defaultOutputDescription;
	defaultOutputDescription.componentType = kAudioUnitType_Output;
	defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
	defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
	defaultOutputDescription.componentFlags = 0;
	defaultOutputDescription.componentFlagsMask = 0;
	
	// Get the default playback output unit
	AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
	NSAssert(defaultOutput, @"Can't find default output");
	
	// Create a new unit based on this that we'll use for output
	OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
	NSAssert1(toneUnit, @"Error creating unit: %ld", err);
	
	// Set our tone rendering function on the unit
	AURenderCallbackStruct input;
    
	input.inputProc = RenderTone;
	input.inputProcRefCon = (__bridge void *)(self);
	err = AudioUnitSetProperty(toneUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               sizeof(input));
	NSAssert1(err == noErr, @"Error setting callback: %ld", err);
	
	// Set the format to 32 bit, single channel, floating point, linear PCM
	const int four_bytes_per_float = 4;
	const int eight_bits_per_byte = 8;
	AudioStreamBasicDescription streamFormat;
	streamFormat.mSampleRate = sampleRate;
	streamFormat.mFormatID = kAudioFormatLinearPCM;
	streamFormat.mFormatFlags =
    kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
	streamFormat.mBytesPerPacket = four_bytes_per_float;
	streamFormat.mFramesPerPacket = 1;
	streamFormat.mBytesPerFrame = four_bytes_per_float;
	streamFormat.mChannelsPerFrame = 1;
	streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
	err = AudioUnitSetProperty (toneUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                sizeof(AudioStreamBasicDescription));
	NSAssert1(err == noErr, @"Error setting stream format: %ld", err);
    
    // Stop changing parameters on the unit
    err = AudioUnitInitialize(toneUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %ld", err);
    
    // Start playback
    err = AudioOutputUnitStart(toneUnit);
    NSAssert1(err == noErr, @"Error starting unit: %ld", err);
    
    [self performSelector:@selector(playNextNote) withObject:nil afterDelay:time];
}

@end