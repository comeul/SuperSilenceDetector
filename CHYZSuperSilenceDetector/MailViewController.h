//
//  MailViewController.h
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-19.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MailViewController : NSViewController
@property (weak) IBOutlet NSTextField *smtpAdress;
@property (weak) IBOutlet NSTextField *port;
@property (weak) IBOutlet NSTextField *hostname;
@property (weak) IBOutlet NSTextField *pwd;
@property (weak) IBOutlet NSTextField *subject;
@property (weak) IBOutlet NSTextField *msg;
@property (weak) IBOutlet NSTextField *recipients;

@property (weak) IBOutlet NSTextField *saveLabel;
@property (weak) IBOutlet NSTextField *testLabel;


- (IBAction)save:(id)sender;
- (IBAction)test:(id)sender;

@end
