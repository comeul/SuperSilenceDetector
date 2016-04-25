//
//  ViewController.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioManager.h"
#import "OverviewViewController.h"

@interface ViewController : NSViewController <AudioManagerDelegate, OverviewViewControllerDelegate, NSSharingServiceDelegate>

@property (weak) IBOutlet NSTextField *currentDevice;
@property (weak) IBOutlet NSTextField *currentDecibelValue;

@property (weak) OverviewViewController *overviewController;

@end

