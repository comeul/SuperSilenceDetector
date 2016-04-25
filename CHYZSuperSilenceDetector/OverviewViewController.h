//
//  OverviewViewController.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-18.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EZAudioPlot.h>

@protocol OverviewViewControllerDelegate <NSObject>
- (float) getThreshold;
- (void) setCurrentSelectedDevice:(NSString*)device;
- (void) start;
- (void) stop;

@end

@interface OverviewViewController : NSViewController

@property (weak, nonatomic) id<OverviewViewControllerDelegate> delegate;

@property (weak) IBOutlet EZAudioPlot *visualizer;

@property (weak) IBOutlet NSTextField *audioLabel;
@property (weak) IBOutlet NSTextField *thresholdLabel;
@property (weak) IBOutlet NSTextField *errorLabel;
@property (weak) IBOutlet NSButton *startButton;

- (void) updatePlotBuffer:(float*)buffer withBufferSize:(float)bufferSize;

- (IBAction)stopStart:(id)sender;

- (void) updateDecibelValue:(float)value;

- (void) setIsRunning:(bool)value;

- (void) writeToErrorLabel:(NSString*)error;

@end
