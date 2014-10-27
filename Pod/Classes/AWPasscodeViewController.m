//
//  AWPasscodeViewController.m
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWPasscodeViewController.h"
#import "AWPasscodeHandler.h"
#import "UIResponder+FirstResponderReference.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface AWPasscodeViewController ()
@property (nonatomic, strong) UITextField   *firstDigitTextField;
@property (nonatomic, strong) UITextField   *secondDigitTextField;
@property (nonatomic, strong) UITextField   *thirdDigitTextField;
@property (nonatomic, strong) UITextField   *fourthDigitTextField;

@property (nonatomic, strong) UILabel       *failedLabel;
@property (nonatomic, strong) UILabel       *mainLabel;
@property (nonatomic, strong) UIView        *containerView;
@property (nonatomic, strong) UIView        *passcodeEntryView;

@property (nonatomic, strong) LAContext     *context;

@property (nonatomic, strong) UIImageView   *backgroundImageView;

@property (nonatomic, assign) CGFloat       modifierForBottomVerticalGap;
@property (nonatomic, assign) CGFloat       iPadFontSizeModifier;
@property (nonatomic, assign) CGFloat       iPhoneHorizontalGap;

@property (nonatomic, assign) BOOL          presentedAsModal;
@property (nonatomic, assign) BOOL          wasHidden;
@end

@implementation AWPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _loadDefaults];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if(self.navigationController)
        self.navigationController.navigationBar.translucent = YES;
    
    if([self _isModal]) {
        _presentedAsModal = YES;
        [self.navigationItem setHidesBackButton:TRUE];
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(_cancel)];
        [self.navigationItem setLeftBarButtonItem:leftBarButton];
    }
    
    if(_currentOperation == PasscodeOperationLocked) {
        _isPasscodeScreen = YES;
        [self _touchIDInit];
        
        // We only need to listen to rotation events on iOS versions below 8.
        // And only on the "Locked" view.
        if(AW_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            // Subscribe to rotation events
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(statusBarFrameOrOrientationChanged:)
             name:UIApplicationDidChangeStatusBarOrientationNotification
             object:nil];
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(statusBarFrameOrOrientationChanged:)
             name:UIApplicationDidChangeStatusBarFrameNotification
             object:nil];
        }
    } else if(_currentOperation == PasscodeOperationDisable) {
        _isPasscodeScreen = NO;
        [self _touchIDInit];
    } else {
        _isPasscodeScreen = NO;
    }
    
    [self _setupRootViews];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_passcodeTextField becomeFirstResponder];
}


- (void)viewDidAppear:(BOOL)animated {
   
    if (!_passcodeTextField.isFirstResponder)
        [_passcodeTextField becomeFirstResponder];
        // We need to make sure that we always start in the correct rotation if launched in landscape
    if((_wasHidden || AW_SYSTEM_VERSION_LESS_THAN(@"8.0")) && _currentOperation == PasscodeOperationLocked) {
        _wasHidden = NO;
         [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
        [self statusBarFrameOrOrientationChanged:nil];
    }
     [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    // Will use this to make sure that the keyboard actually gets dismissed
    id firstResponder = [UIResponder getCurrentFirstResponderReference];
    if([firstResponder canResignFirstResponder])
        [firstResponder resignFirstResponder];
    
    [super viewWillDisappear:animated];
    
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        // We need to release the strong reference in the \
        singleton to the passcode view.
        [AWPasscodeHandler resetHandler];
    }
    
    _wasHidden = YES;
}


-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotate {
    return YES;
}


- (void)_cancel {
    [self popToCallerAnimated:YES];
}


- (void)_loadDefaults {
    [self _loadGapDefaults];
    [self _loadFontDefaults];
    [self _loadColorDefaults];
    [self _loadMiscDefaults];
}


- (void)_loadMiscDefaults {
    _passcodeCharacter = @"\u2014"; // A longer "-";
    
    _localizationTableName = @"AWPasscodeViewControllerLocalization";
}


- (void)_loadGapDefaults {
    _iPadFontSizeModifier = 1.5;
    _iPhoneHorizontalGap = 40.0;
    _horizontalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? _iPhoneHorizontalGap * _iPadFontSizeModifier : _iPhoneHorizontalGap;
    _verticalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60.0f : 25.0f;
    _modifierForBottomVerticalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.6f : 3.0f;
    _failedAttemptLabelGap = _verticalGap * _modifierForBottomVerticalGap - 2.0f;
    _passcodeOverlayHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 96.0f : 40.0f;
}


- (void)_loadFontDefaults {
    _labelFontSize = 15.0;
    _passcodeFontSize = 33.0;
    _labelFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
    [UIFont fontWithName: @"AvenirNext-Regular" size:_labelFontSize * _iPadFontSizeModifier] :
    [UIFont fontWithName: @"AvenirNext-Regular" size:_labelFontSize];
    _passcodeFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
    [UIFont fontWithName: @"AvenirNext-Regular" size: _passcodeFontSize * _iPadFontSizeModifier] :
    [UIFont fontWithName: @"AvenirNext-Regular" size: _passcodeFontSize];
}


- (void)_loadColorDefaults {
    // Backgrounds
    _backgroundColor =  [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f];
    _passcodeBackgroundColor = [UIColor clearColor];
    _coverViewBackgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:1.0f alpha:1.00f];
    _failedAttemptLabelBackgroundColor =  [UIColor colorWithRed:0.8f green:0.1f blue:0.2f alpha:1.000f];
    _enterPasscodeLabelBackgroundColor = [UIColor clearColor];
    
    // Text
    _labelTextColor = [UIColor colorWithWhite:0.31f alpha:1.0f];
    _passcodeTextColor = [UIColor colorWithWhite:0.31f alpha:1.0f];
    _failedAttemptLabelTextColor = [UIColor whiteColor];
}


