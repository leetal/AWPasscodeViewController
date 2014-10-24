//
//  AWPasscodeHandler.m
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWPasscodeHandler.h"
#import "AWKeychainUtils.h"

@interface AWPasscodeHandler ()
@property (nonatomic, assign) NSInteger   failedAttempts;
@property (nonatomic, strong) NSString    *tempPasscode;
@property (nonatomic, strong) AWPasscodeViewController *passcodeVC;
@property (nonatomic, strong) UIView *dummyView;
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
    
    [self _addNecessaryObservers];
    [self _loadDefaults];
    [self _loadKeychainDefaults];
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


#pragma mark - Misc loading

- (void)_loadDefaults {
    _lockAnimationDuration = 0.25;
    _slideAnimationDuration = 0.15;
    _maxNumberOfAllowedFailedAttempts = 3;
    _usesKeychain = YES;
    _isDisplayedAsLockscreen = NO;
    _useTouchID = YES;
}


- (void)_loadKeychainDefaults {
    _keychainPasscodeUsername = @"defaultPasscode";
    _keychainTimerStartUsername = @"defaultPasscodeTimerStart";
    _keychainServiceName = @"defaultServiceName";
    _keychainTimerDurationUsername = @"passcodeTimerDuration";
}


- (void)_addNecessaryObservers {
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationWillResignActive)
     name: UIApplicationWillResignActiveNotification
     object: nil];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationDidEnterBackground)
     name: UIApplicationDidEnterBackgroundNotification
     object: nil];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationWillEnterForeground)
     name: UIApplicationWillEnterForegroundNotification
     object: nil];
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector(_applicationDidBecomeActive)
     name: UIApplicationDidBecomeActiveNotification
     object: nil];
}


#pragma mark - Public, class methods

+ (BOOL)doesPasscodeExist {
    return [[AWPasscodeHandler sharedHandler] _doesPasscodeExist];
}


