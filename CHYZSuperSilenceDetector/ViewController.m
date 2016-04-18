//
//  ViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "ViewController.h"
#include <MailCore/MailCore.h>

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
    [self sendMail];
//    [countdown invalidate];
//    countdown = nil;
//    errMarging = 0;

}

- (void) sendMail
{
//    NSLog(@"Proc");
//    NSArray *shareItems=@[@"Salut"];
//    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNameComposeEmail];
//    service.delegate = self;
//    service.recipients=@[@"webmestre@comeul.ca"];
//    service.subject= [ NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"SLYRunner console",nil), [NSDate date]];
//    [service performWithItems:shareItems];
//}
//
//- (void)sendEmailWithMail:(NSString *) senderAddress Address:(NSString *) toAddress Subject:(NSString *) subject Body:(NSString *) bodyText {
    
//    NSString *toAddress = @"webmestre@chyz.ca";
//    NSString *subject = @"Notif";
//    NSString *bodyText = @"Salut";
//
//    
//    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:%@?Subject=%@&body=%@",toAddress,subject,bodyText] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
//    NSLog(@"Mailto:%@",mailtoAddress);
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = @"antenne@chyz.ca";
    smtpSession.password = @"maillet20";
    smtpSession.authType = MCOAuthTypeSASLPlain;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:@"CHYZSuperSilenceDetector" mailbox:@"antenne@chyz.ca"];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil mailbox:@"webmestre@comeul.ca"];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:@"Notif"];
    [builder setHTMLBody:@"Silence"];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            NSLog(@"Error sending email: %@", error);
        } else {
            NSLog(@"Successfully sent email!");
        }
    }];
    
    
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
