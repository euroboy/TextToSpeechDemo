//
//  SpeechManager.m
//  TextToSpeechAndViceversa
//
//  Created by Dev on 1/15/18.
//  Copyright © 2018 Dev. All rights reserved.
//

#import "SpeechManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Speech/Speech.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@interface SpeechManager() <SFSpeechRecognizerDelegate>

//TEXT TO SPEECH:
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;

//SPEECH TO TEXT:
@property (strong, nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (strong, nonatomic) SFSpeechRecognitionTask *recognitionTask;
@property (strong, nonatomic) AVAudioEngine *audioEngine;

@end

@implementation SpeechManager

#pragma mark - Initializations
+ (instancetype) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self loadSpeechSynthesizer];
    }
    return self;
}

- (void) loadSpeechSynthesizer
{
    self.synthesizer = [AVSpeechSynthesizer new];
    [self printAvailableVoices];
}

- (void) loadSpeechRecognizer
{
    if (@available(iOS 10.0, *))
    {
        self.audioEngine = [AVAudioEngine new];
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en-EN"];
        self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:locale];
        self.speechRecognizer.delegate = self;
        
        [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
            
            switch (status)
            {
                case SFSpeechRecognizerAuthorizationStatusAuthorized:
                {
                    NSLog(@"Speech recognition authorized");
                    break;
                }
                case SFSpeechRecognizerAuthorizationStatusDenied:
                {
                    NSLog(@"User denied access to speech recognition");
                    break;
                }
                case SFSpeechRecognizerAuthorizationStatusRestricted:
                {
                    NSLog(@"Speech recognition restricted on this device");
                    break;
                }
                case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                {
                    NSLog(@"Speech recognition not yet authorized");
                    break;
                }
                default:
                    break;
            }
        }];
        
        [self printSupportedLocales];
    }
    else
    {
        //not supported
    }
}

#pragma mark - TEXT TO SPEECH Methods
- (void) speechText:(NSString *) textToBeSpoken
{
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-IE"];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:textToBeSpoken];
    utterance.voice = voice;
    
    [self stopSpeechPlayback];
    [self.synthesizer speakUtterance:utterance];
}

- (void) stopSpeechPlayback
{
    if (self.synthesizer.isSpeaking)
    {
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
}

#pragma mark - SPEECH TO TEXT Methods
- (void) startVoiceRecordingWithCompletion:(VoiceRecordingResultBlock) completion
{
    if (@available(iOS 10.0, *))
    {
        static dispatch_once_t once = 0;
        dispatch_once(&once, ^{
            
            [self loadSpeechRecognizer];
        });
        
        [self stopVoiceRecording];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        @try
        {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
            [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
            [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
        }
        @catch(NSException * e)
        {
            NSLog(@"audioSession properties weren't set because of an error");
        }
        
        self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        if (!inputNode)
        {
            NSString *errorDescription = @"Audio engine has no input node";
            NSLog(@"VOICE RECORDING ERROR: %@", errorDescription);
            NSError *noInputError = [NSError errorWithDomain:errorDescription code:999 userInfo:nil];
            
            if (completion)
            {
                completion(nil, noInputError);
            }
            return;
        }
        
        self.recognitionRequest.shouldReportPartialResults = YES;
        self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            
            BOOL isFinal = NO;
            
            if (result != nil)
            {
                if (completion)
                {
                    completion(result.bestTranscription.formattedString, error);
                }
                
                isFinal = !result.isFinal;
            }
        }];
        
        AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
        [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            
            [self.recognitionRequest appendAudioPCMBuffer:buffer];
        }];
        
        [self.audioEngine prepare];
        
        @try
        {
            [self.audioEngine startAndReturnError:nil];
        }
        @catch(NSException * e)
        {
            NSLog(@"audioEngine couldn't start because of an error");
        }
    }
    else
    {
        NSString *errorDescription = @"Voice recognition is not supported by your firmware";
        NSLog(@"VOICE RECOGNITION ERROR: %@", errorDescription);
        NSError *notSupportedError = [NSError errorWithDomain:errorDescription code:888 userInfo:nil];
        
        if (completion)
        {
            completion(nil, notSupportedError);
        }
    }
}

- (void) stopVoiceRecording
{
    if (@available(iOS 10.0, *))
    {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        AVAudioInputNode *inputNode = self.audioEngine.inputNode;
        if (inputNode)
        {
            [inputNode removeTapOnBus:0];
        }
        _recognitionRequest = nil;
        if (self.recognitionTask != nil)
        {
            [self.recognitionTask cancel];
            _recognitionTask = nil;
        }
    }
}

- (BOOL) isRecordingVoice
{
    return self.audioEngine.isRunning;
}

#pragma mark - SFSpeechRecognizerDelegate Methods
- (void) speechRecognizer:(SFSpeechRecognizer *) speechRecognizer availabilityDidChange:(BOOL) available
{
    
}

#pragma mark - Printing Info
- (void) printAvailableVoices
{
    for (AVSpeechSynthesisVoice *voiceItem in [AVSpeechSynthesisVoice speechVoices])
    {
        NSLog(@"VOICE = %@", voiceItem);
    }
}

- (void) printSupportedLocales
{
    if (@available(iOS 10.0, *))
    {
        for (NSLocale *locate in [SFSpeechRecognizer supportedLocales])
        {
            NSString *languageCode = [locate localeIdentifier];
            NSLog(@"%@   -   %@", [locate localizedStringForCountryCode:locate.countryCode], languageCode);
        }
    }
}

@end

#pragma clang diagnostic pop
