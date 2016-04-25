//
//  InputViewController.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-19.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InputViewController : NSViewController
@property (weak) IBOutlet NSPopUpButton *deviceList;
@property (weak) IBOutlet NSTextField *minDB;
@property (weak) IBOutlet NSTextField *time;
@property (weak) IBOutlet NSTextField *marging;
@property (weak) IBOutlet NSButton *shouldStart;

- (IBAction)saveCurrentValue:(id)sender;

@end
