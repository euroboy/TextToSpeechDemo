//
//  ViewController.m
//  TextToSpeechAndViceversa
//
//  Created by Dev on 10/16/17.
//  Copyright © 2017 Dev. All rights reserved.
//

#import "ViewController.h"
#import "SpeechManager.h"

@interface ViewController ()

//UI outlets
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;

@end

@implementation ViewController

#pragma mark - View Controller LifeCycle Methods
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self defaultInits];
}

#pragma mark - Initializations
- (void) defaultInits
{
    self.inputTextView.text = @"    I'm tryna put you in the worst mood, ah, \n\
    P1 cleaner than your church shoes, ah, \n\
    Milli point two just to hurt you, ah, \n\
    All red Lamb’ just to tease you, ah, \n\
    None of these toys on lease too, ah, \n\
    Made your whole year in a week too, yah, \n\
    Main bitch out your league too, ah, \n\
    Side bitch out of your league too, ah, \n\
    \n\
    House so empty, need a centerpiece, \n\
    20 racks a table cut from ebony, \n\
    Cut that ivory into skinny pieces, \n\
    Then she clean it with her face man I love my baby, \n\
    You talking money, need a hearing aid, \n\
    You talking bout me, I don't see the shade, \n\
    Switch up my style, I take any lane, \n\
    I switch up my cup, I kill any pain, \n\
    \n\
    Look what you've done, \n\
    I’m a motherfuckin' starboy, \n\
    Look what you've done, \n\
    I'm a motherfuckin' starboy";
}

#pragma mark - UI Events
- (IBAction) speakButtonPressed:(id) sender
{
    [[SpeechManager sharedManager] speechText:self.inputTextView.text];
}

- (IBAction) stopButtonPressed:(id) sender
{
    [[SpeechManager sharedManager] stopSpeechPlayback];
}

- (IBAction) closeButtonPressed:(id) sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
