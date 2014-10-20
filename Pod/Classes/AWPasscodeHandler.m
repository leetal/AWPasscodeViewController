//
//  AWPasscodeHandler.m
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWPasscodeHandler.h"
#import "AWKeychainUtils.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface AWPasscodeHandler ()
@property (nonatomic, assign) NSInteger   failedAttempts;
@property (nonatomic, strong) NSString    *tempPasscode;
@end

@implementation AWPasscodeHandler

#pragma mark - Init
+ (AWPasscodeHandler *)sharedHandler {
    __strong static AWPasscodeHandler *sharedObject = nil;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedObject = [[AWPasscodeHandler alloc] init];
    });
    
    return sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit {
    [self _addObservers];
    
    [self _loadMiscDefaults];
    [self _loadKeychainDefaults];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Misc loading
- (void)_loadMiscDefaults {
    _lockAnimationDuration = 0.25;
    _slideAnimationDuration = 0.15;
    _maxNumberOfAllowedFailedAttempts = 3;
    _usesKeychain = YES;
}

- (void)_loadKeychainDefaults {
    _keychainPasscodeUsername = @"defaultPasscode";
    _keychainTimerStartUsername = @"defaultPasscodeTimerStart";
    _keychainServiceName = @"defaultServiceName";
    _keychainTimerDurationUsername = @"passcodeTimerDuration";
}

#pragma mark - Public, class methods
+ (BOOL)doesPasscodeExist {
    return [[AWPasscodeHandler sharedHandler] _doesPasscodeExist];
}


+ (NSString *)passcode {
    return [[AWPasscodeHandler sharedHandler] _passcode];
}


+ (NSTimeInterval)timerDuration {
    return [[AWPasscodeHandler sharedHandler] _timerDuration];
}


+ (void)saveTimerDuration:(NSTimeInterval)duration {
    [[AWPasscodeHandler sharedHandler] _saveTimerDuration:duration];
}


+ (NSTimeInterval)timerStartTime {
    return [[AWPasscodeHandler sharedHandler] _timerStartTime];
}


+ (void)saveTimerStartTime {
    [[AWPasscodeHandler sharedHandler] _saveTimerStartTime];
}


+ (BOOL)didPasscodeTimerEnd {
    return [[AWPasscodeHandler sharedHandler] _didPasscodeTimerEnd];
}


+ (void)deletePasscodeAndClose {
    [[AWPasscodeHandler sharedHandler] _deletePasscode];
    [[AWPasscodeHandler sharedHandler] _dismissMe];
}


+ (void)deletePasscode {
    [[AWPasscodeHandler sharedHandler] _deletePasscode];
}


+ (void)useKeychain:(BOOL)useKeychain {
    [[AWPasscodeHandler sharedHandler] _useKeychain:useKeychain];
}


#pragma mark - Private methods
- (void)_useKeychain:(BOOL)useKeychain {
    _usesKeychain = useKeychain;
}


- (BOOL)_doesPasscodeExist {
    return [self _passcode].length != 0;
}


- (NSTimeInterval)_timerDuration {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(timerDuration)]) {
    //    return [self.delegate timerDuration];
    //}
    
    NSString *keychainValue =
    [AWKeychainUtils getPasswordForUsername:_keychainTimerDurationUsername
                             andServiceName:_keychainServiceName
                                      error:nil];
    if (!keychainValue) return -1;
    return keychainValue.doubleValue;
}


