//
//  ViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-14.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "ViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#include <MailCore/MailCore.h>

//static const int ddLogLevel = DDLogLevelVerbose;
static const int ddLogLevel = DDLogLevelDebug;

@implementation ViewController
{
    AudioManager * audioMan;
    NSTimer * countdown;
    Float32 currentDecibels;
    
    int errMarging;
    
    NSTimer * decibelUpdate;
    
    NSFileManager *fileManager;
    
    float decibelMin;
    int seconds;
    int marging;;
    
    bool isRunning;
    
    bool silenceFired;
    
    NSDateFormatter *df;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    errMarging = 0;
    
    audioMan = [AudioManager.alloc initWithDelegate:self];
    
    fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"input.json"];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *jsonData = [fileManager contentsAtPath:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];

        if ([[json objectForKey:@"au_demarrage"] intValue] == 1) {
            [self start];
        }
    }
    
    decibelUpdate = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateDecibelValue:) userInfo:nil repeats:YES];

    df = [NSDateFormatter.alloc init];
//    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_CA"]];
    [df setDateStyle:NSDateFormatterFullStyle];
    [df setTimeStyle:NSDateFormatterMediumStyle];

    [df setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EDT"]];

    
    
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
    [self.overviewController updateDecibelValue:currentDecibels];
//    });
}

- (void) silence:(NSTimer*)sender
{
                dispatch_async(dispatch_get_main_queue(),^{
    DDLogError(@"THATS A SILENCE");
    silenceFired = YES;
    errMarging = 0;
    [self sendMailWithMessage:nil];
//    [countdown invalidate];
                    //    countdown = nil;
                });

}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"mainSegue"])
    {
        //1
        NSTabViewController * tabViewController = segue.destinationController;
        //2
        for (NSViewController * controller in tabViewController.childViewControllers) {
            //3
            if ([controller isKindOfClass:[OverviewViewController class]]) {
                self.overviewController = (OverviewViewController *)controller;
                self.overviewController.delegate = self;
                
                [self.overviewController setIsRunning:isRunning];
            }
        }
    }
}

- (void) sendMailWithMessage:(NSString*)msgS
{
    
    NSString *smtpAdressS;
    int portI = 0;
    NSString *hostnameS;
    NSString *pwdS;
    NSString *subjectS;
    NSArray * targetMails;
    
    fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"mail.json"];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *jsonData = [fileManager contentsAtPath:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        smtpAdressS =[json objectForKey:@"adresse_smtp"];
        portI = [[json objectForKey:@"port"] intValue];
        hostnameS = [json objectForKey:@"nom_utilisateur"];
        pwdS = [json objectForKey:@"passe"];
        subjectS = [json objectForKey:@"sujet"];
        if (!msgS) {
            msgS = [json objectForKey:@"message"];
        }
        
        targetMails = [json objectForKey:@"destinataires"];
        
        MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
        smtpSession.hostname = smtpAdressS;
        smtpSession.port = portI;
        smtpSession.username = hostnameS;
        smtpSession.password = pwdS;
        smtpSession.authType = MCOAuthTypeSASLPlain;
        smtpSession.connectionType = MCOConnectionTypeTLS;
        
        MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
        MCOAddress *from = [MCOAddress addressWithDisplayName:@"CHYZSuperSilenceDetector" mailbox:hostnameS];
        [[builder header] setFrom:from];
        
        NSMutableArray * adressArray = [NSMutableArray.alloc init];
        for (NSString *recipient in targetMails) {
            MCOAddress *to = [MCOAddress addressWithDisplayName:nil mailbox:recipient];
            [adressArray addObject:to];
        }
        
        [[builder header] setTo:adressArray];
        [[builder header] setSubject:subjectS];
        NSString *fDate = [df stringFromDate:[NSDate date]];
        [builder setHTMLBody:[NSString stringWithFormat:@"%@ - %@", fDate, msgS]];
        NSData * rfc822Data = [builder data];
        
        MCOSMTPSendOperation *sendOperation =
        [smtpSession sendOperationWithData:rfc822Data];
        [sendOperation start:^(NSError *error) {
            if(error) {
                [self.overviewController writeToErrorLabel:[NSString stringWithFormat:@"Error sending email: %@", error.localizedDescription]];
                DDLogError(@"Error sending email: %@", error);
            } else {
                DDLogInfo(@"Successfully sent email!");
            }
        }];
        
    } else {
        DDLogError(@"No configuration file");
    }
    
}

#pragma mark - OverviewviewController

- (float) getThreshold
{
    return decibelMin;
}

- (void) start
{
    bool    noError = YES;
    
    fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"input.json"];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *jsonData = [fileManager contentsAtPath:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        NSString *deviceName = [json objectForKey:@"nom_entree"];
        noError = [audioMan setDeviceWithName:deviceName];
        
        decibelMin = [[json objectForKey:@"decibel"] intValue];
        seconds = [[json objectForKey:@"secondes"] intValue];
        marging = [[json objectForKey:@"tolerance"] intValue];
    }
    if (noError) {
    isRunning = YES;
    [self.overviewController setIsRunning:isRunning];
    [audioMan startListening];
    } else {
        [self.overviewController writeToErrorLabel:@"Impossible de trouver le périphérique d'entrée spécifié."];
    }
    
}

- (void) stop
{
    isRunning = NO;
    [self.overviewController setIsRunning:isRunning];
    [audioMan stopListening];
    
    if (countdown)
    {
        [countdown invalidate];
        countdown = nil;
        errMarging = 0;
        
    }
}


#pragma mark - AudioManagerDelegate


- (void) setDecibelLevel:(Float32)decibels
{
    currentDecibels = decibels;
    if (decibels < decibelMin) {
        if (!countdown) {
            DDLogVerbose(@"Create Timer");
//            dispatch_async(dispatch_get_main_queue(),^{
                countdown = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(silence:) userInfo:nil repeats:NO];
//            });
        }
    } else if (countdown)
    {
        errMarging++;
        if (errMarging > marging) {
            DDLogVerbose(@"destroy Timer");
            if (silenceFired) {
                silenceFired = NO;
                DDLogError(@"Sound is back up");
                [self sendMailWithMessage:@"Le son est revenu"];
            }
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

- (void) updatePlotBuffer:(float*)buffer withBufferSize:(float)bufferSize
{
    [self.overviewController updatePlotBuffer:buffer withBufferSize:bufferSize];
}

@end
