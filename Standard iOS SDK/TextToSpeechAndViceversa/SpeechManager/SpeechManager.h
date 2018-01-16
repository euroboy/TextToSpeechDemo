//
//  SpeechManager.h
//  TextToSpeechAndViceversa
//
//  Created by Dev on 1/15/18.
//  Copyright © 2018 Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VoiceRecordingResultBlock)(NSString *result, NSError *error);

@interface SpeechManager : NSObject

#pragma mark - Initializations
+ (instancetype) sharedManager;

#pragma mark - TEXT TO SPEECH Methods
- (void) speechText:(NSString *) textToBeSpoken;
- (void) stopSpeechPlayback;

#pragma mark - SPEECH TO TEXT Methods
- (void) startVoiceRecordingWithCompletion:(VoiceRecordingResultBlock) completion;
- (void) stopVoiceRecording;
- (BOOL) isRecordingVoice;

@end