- (void)_saveTimerDuration:(NSTimeInterval) duration {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(saveTimerDuration:)]) {
    //    [self.delegate saveTimerDuration:duration];
    //
    //    return;
    //}
    
    [AWKeychainUtils storeUsername:_keychainTimerDurationUsername
                       andPassword:[NSString stringWithFormat: @"%.6f", duration]
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (NSTimeInterval)_timerStartTime {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(timerStartTime)]) {
    //    return [self.delegate timerStartTime];
    //}
    
    NSString *keychainValue =
    [AWKeychainUtils getPasswordForUsername:_keychainTimerStartUsername
                             andServiceName:_keychainServiceName
                                      error:nil];
    if (!keychainValue) return -1;
    return keychainValue.doubleValue;
}


- (void)_saveTimerStartTime {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(saveTimerStartTime)]) {
    //    [self.delegate saveTimerStartTime];
    //
    //    return;
    //}
    
    [AWKeychainUtils storeUsername:_keychainTimerStartUsername
                       andPassword:[NSString stringWithFormat: @"%.6f",
                                    [NSDate timeIntervalSinceReferenceDate]]
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (BOOL)_didPasscodeTimerEnd {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(didPasscodeTimerEnd)]) {
    //   return [self.delegate didPasscodeTimerEnd];
    //}
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    // startTime wasn't saved yet (first app use and it crashed, phone force
    // closed, etc) if it returns -1.
    if (now - [self _timerStartTime] >= [self _timerDuration] ||
        [self _timerStartTime] == -1) return YES;
    return NO;
}


- (void)_deletePasscode {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(deletePasscode)]) {
    //    [self.delegate deletePasscode];
    //
    //    return;
    //}
    
    [AWKeychainUtils deleteItemForUsername:_keychainPasscodeUsername
                            andServiceName:_keychainServiceName
                                     error:nil];
}


- (void)_savePasscode:(NSString *)passcode {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(savePasscode:)]) {
    //    [self.delegate savePasscode:passcode];
    //
    //    return;
    //}
    
    [AWKeychainUtils storeUsername:_keychainPasscodeUsername
                       andPassword:passcode
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (NSString *)_passcode {
    //if (!_usesKeychain &&
    //    [self.delegate respondsToSelector:@selector(passcode)]) {
    //    return [self.delegate passcode];
    //}
    
    return [AWKeychainUtils getPasswordForUsername:_keychainPasscodeUsername
                                    andServiceName:_keychainServiceName
                                             error:nil];
}

#pragma mark - Passcode view handling

- (void)_cancelAndDismissMe {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeViewControllerWillClose" object:self userInfo:nil];
    
    if (_passcodeWindow) {
        _passcodeVC = nil;
        _passcodeWindow.hidden = YES;
        _passcodeWindow = nil;
        
        // Remove keyboard window (top window, third or more in hierachy)
        NSArray *wins = [[UIApplication sharedApplication] windows];
        if ([wins count] > 1) {
            UIWindow *keyboardWindow = [wins lastObject];
            keyboardWindow.hidden = YES;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeViewControllerDidClose" object:self userInfo:nil];
    }
}

- (void)_dismissMe {
    _failedAttempts = 0;
    
    //Find keyboard window so we can fade it away
    NSArray *wins = [[UIApplication sharedApplication] windows];
    UIWindow *keyboardWindow = nil;
    if ([wins count] > 1) {
        keyboardWindow = [wins lastObject];
    }
    
    [UIView animateWithDuration: _lockAnimationDuration animations: ^{
        if (_passcodeVC) {
            
            keyboardWindow.alpha = 0.0f;
            
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
                _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * -1.f, _passcodeVC.view.center.y);
            }
            else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * 2.f, _passcodeVC.view.center.y);
            }
            else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
                _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * -1.f);
            }
            else {
                _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * 2.f);
            }
        } else {
            // Delete from Keychain
            if (_passcodeVC.currentOperation == PasscodeOperationRemove) {
                [self _deletePasscode];
            }
            else {
                // Update the Keychain if adding or changing passcode
                [self _savePasscode:_tempPasscode];
            }
        }
    } completion: ^(BOOL finished) {
        [self _cancelAndDismissMe];
    }];
}