#pragma mark - Touch ID

- (void)_touchIDInit {
    if (!self.context && [AWPasscodeHandler useTouchID]) {
        self.context = [[LAContext alloc] init];
        
        NSError *error = nil;
        if ([self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            if (error) {
                // Just return. We simply can't use the touch id. SO just skip it!
                return;
            }
            // Authenticate User
            [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                         localizedReason:NSLocalizedStringWithDefaultValue(@"TouchID", _localizationTableName, [NSBundle mainBundle], @"Unlock using Touch ID", @"Unlock using Touch ID")
                                   reply:^(BOOL success, NSError *error) {
                                       if (error) {
                                           self.context = nil;
                                           return;
                                       }
                                       if (success) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self _validatePasscode:nil verifiedByTouchID:YES];
                                           });
                                       }
                                       self.context = nil;
                                   }];
        }
    }
}


#pragma mark - View setup

- (void)_setupRootViews {
    // Create the container view
    _containerView = [AWPasscodeHandler createFrostView:_backgroundColor];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(_keyboardHandler)];
    
    [_containerView addGestureRecognizer:tap];
    
    // Background image view
    _backgroundImageView = [UIImageView new];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.layer.masksToBounds = YES;
    _backgroundImageView.image = _backgroundImage;
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_backgroundImageView];
    
    // Add the frost effect
    //[[AWPasscodeHandler sharedHandler] addBlurToView:_containerView withFallbackBackgroudColor:_backgroundColor];
    
    // Add a container for the passcode
    _passcodeEntryView = [UIView new];
    _passcodeEntryView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add the "containers" view to self and containerview
    [self.view addSubview:_containerView];
    [_containerView addSubview:_passcodeEntryView];
    
    // Additional view setup
    [self _setupLabels];
    [self _setupPasscodeFields];
    
    // Lastly setup the constraints for the view
    [self addConstraints];
}


- (void)_setupLabels {
    _mainLabel = [UILabel new];
    _mainLabel.backgroundColor = _enterPasscodeLabelBackgroundColor;
    _mainLabel.numberOfLines = 0;
    _mainLabel.textColor = _labelTextColor;
    _mainLabel.font = _labelFont;
    _mainLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview: _mainLabel];
    
    
    _failedLabel = [UILabel new];
    _failedLabel.text = @"1 Passcode Failed Attempt";
    _failedLabel.numberOfLines = 0;
    _failedLabel.backgroundColor	= _failedAttemptLabelBackgroundColor;
    _failedLabel.hidden = YES;
    _failedLabel.textColor = _failedAttemptLabelTextColor;
    _failedLabel.font = _labelFont;
    _failedLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview: _failedLabel];
    
    _mainLabel.text = (self.currentOperation==PasscodeOperationEnable) ? NSLocalizedStringWithDefaultValue(@"New", _localizationTableName, [NSBundle mainBundle], @"Enter a new Passcode", @"The soon-to-be entered passcode") : NSLocalizedStringWithDefaultValue(@"Locked", _localizationTableName, [NSBundle mainBundle], @"Enter Passcode", @"The needed passcode");
    
    _mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _failedLabel.translatesAutoresizingMaskIntoConstraints = NO;
}


