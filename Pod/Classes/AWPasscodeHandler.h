//
//  AWPasscodeHandler.h
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWPasscodeViewController.h"

@interface AWPasscodeHandler : NSObject
/**
 @brief  Returns the shared instance of the passcode handler.
 */
+ (AWPasscodeHandler *)sharedHandler;
/**
 @brief The window holding a reference to AWPAsscodeViewController
 */
@property (nonatomic, strong) UIWindow  *passcodeWindow;
/**
 @brief The view controller AWPAsscodeViewController
 */
@property (nonatomic, strong) AWPasscodeViewController *passcodeVC;
/**
 @brief The string to be used as username for the passcode in the Keychain.
 */
@property (nonatomic, strong) NSString  *keychainPasscodeUsername;
/**
 @brief The string to be used as username for the timer start time in the Keychain.
 */
@property (nonatomic, strong) NSString  *keychainTimerStartUsername;
/**
 @brief The string to be used as username for the timer duration in the Keychain.
 */
@property (nonatomic, strong) NSString  *keychainTimerDurationUsername;
/**
 @brief The string to be used as service name for all the Keychain entries.
 */
@property (nonatomic, strong) NSString  *keychainServiceName;
/**
 @brief The duration of the lock animation.
 */
@property (nonatomic, assign) CGFloat   lockAnimationDuration;
/**
 @brief The duration of the slide animation.
 */
@property (nonatomic, assign) CGFloat   slideAnimationDuration;
/**
 @brief Use keychain or not.
 */
@property (nonatomic, assign) BOOL   usesKeychain;
/**
 @brief The maximum number of failed attempts allowed.
 */
@property (nonatomic, assign) NSInteger maxNumberOfAllowedFailedAttempts;
/**
 @brief  Returns a Boolean value that indicates whether a passcode exists (@c YES) or not (@c NO).
 @return @c YES if a passcode is enabled. This also means it is enabled, unless custom logic was added to the library.
 */
+ (BOOL)doesPasscodeExist;
/**
 @brief	 Retrieves from the keychain the duration while app is in background after which the lock has to be displayed.
 @return The duration.
 */
+ (NSTimeInterval)timerDuration;
/**
 @brief			 Saves in the keychain the duration that needs to pass while app is in background  for the lock to be displayed.
 @param duration The duration.
 */
+ (void)saveTimerDuration:(NSTimeInterval)duration;
/**
 @brief  Retrieves from the keychain the time at which the timer started.
 @return The time, as @c timeIntervalSinceReferenceDate, at which the timer started.
 */
+ (NSTimeInterval)timerStartTime;
/**
 @brief Saves the current time, as @c timeIntervalSinceReferenceDate.
 */
+ (void)saveTimerStartTime;
/**
 @brief  Returns a Boolean value that indicates whether the timer has ended (@c YES) and the lock has to be displayed or not (@c NO).
 @return @c YES if the timer ended and the lock has to be displayed.
 */
+ (BOOL)didPasscodeTimerEnd;
/**
 @brief Removes the passcode from the keychain.
 */
+ (void)deletePasscode;
/**
 @brief Removes the passcode from the keychain and closes the passcode view controller.
 */
+ (void)deletePasscodeAndClose;
/**
 @brief             Call this if you want to save and read the passcode and timers to and from somewhere else rather than the Keychain.
 @attention         All the protocol methods will fall back to the Keychain if not implemented, even if calling this method with @c NO. This allows for flexibility over what and where you save.
 @param useKeychain Set to @c NO if you want to save and read the passcode and timers to and from somewhere else rather than the Keychain. Default is @c YES.
 */
+ (void)useKeychain:(BOOL)useKeychain;
/**
 @brief Resets the singleton and clears any strong references that can cause problems
 */
+ (void)resetHandler;

// #### Methods used to display the passcode
- (void)showLockScreenWithAnimation:(BOOL)animated;
- (void)displayPasscodeToEnable:(UIViewController*)viewController asModal:(BOOL)modally;
- (void)displayPasscodeToChange:(UIViewController*)viewController asModal:(BOOL)modally;
- (void)displayPasscodeToDisable:(UIViewController*)viewController asModal:(BOOL)modally;

// #### Validating methods
- (BOOL)validatePasscode:(NSString *)typedString;

@end