#pragma mark - Displaying
- (void)showLockScreenWithAnimation:(BOOL)animated {
    
    if(!_passcodeWindow) {
        _passcodeVC = [AWPasscodeViewController new];
        
        [_passcodeVC prepareAsLockScreen];
        
        _passcodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _passcodeWindow.windowLevel = UIWindowLevelStatusBar;
        [_passcodeWindow setRootViewController:_passcodeVC];
        _passcodeWindow.backgroundColor = [UIColor clearColor];
        [_passcodeWindow makeKeyAndVisible];
        
        CGPoint newCenter;
        if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
            _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * -1.f, _passcodeVC.view.center.y);
            newCenter = CGPointMake(self.passcodeWindow.center.x - _passcodeVC.navigationController.navigationBar.frame.size.height / 2,
                                    self.passcodeWindow.center.y);
        }
        else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
            _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * 2.f, _passcodeVC.view.center.y);
            newCenter = CGPointMake(self.passcodeWindow.center.x + _passcodeVC.navigationController.navigationBar.frame.size.height / 2,
                                    self.passcodeWindow.center.y);
        }
        else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
            _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * -1.f);
            newCenter = CGPointMake(self.passcodeWindow.center.x,
                                    self.passcodeWindow.center.y - _passcodeVC.navigationController.navigationBar.frame.size.height / 2);
        }
        else {
            _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * 2.f);
            newCenter = CGPointMake(self.passcodeWindow.center.x,
                                    self.passcodeWindow.center.y + _passcodeVC.navigationController.navigationBar.frame.size.height / 2);
        }
        
        if (animated) {
            [UIView animateWithDuration: _lockAnimationDuration animations: ^{
                _passcodeVC.view.center = newCenter;
            }];
        }
        else {
            _passcodeVC.view.center = newCenter;
        }
    }
}

/*
 - (void)_prepareNavigationControllerWithController:(UIViewController *)viewController {
 self.navigationItem.rightBarButtonItem =
 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancelAndDismissMe)];
 
 if (!_displayedAsModal) {
 [viewController.navigationController pushViewController:self
 animated:YES];
 self.navigationItem.hidesBackButton = _hidesBackButton;
 [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
 
 return;
 }
 UINavigationController *navController =
 [[UINavigationController alloc] initWithRootViewController:self];
 
 // Make sure nav bar for logout is off the screen
 [self.navBar removeFromSuperview];
 self.navBar = nil;
 
 // Customize navigation bar
 // Make sure UITextAttributeTextColor is not set to nil
 // barTintColor & translucent is only called on iOS7+
 navController.navigationBar.tintColor = self.navigationTintColor;
 if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
 navController.navigationBar.barTintColor = self.navigationBarTintColor;
 navController.navigationBar.translucent = self.navigationBarTranslucent;
 }
 if (self.navigationTitleColor) {
 navController.navigationBar.titleTextAttributes =
 @{ NSForegroundColorAttributeName : self.navigationTitleColor };
 }
 
 [viewController presentViewController:navController
 animated:YES
 completion:nil];
 [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
 }
 
 
 - (void)showForEnablingPasscodeInViewController:(UIViewController *)viewController
 asModal:(BOOL)isModal {
 _displayedAsModal = isModal;
 [self _prepareForEnablingPasscode];
 [self _prepareNavigationControllerWithController:viewController];
 self.title = NSLocalizedStringFromTable(self.enablePasscodeString, _localizationTableName, @"");
 }
 
 
 - (void)showForChangingPasscodeInViewController:(UIViewController *)viewController
 asModal:(BOOL)isModal {
 _displayedAsModal = isModal;
 [self _prepareForChangingPasscode];
 [self _prepareNavigationControllerWithController:viewController];
 self.title = NSLocalizedStringFromTable(self.changePasscodeString, _localizationTableName, @"");
 }
 
 
 - (void)showForDisablingPasscodeInViewController:(UIViewController *)viewController
 asModal:(BOOL)isModal {
 _displayedAsModal = isModal;
 [self _prepareForTurningOffPasscode];
 [self _prepareNavigationControllerWithController:viewController];
 self.title = NSLocalizedStringFromTable(self.turnOffPasscodeString, _localizationTableName, @"");
 }
 */