- (void)_setupPasscodeFields {
    _passcodeTextField = [UITextField new];
    _passcodeTextField.userInteractionEnabled = YES;
    _passcodeTextField.delegate = self;
    _passcodeTextField.secureTextEntry = YES;
    _passcodeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _passcodeTextField.hidden = YES;
    _passcodeTextField.enabled = YES;
    _passcodeTextField.tag = 1;
    _passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:_passcodeTextField];
    
    _firstDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_firstDigitTextField];
    
    _secondDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_secondDigitTextField];
    
    _thirdDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_thirdDigitTextField];
    
    _fourthDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_fourthDigitTextField];
}


- (UITextField *)_makeDigitField{
    UITextField *field = [UITextField new];
    field.backgroundColor = _passcodeBackgroundColor;
    field.textAlignment = NSTextAlignmentCenter;
    field.text = _passcodeCharacter;
    field.textColor = _passcodeTextColor;
    field.font = _passcodeFont;
    field.secureTextEntry = NO;
    field.userInteractionEnabled = NO;
    field.translatesAutoresizingMaskIntoConstraints = NO;
    [field setBorderStyle:UITextBorderStyleNone];
    return field;
}


#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (CGFloat)_getFailedHeight {
    // Fetch correct sizes during runtime. Would fail if used as a define in compiletime
    if ([_failedLabel respondsToSelector:@selector(sizeWithAttributes:)]) {
        // iOS7+
        return [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].height;
    } else {
        // <iOS7
        return [_failedLabel.text sizeWithFont:_labelFont].height;
    }
}


- (CGFloat)_getFailedWidth {
    // Fetch correct sizes during runtime. Would fail if used as a define in compiletime
    if ([_failedLabel respondsToSelector:@selector(sizeWithAttributes:)]) {
        // iOS7+
        return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].width + 60.0f : [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].width + 30.0f);
    } else {
        // <iOS7
        return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedLabel.text sizeWithFont:_labelFont].width + 60.0f : [_failedLabel.text sizeWithFont:_labelFont].width + 20.0f);
    }
}
#pragma GCC diagnostic pop


- (void)_resetTextFields {
    if (![_passcodeTextField isFirstResponder])
        [_passcodeTextField becomeFirstResponder];
    _firstDigitTextField.secureTextEntry    = NO;
    _secondDigitTextField.secureTextEntry   = NO;
    _thirdDigitTextField.secureTextEntry    = NO;
    _fourthDigitTextField.secureTextEntry   = NO;
    _passcodeTextField.text                 = @"";
}


- (void)resetUI {
    [self _resetTextFields];
    _failedLabel.backgroundColor    = _failedAttemptLabelBackgroundColor;
    _failedLabel.textColor          = _failedAttemptLabelTextColor;
    _passcodeTextField.text         = @"";
    _failedLabel.hidden             = YES;
    
    switch (_currentOperation) {
        case PasscodeOperationChange:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"New", _localizationTableName, [NSBundle mainBundle], @"Enter new Passcode", @"The soon-to-be entered passcode");
        }
            break;
        case PasscodeOperationChangeVerify:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"ReEnter", _localizationTableName, [NSBundle mainBundle], @"Re-enter the Passcode", @"Re-entered passcode");
        }
            break;
        case PasscodeOperationChangeMissmatch:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"Missmatch", _localizationTableName, [NSBundle mainBundle], @"Passcodes missmatch.\r\nPlease enter a new Passcode", @"Missmatch. Enter new  passcode");
        }
            break;
        case PasscodeOperationDisable:
        {
            // Nothing here!
        }
            break;
        case PasscodeOperationEnable:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"New", _localizationTableName, [NSBundle mainBundle], @"Enter new Passcode", @"The soon-to-be entered passcode");
        }
            break;
        case PasscodeOperationLocked:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"Locked", _localizationTableName, [NSBundle mainBundle], @"Enter Passcode", @"The needed passcode");
        }
            break;
        case PasscodeOperationNone:
        {
            // Should not come here
        }
            break;
        default:
            break;
    }
}


