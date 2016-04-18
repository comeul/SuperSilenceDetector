//
//  AudioManager.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EZAudioDevice.h"
#import "EZRecorder.h"
#import "EZMicrophone.h"

@protocol AudioManagerDelegate <NSObject>
- (void) setDecibelLevel:(Float32)decibels;
- (void) setCurrentSelectedDevice:(NSString*)device;


@end

@interface AudioManager : NSObject <EZMicrophoneDelegate>

@property (nonatomic, weak) id <AudioManagerDelegate> delegate;

-(id) initWithDelegate:(id<AudioManagerDelegate>)sender;

@end
