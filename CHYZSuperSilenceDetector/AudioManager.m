//
//  AudioManager.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "AudioManager.h"

static const int ddLogLevel = DDLogLevelDebug;


@implementation AudioManager
{
    EZRecorder * audio;
    EZAudioDevice *selectedDevice;
    EZMicrophone *microphone;
    
    float min;
    float max;
}

-(id) init
{
    self = [super init];
    if( self )
    {
        
    }
    
    return self;
}

-(id) initWithDelegate:(id<AudioManagerDelegate>)sender
{
    self = [self init];
    if( self )
    {
        self.delegate = sender;
        min = 10000000;
    }
    
    return self;
}

- (void) startListening
{
    [microphone startFetchingAudio];
}

- (void) stopListening
{
    [microphone stopFetchingAudio];
}

- (bool) setDeviceWithName:(NSString *)deviceTitle
{
    NSArray *inputDevices = [EZAudioDevice inputDevices];
    for (EZAudioDevice *input in inputDevices)
    {
        if ([input.name isEqualToString:deviceTitle]) {
            selectedDevice = input;
            break;
        }
    }
    
    if (selectedDevice)
    {
        [self.delegate setCurrentSelectedDevice:selectedDevice.name];
        
        microphone = [EZMicrophone microphoneWithDelegate:self];
        [microphone setDevice:selectedDevice];
        return YES;
    } else
        return NO;
}

- (void) microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    // This is not always guaranteed to occur on the main thread so make sure you
    // wrap it in a GCD block
    dispatch_async(dispatch_get_main_queue(), ^{
        // Update UI here
        DDLogInfo(@"Changed input device: %@", device);
    });
}

-(void) microphone:(EZMicrophone *)microphone hasAudioReceived:(float **)buffer withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels
{
    __weak typeof (self) weakSelf = self;
    // Getting audio data as an array of float buffer arrays that can be fed into the
    // EZAudioPlot, EZAudioPlotGL, or whatever visualization you would like to do with
    // the microphone data.
    
    float decibels = fabsf(*buffer[0])*1000;
    
    dispatch_async(dispatch_get_main_queue(),^{
        // Visualize this data brah, buffer[0] = left channel, buffer[1] = right channel
        //
        if (decibels > max) {
            max = decibels;
            DDLogInfo(@"MAX set to : %f", max);
        }
        if (decibels < min) {
            min = decibels;
            DDLogInfo(@"MIN set to : %f", min);
        }
        
        [weakSelf updatePlotBuffer:buffer[0] withBufferSize:bufferSize];
        
        [self.delegate setDecibelLevel:decibels];
    });
    
}

- (void) updatePlotBuffer:(float*)buffer withBufferSize:(float)bufferSize
{
    [self.delegate updatePlotBuffer:buffer withBufferSize:bufferSize];
}

-(void)    microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels
{
////    OSStatus err = AudioUnitRender(audioUnitWrapper->audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
//    
////    if(err != 0) DDLogError(@"AudioUnitRender status is %d", err);
//    // These values should be in a more conventional location
//    //for a bunch of preprocessor defines in your real code
//#define DBOFFSET 0.0
//    // DBOFFSET is An offset that will be used to normalize
//    // the decibels to a maximum of zero.
//    // This is an estimate, you can do your own or construct
//    // an experiment to find the right value
//#define LOWPASSFILTERTIMESLICE .001
//    // LOWPASSFILTERTIMESLICE is part of the low pass filter
//    // and should be a small positive value
//    
//    SInt16* samples = (SInt16*)(bufferList->mBuffers[0].mData); // Step 1: get an array of
//    // your samples that you can loop through. Each sample contains the amplitude.
//    
//    Float32 decibels = DBOFFSET; // When we have no signal we'll leave this on the lowest setting
//    Float32 currentFilteredValueOfSampleAmplitude, previousFilteredValueOfSampleAmplitude; // We'll need
//    // these in the low-pass filter
//    
//    Float32 peakValue = DBOFFSET; // We'll end up storing the peak value here
//    
////    for (int i=0; i < numberOfChannels; i++) {
//    
//        Float32 absoluteValueOfSampleAmplitude = abs(samples[0]); //Step 2: for each sample,
//        // get its amplitude's absolute value.
//        
//        // Step 3: for each sample's absolute value, run it through a simple low-pass filter
//        // Begin low-pass filter
//    currentFilteredValueOfSampleAmplitude = LOWPASSFILTERTIMESLICE * absoluteValueOfSampleAmplitude + (1.0 - LOWPASSFILTERTIMESLICE);// * previousFilteredValueOfSampleAmplitude;
////        previousFilteredValueOfSampleAmplitude = currentFilteredValueOfSampleAmplitude;
//        Float32 amplitudeToConvertToDB = currentFilteredValueOfSampleAmplitude;
//        // End low-pass filter
//        
//        Float32 sampleDB = 20.0*log10(amplitudeToConvertToDB) + DBOFFSET;
//        // Step 4: for each sample's filtered absolute value, convert it into decibels
//        // Step 5: for each sample's filtered absolute value in decibels,
//        // add an offset value that normalizes the clipping point of the device to zero.
//        
//        if((sampleDB == sampleDB) && (sampleDB != -DBL_MAX)) { // if it's a rational number and
//            // isn't infinite
//            
//            if(sampleDB > peakValue) peakValue = sampleDB; // Step 6: keep the highest value
//            // you find.
//            decibels = peakValue; // final value
//        }
////    }
//    
//    [self.delegate setDecibelLevel:decibels];
//    
////    for (UInt32 i=0; i < bufferList->mNumberBuffers; i++) { // This is only if you need to silence
////        // the output of the audio unit
////        memset(bufferList->mBuffers[i].mData, 0, bufferList->mBuffers[i].mDataByteSize); // Delete if you
////        // need audio output as well as input
////    }
//    

}

@end