- (void) addConstraints {
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_containerView, _backgroundImageView);
    
    // Container view (blur view)
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_containerView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_containerView]|" options:0 metrics:nil views:views]];
    
    // Background image view
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundImageView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_backgroundImageView]|" options:0 metrics:nil views:views]];
    
    // Passcode entry view
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem: _passcodeEntryView
                              attribute: NSLayoutAttributeLeft
                              relatedBy: NSLayoutRelationEqual
                              toItem:self.view
                              attribute: NSLayoutAttributeCenterX
                              multiplier: 1.0f
                              constant: 1.0f]];
    [self.view addConstraint:[NSLayoutConstraint
                              constraintWithItem: _passcodeEntryView
                              attribute: NSLayoutAttributeCenterY
                              relatedBy: NSLayoutRelationEqual
                              toItem: self.mainLabel
                              attribute: NSLayoutAttributeBottom
                              multiplier: 1.0f
                              constant: 1.0f]];
    
    // MainLabel
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self.mainLabel
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_containerView
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1.0
                                   constant:0.0f]];
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem:self.mainLabel
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:_containerView
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1.0
                                   constant:-self.view.frame.size.height*0.2]];
    
    // Digit fields
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _firstDigitTextField
                                       attribute: NSLayoutAttributeLeft
                                       relatedBy: NSLayoutRelationEqual
                                       toItem:_passcodeEntryView
                                       attribute: NSLayoutAttributeCenterX
                                       multiplier: 1.0f
                                       constant: - _horizontalGap * 1.5f - 2.0f]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _secondDigitTextField
                                       attribute: NSLayoutAttributeLeft
                                       relatedBy: NSLayoutRelationEqual
                                       toItem:_passcodeEntryView
                                       attribute: NSLayoutAttributeCenterX
                                       multiplier: 1.0f
                                       constant: - _horizontalGap * 2/3 - 2.0f]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _thirdDigitTextField
                                       attribute: NSLayoutAttributeLeft
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeCenterX
                                       multiplier: 1.0f
                                       constant: _horizontalGap * 1/6 - 2.0f]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _fourthDigitTextField
                                       attribute: NSLayoutAttributeLeft
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeCenterX
                                       multiplier: 1.0f
                                       constant: _horizontalGap - 2.0f]];
    
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _firstDigitTextField
                                       attribute: NSLayoutAttributeCenterY
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeBottom
                                       multiplier: 1.0f
                                       constant: _verticalGap]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _secondDigitTextField
                                       attribute: NSLayoutAttributeCenterY
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeBottom
                                       multiplier: 1.0f
                                       constant: _verticalGap]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _thirdDigitTextField
                                       attribute: NSLayoutAttributeCenterY
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeBottom
                                       multiplier: 1.0f
                                       constant: _verticalGap]];
    [_passcodeEntryView addConstraint:[NSLayoutConstraint
                                       constraintWithItem: _fourthDigitTextField
                                       attribute: NSLayoutAttributeCenterY
                                       relatedBy: NSLayoutRelationEqual
                                       toItem: _passcodeEntryView
                                       attribute: NSLayoutAttributeBottom
                                       multiplier: 1.0f
                                       constant: _verticalGap]];
    
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem: _failedLabel
                                   attribute: NSLayoutAttributeCenterX
                                   relatedBy: NSLayoutRelationEqual
                                   toItem: _containerView
                                   attribute: NSLayoutAttributeCenterX
                                   multiplier: 1.0f
                                   constant: 0.0f]];
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem: _failedLabel
                                   attribute: NSLayoutAttributeCenterY
                                   relatedBy: NSLayoutRelationEqual
                                   toItem: _mainLabel
                                   attribute: NSLayoutAttributeBottom
                                   multiplier: 1.0f
                                   constant: _failedAttemptLabelGap]];
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem: _failedLabel
                                   attribute: NSLayoutAttributeWidth
                                   relatedBy: NSLayoutRelationGreaterThanOrEqual
                                   toItem: nil
                                   attribute: NSLayoutAttributeNotAnAttribute
                                   multiplier: 1.0f
                                   constant: [self _getFailedWidth]]];
    [_containerView addConstraint:[NSLayoutConstraint
                                   constraintWithItem: _failedLabel
                                   attribute: NSLayoutAttributeHeight
                                   relatedBy: NSLayoutRelationEqual
                                   toItem: nil
                                   attribute: NSLayoutAttributeNotAnAttribute
                                   multiplier: 1.0f
                                   constant: [self _getFailedHeight] + 6.0f]];
}


- (void)updateViewConstraints {
    [super updateViewConstraints];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString: @"\n"])
        return NO;
    
    NSString *typedString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // Limit to Decimal chars only!
    NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    
    if (typedString.length >= 1) _firstDigitTextField.secureTextEntry = YES;
    else _firstDigitTextField.secureTextEntry = NO;
    if (typedString.length >= 2) _secondDigitTextField.secureTextEntry = YES;
    else _secondDigitTextField.secureTextEntry = NO;
    if (typedString.length >= 3) _thirdDigitTextField.secureTextEntry = YES;
    else _thirdDigitTextField.secureTextEntry = NO;
    if (typedString.length >= 4) _fourthDigitTextField.secureTextEntry = YES;
    else _fourthDigitTextField.secureTextEntry = NO;
    
    if (typedString.length == 4) {
        // Make the last bullet show up
        [self _validatePasscode:typedString verifiedByTouchID:NO];
    }
    
    if (typedString.length > 4)
        return NO;
    
    
    return YES;
}





