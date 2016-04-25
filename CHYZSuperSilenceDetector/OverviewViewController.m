//
//  OverviewViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-18.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "OverviewViewController.h"

@interface OverviewViewController ()

@end

@implementation OverviewViewController {
    bool isRunning;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.thresholdLabel setStringValue:[NSString stringWithFormat:@"%f", [self.delegate getThreshold]]];
    
    // Background color (use UIColor for iOS)
    self.visualizer.backgroundColor = [NSColor colorWithRed:137.0/255.0 green:112.0/255.0 blue:178.0/255.0 alpha:1];
    // Waveform color (use UIColor for iOS)
    self.visualizer.color = [NSColor colorWithRed:191.0/255.0 green:215.0/255.0 blue:48.0/255.0 alpha:1];
    // Plot type
    self.visualizer.plotType = EZPlotTypeBuffer;
    // Fill
    self.visualizer.shouldFill = YES;
    // Mirror
    self.visualizer.shouldMirror = YES;
    
    if (isRunning) {
        [self.startButton setTitle:@"Stop"];
    }
}

- (void) updateDecibelValue:(float)value
{
    [self.audioLabel setStringValue:[NSString stringWithFormat:@"%f", value]];
}

- (void) setIsRunning:(bool)value
{
    if  (value)
        [self.thresholdLabel setStringValue:[NSString stringWithFormat:@"%f", [self.delegate getThreshold]]];
    isRunning = value;
}

- (void) writeToErrorLabel:(NSString*)error
{
    [self.errorLabel setStringValue:error];
}

- (void) updatePlotBuffer:(float*)buffer withBufferSize:(float)bufferSize
{
    [self.visualizer updateBuffer:buffer withBufferSize:bufferSize];
}

- (IBAction)stopStart:(id)sender {
    if (isRunning) {
        [self.startButton setTitle:@"Start"];
        [self.delegate stop];
    } else {
        [self.startButton setTitle:@"Stop"];
        [self.delegate start];
    }
}
@end
