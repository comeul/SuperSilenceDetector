//
//  AudioManager.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "EZAudioDevice.h"
#import "EZRecorder.h"
#import "EZMicrophone.h"

@protocol AudioManagerDelegate <NSObject>
- (void) setDecibelLevel:(Float32)decibels;
- (void) setCurrentSelectedDevice:(NSString*)device;
- (void) updatePlotBuffer:(float*)buffer withBufferSize:(float)bufferSize;


@end

@interface AudioManager : NSObject <EZMicrophoneDelegate>

@property (nonatomic, weak) id <AudioManagerDelegate> delegate;

-(id) initWithDelegate:(id<AudioManagerDelegate>)sender;

- (bool) setDeviceWithName:(NSString *)deviceTitle;
- (void) startListening;
- (void) stopListening;

@end