#pragma mark - Getters/setters

- (UIView*)containerView {
    return _containerView;
}


- (UIView*)passcodeEntryView {
    return _passcodeEntryView;
}


#pragma mark - Public methods

- (void)popToCallerAnimated:(BOOL)animated {
    if(_presentedAsModal) {
        [self dismissViewControllerAnimated:animated completion:^{
            [AWPasscodeHandler resetHandler];
        }];
    } else {
        [self.navigationController popViewControllerAnimated:animated];
    }
}


- (void)increaseFailCount:(NSUInteger)fails {
    
    if (fails == 1) {
        _failedLabel.text =
        NSLocalizedStringWithDefaultValue(@"Failed1", _localizationTableName, [NSBundle mainBundle], @"1 failed attempt", @"First failed attempt");
    }
    else {
        _failedLabel.text = [NSString stringWithFormat: NSLocalizedStringWithDefaultValue(@"Failed1", _localizationTableName, [NSBundle mainBundle], @"%i failed attempts", @"Subsequent failed attempts"), fails];
    }
    _failedLabel.layer.cornerRadius = [self _getFailedHeight] * 0.65f;
    _failedLabel.clipsToBounds = true;
    _failedLabel.hidden = NO;
    
    [self _resetTextFields];
}


#pragma mark - Private method helpers

- (BOOL)_isModal {
    return self.presentingViewController.presentedViewController == self
    || self.navigationController.presentingViewController.presentedViewController == self.navigationController
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}


- (void)_keyboardHandler {
    if(!_passcodeTextField.isFirstResponder) {
        [_passcodeTextField becomeFirstResponder];
    }
}


- (void)_validatePasscode:(NSString*)passcode verifiedByTouchID:(BOOL)verified {
    [[AWPasscodeHandler sharedHandler] validatePasscode:passcode verifiedByTouchID:verified];
}


#pragma mark - Handling rotation

- (void)setTransform:(CGAffineTransform)transform frame:(CGRect)frame {
    if(!CGRectEqualToRect(self.view.frame, frame)) {
        self.view.frame = frame;
    }
    
    if(!CGAffineTransformEqualToTransform(self.view.transform, transform)) {
        self.view.transform = transform;
    }
}


- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification {
    
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    
    if (AW_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        _containerView.frame = self.view.frame;
    }
    else {
        if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
            _containerView.frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.width, [UIApplication sharedApplication].keyWindow.frame.size.height);
        }
        else {
            CGRect frame = CGRectMake(0, 0, [UIApplication sharedApplication].keyWindow.frame.size.height, [UIApplication sharedApplication].keyWindow.frame.size.width);
            _containerView.frame = frame;
        }
        [_containerView updateConstraints];
        [_containerView layoutSubviews];
    }
}


- (NSUInteger)supportedInterfaceOrientations {
    if (_isPasscodeScreen)
        return AW_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAll;
    return UIInterfaceOrientationMaskAll;
}


// Inspired by AGWindow
- (UIInterfaceOrientation)desiredOrientation {
    UIInterfaceOrientation statusBarOrientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    UIInterfaceOrientationMask statusBarOrientationAsMask = UIInterfaceOrientationMaskFromOrientation(statusBarOrientation);
    if(self.supportedInterfaceOrientations & statusBarOrientationAsMask) {
        return statusBarOrientation;
    }
    else {
        if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskPortrait) {
            return UIInterfaceOrientationPortrait;
        }
        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft) {
            return UIInterfaceOrientationLandscapeLeft;
        }
        else if(self.supportedInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight) {
            return UIInterfaceOrientationLandscapeRight;
        }
        else {
            return UIInterfaceOrientationPortraitUpsideDown;
        }
    }
}


// Inspired by AGWindow
- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations {
    UIInterfaceOrientation orientation = [self desiredOrientation];
    CGFloat angle = UIInterfaceOrientationAngleOfOrientation(orientation);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
    // We need to support for example split-views on iPads also and so on...
    if(_isPasscodeScreen) {
        // This will always cover the whole screen! (During "locked" state
        [self setTransform: transform frame: self.view.window.bounds];
    } else {
        // The other views (for enabling, disabling,..) will always be shown with a parent. \
        Therefore, use the parent's bounds instead of the window's bounds.
        [self setTransform: transform frame: self.parentViewController.view.bounds];
    }
}


UIInterfaceOrientationMask UIInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation) {
    return 1 << orientation;
}


CGFloat UIInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation) {
    CGFloat angle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}

@end