+ (BOOL)useTouchID {
    return [[AWPasscodeHandler sharedHandler] useTouchID];
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


+ (void)saveKeychainUsername:(NSString*)username {
    [[AWPasscodeHandler sharedHandler] _saveKeychainUsername:username];
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


+ (void)resetHandler {
    [[AWPasscodeHandler sharedHandler] _resetHandler];
}


- (UIView*)createFrostView:(UIColor*)backgroundColor {
    UIView *blurView = nil;
    
    if([UIBlurEffect class]) { // iOS 8
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //blurView.frame = view.frame;
        
    } else if(AW_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //iOS 7
        blurView = [[UIToolbar alloc] initWithFrame:CGRectZero];
    } else {
        // Fallback to backgroundColor
        blurView = [UIView new];
        if(backgroundColor) {
            blurView.backgroundColor = backgroundColor;
        } else {
            blurView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    return blurView;
    /*[view addSubview:blurView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];*/
}

#pragma mark - Private methods

- (BOOL)_doesPasscodeExist {
    return [self _passcode].length != 0;
}


- (NSTimeInterval)_timerDuration {
    
    NSString *keychainValue =
    [AWKeychainUtils getPasswordForUsername:_keychainTimerDurationUsername
                             andServiceName:_keychainServiceName
                                      error:nil];
    if (!keychainValue)
        return -1;
    return keychainValue.doubleValue;
}


- (void)_saveTimerDuration:(NSTimeInterval) duration {
    
    [AWKeychainUtils storeUsername:_keychainTimerDurationUsername
                       andPassword:[NSString stringWithFormat: @"%.6f", duration]
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (void)_saveKeychainUsername:(NSString*) username {
    _keychainPasscodeUsername = username;
}


- (NSTimeInterval)_timerStartTime {
    
    NSString *keychainValue =
    [AWKeychainUtils getPasswordForUsername:_keychainTimerStartUsername
                             andServiceName:_keychainServiceName
                                      error:nil];
    if (!keychainValue) return -1;
    return keychainValue.doubleValue;
}


- (void)_saveTimerStartTime {
    
    [AWKeychainUtils storeUsername:_keychainTimerStartUsername
                       andPassword:[NSString stringWithFormat: @"%.6f",
                                    [NSDate timeIntervalSinceReferenceDate]]
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (BOOL)_didPasscodeTimerEnd {
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    // startTime wasn't saved yet (first app use and it crashed, phone force
    // closed, etc) if it returns -1.
    if (now - [self _timerStartTime] >= [self _timerDuration] ||
        [self _timerStartTime] == -1) return YES;
    return NO;
}


- (void)_deletePasscode {
    
    [AWKeychainUtils deleteItemForUsername:_keychainPasscodeUsername
                            andServiceName:_keychainServiceName
                                     error:nil];
}


- (void)_savePasscode:(NSString *)passcode {
    
    [AWKeychainUtils storeUsername:_keychainPasscodeUsername
                       andPassword:passcode
                    forServiceName:_keychainServiceName
                    updateExisting:YES
                             error:nil];
}


- (NSString *)_passcode {
    
    return [AWKeychainUtils getPasswordForUsername:_keychainPasscodeUsername
                                    andServiceName:_keychainServiceName
                                             error:nil];
}


- (void)_resetHandler {
    _passcodeVC                     = nil;
}

#pragma mark - Passcode view handling

- (void)_cancelAndDismissMe {
    [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeViewControllerWillClose" object:self userInfo:nil];
    
    if (_isDisplayedAsLockscreen) {
        
        [_passcodeVC.view removeFromSuperview];
        [_passcodeVC removeFromParentViewController];
        
        [self _resetHandler];
        _isDisplayedAsLockscreen = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeViewControllerDidClose" object:self userInfo:nil];
    } else if(_passcodeVC) {
        // Displayed in a modal or another contoller
        [_passcodeVC popToCallerAnimated:YES];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"passcodeViewControllerDidClose" object:self userInfo:nil];
    }
}


- (void)_dismissMe {
    _failedAttempts = 0;
    
    // Delete from Keychain
    if (_passcodeVC.currentOperation == PasscodeOperationDisable) {
        [self _deletePasscode];
    } else if(_passcodeVC.currentOperation != PasscodeOperationLocked){
        // Update the Keychain if adding or changing passcode
        [self _savePasscode:_tempPasscode];
    }
    
    if(_isDisplayedAsLockscreen) {
        //Find keyboard window so we can fade it away
        //NSArray *wins = [[UIApplication sharedApplication] windows];
        //UIWindow *keyboardWindow = nil;
        //if ([wins count] > 1) {
        //    keyboardWindow = [wins lastObject];
        //}
        
        [UIView animateWithDuration: _lockAnimationDuration animations: ^{
            
            //keyboardWindow.alpha = 0.0f;
            
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
        } completion: ^(BOOL finished) {
            [self _cancelAndDismissMe];
        }];
    } else {
        [self _cancelAndDismissMe];
    }
}


- (void)_dismissDummy {
    [_dummyView removeFromSuperview];
    [_dummyView removeConstraints:_dummyView.constraints];
    _dummyView = nil;
}


#pragma mark - Displaying
- (void)_showDummyView {
    _dummyView = [self createFrostView:[UIColor whiteColor]];
    _dummyView.translatesAutoresizingMaskIntoConstraints = NO;
    _dummyView.backgroundColor = [UIColor clearColor];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].windows[0];
    [currentWindow addSubview: _dummyView];
    
    //[self addBlurToView:_dummyView withFallbackBackgroudColor:[UIColor whiteColor]];
    
    [currentWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_dummyView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_dummyView)]];
    [currentWindow addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_dummyView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_dummyView)]];
}


- (void)showLockScreenWithAnimation:(BOOL)animated {
    
    _isDisplayedAsLockscreen = YES;
    
    if(_passcodeVC)
        _passcodeVC = nil;
    
    _passcodeVC = [AWPasscodeViewController new];
    _passcodeVC.currentOperation = PasscodeOperationLocked;
    
    UIWindow *currentWindow = [UIApplication sharedApplication].windows[0];
    [currentWindow addSubview: _passcodeVC.view];
    
    CGPoint newCenter;
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * -1.f, _passcodeVC.view.center.y);
        newCenter = CGPointMake(currentWindow.center.x - _passcodeVC.navigationController.navigationBar.frame.size.height / 2,
                                currentWindow.center.y);
    }
    else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x * 2.f, _passcodeVC.view.center.y);
        newCenter = CGPointMake(currentWindow.center.x + _passcodeVC.navigationController.navigationBar.frame.size.height / 2,
                                currentWindow.center.y);
    }
    else if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * -1.f);
        newCenter = CGPointMake(currentWindow.center.x,
                                currentWindow.center.y - _passcodeVC.navigationController.navigationBar.frame.size.height / 2);
    }
    else {
        _passcodeVC.view.center = CGPointMake(_passcodeVC.view.center.x, _passcodeVC.view.center.y * 2.f);
        newCenter = CGPointMake(currentWindow.center.x,
                                currentWindow.center.y + _passcodeVC.navigationController.navigationBar.frame.size.height / 2);
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


- (void)_addPasscodeToViewControllerInternal:(UIViewController *)viewController asModal:(BOOL)modal withState:(PasscodeOperation)operation{
    
    UIImage *backgroundImage = nil;
    
    if (AW_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        // First, capture a screenshot of the background so that the frost effect is visible all times (iOS7+ only)
        UIGraphicsBeginImageContextWithOptions(viewController.view.bounds.size, viewController.view.opaque, 0.0);
        [viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    if(_passcodeVC)
        _passcodeVC = nil;
    
    _passcodeVC = [AWPasscodeViewController new];
    _passcodeVC.currentOperation = operation;
    _passcodeVC.backgroundImage = backgroundImage;
    
    if (!modal) {
        [viewController.navigationController pushViewController:_passcodeVC
                                                       animated:YES];
        return;
    }
    
    UINavigationController *navController =
    [[UINavigationController alloc] initWithRootViewController:_passcodeVC];
    
    [viewController presentViewController:navController
                                 animated:YES
                               completion:nil];
}


- (void)displayPasscodeToEnable:(UIViewController*)viewController asModal:(BOOL)modally {
    
    [self _addPasscodeToViewControllerInternal:viewController asModal:modally withState:PasscodeOperationEnable];
}


- (void)displayPasscodeToChange:(UIViewController*)viewController asModal:(BOOL)modally {
    
    [self _addPasscodeToViewControllerInternal:viewController asModal:modally withState:PasscodeOperationChange];
}


- (void)displayPasscodeToDisable:(UIViewController*)viewController asModal:(BOOL)modally {
    
    [self _addPasscodeToViewControllerInternal:viewController asModal:modally withState:PasscodeOperationDisable];
}


#pragma mark - Validation

- (BOOL)validatePasscode:(NSString *)typedString verifiedByTouchID:(BOOL)verified {
    return [self _validatePasscode:typedString verifiedByTouchID:verified];
}


- (BOOL)_validatePasscode:(NSString *)typedString verifiedByTouchID:(BOOL)verified {
    
    if(verified) {
        [self _dismissMe];
        return YES;
    }
    
    NSString *savedPasscode = [self _passcode];
    
    if (_passcodeVC && (_passcodeVC.currentOperation == PasscodeOperationChange || _passcodeVC.currentOperation == PasscodeOperationChangeVerify
                        || savedPasscode.length == 0 || !savedPasscode) && _passcodeVC.currentOperation != PasscodeOperationDisable) {
        
        if ((_passcodeVC.currentOperation == PasscodeOperationChange || savedPasscode.length == 0 || !savedPasscode) && _passcodeVC.currentOperation != PasscodeOperationChangeVerify) {
            _tempPasscode = typedString;
            
            // The delay is to give time for the last bullet to appear
            [self performSelector:@selector(_askForConfirmationPasscode)
                       withObject:nil
                       afterDelay:0.15f];
        }
        // User entered his Passcode correctly and we are at the confirming screen.
        else if (_passcodeVC.currentOperation == PasscodeOperationChangeVerify) {
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
    // Passcode missmatch. Just start Over.
    else if(_passcodeVC.currentOperation == PasscodeOperationChangeMissmatch) {
        _tempPasscode = typedString;
        
        // The delay is to give time for the last bullet to appear
        [self performSelector:@selector(_askForConfirmationPasscode)
                   withObject:nil
                   afterDelay:0.15f];
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


#pragma mark - Notification Observers
- (void)_applicationDidEnterBackground {
    if ([self _doesPasscodeExist]) {
        [self _showDummyView];
    }
}


- (void)_applicationDidBecomeActive {
}


- (void)_applicationWillEnterForeground {
    if ([self _doesPasscodeExist] &&
        [self _didPasscodeTimerEnd]) {
        
        [self _dismissDummy];
        
        // Display the lockscreen
        if(!_isDisplayedAsLockscreen)
            [self showLockScreenWithAnimation:NO];
    }
}


- (void)_applicationWillResignActive {
    if ([self _doesPasscodeExist] && !_isDisplayedAsLockscreen) {
        [self _saveTimerStartTime];
    }
}


#pragma mark - Actions

- (void)_askForNewPasscode {
    // TODO add logic
    _passcodeVC.currentOperation = PasscodeOperationChange;
    [_passcodeVC resetUI];
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.containerView layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_reAskForNewPasscode {
    // TODO add logic
    _passcodeVC.currentOperation = PasscodeOperationChangeMissmatch;
    _tempPasscode = @"";
    [_passcodeVC resetUI];
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.containerView layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_askForConfirmationPasscode {
    // TODO add logic
    _passcodeVC.currentOperation = PasscodeOperationChangeVerify;
    [_passcodeVC resetUI];
    
    CATransition *transition = [CATransition animation];
    [transition setDelegate: self];
    [transition setType: kCATransitionPush];
    [transition setSubtype: kCATransitionFromRight];
    [transition setDuration: _slideAnimationDuration];
    [transition setTimingFunction:
     [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
    [[_passcodeVC.containerView layer] addAnimation: transition forKey: @"swipe"];
}


- (void)_denyAccess {
    
    _failedAttempts++;
    
    [_passcodeVC increaseFailCount:_failedAttempts];
    
    if (_maxNumberOfAllowedFailedAttempts > 0 &&
        _failedAttempts == _maxNumberOfAllowedFailedAttempts) {
        
        // Notify about the fail
        [[NSNotificationCenter defaultCenter] postNotificationName: @"maxNumberOfFailedAttemptsReached" object:self userInfo:nil];
        
        // Set operation to disable
        _passcodeVC.currentOperation = PasscodeOperationDisable;
        
        // Dismiss the passcode VC
        [self _dismissMe];
    }
}

@end
