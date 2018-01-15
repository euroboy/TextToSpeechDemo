//
//  SpeechToTextViewController.m
//  TextToSpeechAndViceversa
//
//  Created by Dev on 11/10/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "SpeechToTextViewController.h"
#import "SpeechManager.h"

@interface SpeechToTextViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *speakStopButton;

@end

@implementation SpeechToTextViewController

#pragma mark - UI Events
- (IBAction) closeButtonPressed:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) speakStopButton:(id) sender
{
    if (@available(iOS 10.0, *))
    {
        if ([[SpeechManager sharedManager] isRecordingVoice])
        {
            [[SpeechManager sharedManager] stopVoiceRecording];
            self.speakStopButton.enabled = NO;
            [self.speakStopButton setTitle:@"SPEAK" forState:UIControlStateNormal];
        }
        else
        {
            self.textView.text = @"Say something, I'm listening!";
            [self.speakStopButton setTitle:@"STOP" forState:UIControlStateNormal];
            
            [[SpeechManager sharedManager] startVoiceRecordingWithCompletion:^(NSString *result, NSError *error) {
                
                if (!result || error)
                {
                    [self.speakStopButton setTitle:@"SPEAK" forState:UIControlStateNormal];
                }
                else
                {
                    self.textView.text = result;
                }
            }];
        }
    }
}

@end
