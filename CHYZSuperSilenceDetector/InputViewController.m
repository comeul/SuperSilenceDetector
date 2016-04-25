//
//  InputViewController.m
//  CHYZSuperSilenceDetector
//
//  Created by Webdev on 2016-04-19.
//  Copyright © 2016 CHYZ 94,3 FM. All rights reserved.
//

#import "InputViewController.h"
#import "EZAudioDevice.h"

@interface InputViewController ()

@end

@implementation InputViewController
{
    NSArray *inputDevices;
    
    NSFileManager *fileManager;
    NSString *filePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray * popupValues = [NSMutableArray.alloc init];
    inputDevices = [EZAudioDevice inputDevices];
    for (EZAudioDevice *availDevice in inputDevices) {
        [popupValues addObject:availDevice.name];
    }
    [self.deviceList removeAllItems];
    [self.deviceList addItemsWithTitles:popupValues];
    
    fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [[NSBundle mainBundle] resourcePath];//[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    filePath = [documentsPath stringByAppendingPathComponent:@"input.json"];
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    if (fileExists) {
        NSData *jsonData = [fileManager contentsAtPath:filePath];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
        
        [self.deviceList selectItemWithTitle:[json objectForKey:@"nom_entree"]];
        [self.minDB setStringValue:[json objectForKey:@"decibel"]];
        [self.time setStringValue:[json objectForKey:@"secondes"]];
        [self.marging setStringValue:[json objectForKey:@"tolerance"]];
        [self.shouldStart setState:[[json objectForKey:@"au_demarrage"] intValue]];
    }
}

- (IBAction)saveCurrentValue:(id)sender {
    NSString *input = [self.deviceList selectedItem].title;
    int db = [self.minDB intValue];
    int time = [self.time intValue];
    int marging = [self.marging intValue];
    bool shouldStart = self.shouldStart.state;
    
    if (time == 0)
        time = 1;
    
    NSMutableDictionary *optionJson = [NSMutableDictionary.alloc init];
    [optionJson setObject:input forKey:@"nom_entree"];
    [optionJson setObject:[NSString stringWithFormat:@"%d", db] forKey:@"decibel"];
    [optionJson setObject:[NSString stringWithFormat:@"%d", time] forKey:@"secondes"];
    [optionJson setObject:[NSString stringWithFormat:@"%d", marging] forKey:@"tolerance"];
    [optionJson setObject:[NSString stringWithFormat:@"%d", shouldStart] forKey:@"au_demarrage"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:optionJson options:0 error:nil];
    bool success = [fileManager createFileAtPath:filePath contents:jsonData attributes:nil];
    
    if (success) {
        [self.minDB setStringValue:[NSString stringWithFormat:@"%d", db]];
        [self.time setStringValue:[NSString stringWithFormat:@"%d", time]];
        [self.marging setStringValue:[NSString stringWithFormat:@"%d", marging]];
        [self.shouldStart setState:shouldStart];
    }
    
    
}
@end
