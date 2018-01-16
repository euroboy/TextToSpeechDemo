//
//  ViewController.m
//  OpenEarsDemo
//
//  Created by Dev on 1/16/18.
//  Copyright © 2018 Dev. All rights reserved.
//

#import "ViewController.h"
#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>
#import <OpenEars/OEEventsObserver.h>

@interface ViewController () <OEEventsObserverDelegate>

@property (strong, nonatomic) OEFliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@end

@implementation ViewController

#pragma mark - View Controller LifeCycle Methods
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self loadings];
}

- (void) loadings
{
    self.fliteController = [[OEFliteController alloc] init];
    self.slt = [[Slt alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
}

#pragma mark - UI Events
- (IBAction) speakButtonPressed:(id) sender
{
    [self.fliteController say:@"Bonjour" withVoice:self.slt];
}

#pragma mark - OEEventsObserverDelegate Methods
- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID
{
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartListening
{
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
