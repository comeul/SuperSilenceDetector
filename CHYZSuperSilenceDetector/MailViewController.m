//
//  MailViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-19.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "MailViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#include <MailCore/MailCore.h>

static const int ddLogLevel = DDLogLevelDebug;

@interface MailViewController ()

@end

@implementation MailViewController
{
    NSArray *inputDevices;
    
    NSFileManager *fileManager;
    NSString *filePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [documentsPath stringByAppendingPathComponent:@"mail.json"];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *jsonData = [fileManager contentsAtPath:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        [self.smtpAdress setStringValue:[json objectForKey:@"adresse_smtp"]];
        [self.port setStringValue:[json objectForKey:@"port"]];
        [self.hostname setStringValue:[json objectForKey:@"nom_utilisateur"]];
        [self.pwd setStringValue:[json objectForKey:@"passe"]];
        [self.subject setStringValue:[json objectForKey:@"sujet"]];
        [self.msg setStringValue:[json objectForKey:@"message"]];
        
        NSArray *recipientsArray = [json objectForKey:@"destinataires"];
        NSMutableString * recipientsS = [NSMutableString.alloc init];
        for (NSString *recipient in recipientsArray) {
            [recipientsS appendString:[NSString stringWithFormat:@"%@\n", recipient]];
        }
        if ([recipientsS length] > 0) {
            [recipientsS deleteCharactersInRange:NSMakeRange([recipientsS length]-1, 1)];
        }
        
        [self.recipients setStringValue:recipientsS];
    }
}

- (IBAction)save:(id)sender {
    NSString *smtpAdressS = [self.smtpAdress stringValue];
    int portI = [self.port intValue];
    NSString *hostnameS = [self.hostname stringValue];
    NSString *pwdS = [self.pwd stringValue];
    NSString *subjectS = [self.subject stringValue];
    NSString *msgS = [self.msg stringValue];
    NSString *mailsString = [self.recipients stringValue];
    NSArray * targetMails = [mailsString componentsSeparatedByString:@"\n"];

    NSMutableDictionary *optionJson = [NSMutableDictionary.alloc init];
    [optionJson setObject:smtpAdressS forKey:@"adresse_smtp"];
    [optionJson setObject:hostnameS forKey:@"nom_utilisateur"];
    [optionJson setObject:[NSString stringWithFormat:@"%d", portI] forKey:@"port"];
    [optionJson setObject:pwdS forKey:@"passe"];
    [optionJson setObject:subjectS forKey:@"sujet"];
    [optionJson setObject:msgS forKey:@"message"];
    [optionJson setObject:targetMails forKey:@"destinataires"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:optionJson options:0 error:nil];
    bool success = [fileManager createFileAtPath:filePath contents:jsonData attributes:nil];
    
    if (success) {
        [self.port setStringValue:[NSString stringWithFormat:@"%d", portI]];
        [self.saveLabel setStringValue:@"Success!!"];
    } else {
        [self.saveLabel setStringValue:@"Échec, réessaie ou contacte le DirInfo."];
    }
}

- (IBAction)test:(id)sender {
    NSString *smtpAdressS = [self.smtpAdress stringValue];
    int portI = [self.port intValue];
    NSString *hostnameS = [self.hostname stringValue];
    NSString *pwdS = [self.pwd stringValue];
    NSString *subjectS = [self.subject stringValue];
    NSString *msgS = [self.msg stringValue];
    NSString *mailsString = [self.recipients stringValue];
    NSArray * targetMails = [mailsString componentsSeparatedByString:@"\n"];
    
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
    [builder setHTMLBody:msgS];
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            [self.testLabel setStringValue:[NSString stringWithFormat:@"Error : %@", [error.userInfo objectForKey:@"NSLocalizedDescription"]]];
            DDLogError(@"Error sending test email: %@", error);
        } else {
            [self.testLabel setStringValue:@"Success!!"];
            DDLogInfo(@"Successfully sent test email!");
        }
    }];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    return result;
}

@end
