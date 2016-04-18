//
//  ViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
{
    AudioManager * audioMan;
    NSTimer * countdown;
    Float32 currentDecibels;
    
    int errMarging;
    
    NSTimer * decibelUpdate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    errMarging = 0;
    
    audioMan = [AudioManager.alloc initWithDelegate:self];
    
    decibelUpdate = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateDecibelValue:) userInfo:nil repeats:YES];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void) updateDecibelValue:(NSTimer*)sender
{
//    dispatch_async(dispatch_get_main_queue(),^{
        [self.currentDecibelValue setStringValue:[NSString stringWithFormat:@"%f", currentDecibels]];
//    });
}

- (void) silence:(NSTimer*)sender
{
    NSLog(@"THATS A SILENCE");
    [countdown invalidate];
    countdown = nil;
    errMarging = 0;

}

#pragma mark - AudioManagerDelegate


- (void) setDecibelLevel:(Float32)decibels
{
    currentDecibels = decibels;
    if (decibels < 10) {
        if (!countdown) {
            NSLog(@"Create Timer");
            countdown = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(silence:) userInfo:nil repeats:NO];
        }
    } else if (countdown)
    {
        errMarging++;
        if (errMarging > 20) {
            NSLog(@"destroy Timer");
            [countdown invalidate];
            countdown = nil;
            errMarging = 0;
        }
    }
}

- (void) setCurrentSelectedDevice:(NSString*)device
{
    [self.currentDevice setStringValue:device];
}

@end