- (void)_addObservers {
    /*[[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationDidEnterBackground)
     name: UIApplicationDidEnterBackgroundNotification
     object: nil];
     [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationWillResignActive)
     name: UIApplicationWillResignActiveNotification
     object: nil];
     [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationDidBecomeActive)
     name: UIApplicationDidBecomeActiveNotification
     object: nil];
     [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationWillEnterForeground)
     name: UIApplicationWillEnterForegroundNotification
     object: nil];*/
}

#pragma mark - Validation
- (BOOL) validatePasscode:(NSString *)typedString {
    return [self _validatePasscode:typedString];
}

- (BOOL)_validatePasscode:(NSString *)typedString {
    NSString *savedPasscode = [self _passcode];
    
    if (_passcodeVC && (_passcodeVC.currentOperation == PasscodeOperationChange  || savedPasscode.length == 0) && !_passcodeVC.currentOperation == PasscodeOperationRemove) {
        
        if ((_passcodeVC.currentOperation == PasscodeOperationChange || savedPasscode.length == 0) && _passcodeVC.currentOperation != PasscodeOperationChangeVerify) {
            _tempPasscode = typedString;
            
            // The delay is to give time for the last bullet to appear
            [self performSelector:@selector(_askForConfirmationPasscode)
                       withObject:nil
                       afterDelay:0.15f];
        }
        // User entered his Passcode correctly and we are at the confirming screen.
        else if (_passcodeVC.currentOperation != PasscodeOperationChangeVerify) {
            // User entered the confirmation Passcode correctly
            if ([typedString isEqualToString: _tempPasscode]) {
                [self _dismissMe];
            }
            // User entered the confirmation Passcode incorrectly, start over.
            else {
                [self performSelector:@selector(_reAskForNewPasscode)
                           withObject:nil
                           afterDelay:_slideAnimationDuration];
            }
        }
        // Changing Passcode and the entered Passcode is correct.
        else if ([typedString isEqualToString:savedPasscode]){
            [self performSelector:@selector(_askForNewPasscode)
                       withObject:nil
                       afterDelay:_slideAnimationDuration];
            _failedAttempts = 0;
        }
        // Acting as lockscreen and the entered Passcode is incorrect.
        else {
            [self performSelector: @selector(_denyAccess)
                       withObject: nil
                       afterDelay: _slideAnimationDuration];
            return NO;
        }
    }
    // App launch/Turning passcode off: Passcode OK -> dismiss, Passcode incorrect -> deny access.
    else {
        if ([typedString isEqualToString: savedPasscode]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeWasEnteredSuccessfully" object:self userInfo:nil];
            
            [self _dismissMe];
        }
        else {
            [self performSelector: @selector(_denyAccess)
                       withObject: nil
                       afterDelay: _slideAnimationDuration];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Actions

- (void)_askForNewPasscode {
    // TODO add logic
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    
    
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.view layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_reAskForNewPasscode {
    // TODO add logic
    
    
    _tempPasscode = @"";
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.view layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_askForConfirmationPasscode {
    // TODO add logic
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.view layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_denyAccess {
    
    _failedAttempts++;
    
    if (_maxNumberOfAllowedFailedAttempts > 0 &&
        _failedAttempts == _maxNumberOfAllowedFailedAttempts) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"maxNumberOfFailedAttemptsReached" object:self userInfo:nil];
        _failedAttempts = 0;
        
        [self _dismissMe];
        return;
    }
    
    // TODO add logic in passcodeVC
    
    /*if (_failedAttempts == 1) {
     _failedAttemptLabel.text =
     NSLocalizedStringFromTable(@"1 Passcode Failed Attempt", _localizationTableName, @"");
     }
     else {
     _failedAttemptLabel.text = [NSString stringWithFormat: NSLocalizedStringFromTable(@"%i Passcode Failed Attempts", _localizationTableName, @""), _failedAttempts];
     }
     _failedAttemptLabel.layer.cornerRadius = kFailedAttemptLabelHeight * 0.65f;
     _failedAttemptLabel.clipsToBounds = true;
     _failedAttemptLabel.hidden = NO;
     */
}


@end
