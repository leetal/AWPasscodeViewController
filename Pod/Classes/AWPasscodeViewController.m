//
//  AWPasscodeViewController.m
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWPasscodeViewController.h"
#import "AWPasscodeHandler.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define kPasscodeCharWidth [_passcodeCharacter sizeWithAttributes: @{NSFontAttributeName : _passcodeFont}].width
#define kFailedAttemptLabelWidth (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].width + 60.0f : [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].width + 30.0f)
#define kFailedAttemptLabelHeight [_failedLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].height
#define kEnterPasscodeLabelWidth [_mainLabel.text sizeWithAttributes: @{NSFontAttributeName : _labelFont}].width
#else
#define kPasscodeCharWidth [_passcodeCharacter sizeWithFont:_passcodeFont].width
#define kFailedAttemptLabelWidth (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? [_failedAttemptLabel.text sizeWithFont:_labelFont].width + 60.0f : [_failedAttemptLabel.text sizeWithFont:_labelFont].width + 20.0f)
#define kFailedAttemptLabelHeight [_failedAttemptLabel.text sizeWithFont:_labelFont].height
#define kEnterPasscodeLabelWidth [_enterPasscodeLabel.text sizeWithFont:_labelFont].width
#endif

@interface AWPasscodeViewController ()

//@property (nonatomic, strong) UIView      *passcodeView;
@property (nonatomic, strong) UITextField *passcodeTextField;
@property (nonatomic, strong) UITextField *firstDigitTextField;
@property (nonatomic, strong) UITextField *secondDigitTextField;
@property (nonatomic, strong) UITextField *thirdDigitTextField;
@property (nonatomic, strong) UITextField *fourthDigitTextField;

@property (nonatomic, strong) UILabel     *failedLabel;
@property (nonatomic, strong) UILabel     *mainLabel;
@property (nonatomic, strong) UIView      *containerView;
@property (nonatomic, strong) UIView      *passcodeEntryView;

@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, assign) CGFloat     modifierForBottomVerticalGap;
@property (nonatomic, assign) CGFloat     iPadFontSizeModifier;
@property (nonatomic, assign) CGFloat     iPhoneHorizontalGap;
@end

@implementation AWPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _loadDefaults];
    // Do any additional setup after loading the view.
    if(_backgroundColor) {
        self.view.backgroundColor = _backgroundColor;
    } else {
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    [self _setupRootViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_passcodeTextField resignFirstResponder];

    [_passcodeTextField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // We need to keep track of the VC if added to for example a nav controller
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        // We need to release the strong reference in the Passcodehandler
        [AWPasscodeHandler resetHandler];
        [_passcodeTextField resignFirstResponder];
    }
    [self.view endEditing:YES];
}

-(void) dealloc {
    _passcodeTextField.delegate = nil;
    _passcodeTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void) _loadDefaults {
    [self _loadMiscDefaults];
    [self _loadGapDefaults];
    [self _loadFontDefaults];
    [self _loadColorDefaults];
}

- (void) _loadMiscDefaults {
    _passcodeCharacter = @"\u2014"; // A longer "-";
    _localizationTableName = @"AWPasscodeViewControllerLocalization";
}

- (void) _loadGapDefaults {
    _iPadFontSizeModifier = 1.5;
    _iPhoneHorizontalGap = 40.0;
    _horizontalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? _iPhoneHorizontalGap * _iPadFontSizeModifier : _iPhoneHorizontalGap;
    _verticalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 60.0f : 25.0f;
    _modifierForBottomVerticalGap = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2.6f : 3.0f;
    _failedAttemptLabelGap = _verticalGap * _modifierForBottomVerticalGap - 2.0f;
    _passcodeOverlayHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 96.0f : 40.0f;
}

- (void) _loadFontDefaults {
    _labelFontSize = 15.0;
    _passcodeFontSize = 33.0;
    _labelFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
    [UIFont fontWithName: @"AvenirNext-Regular" size:_labelFontSize * _iPadFontSizeModifier] :
    [UIFont fontWithName: @"AvenirNext-Regular" size:_labelFontSize];
    _passcodeFont = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?
    [UIFont fontWithName: @"AvenirNext-Regular" size: _passcodeFontSize * _iPadFontSizeModifier] :
    [UIFont fontWithName: @"AvenirNext-Regular" size: _passcodeFontSize];
}

- (void) _loadColorDefaults {
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

#pragma mark - View setup
- (void) _setupRootViews {
    // Create the container view
    _containerView = [UIView new];
    _containerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Background image view
    _backgroundImageView = [UIImageView new];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundImageView.layer.masksToBounds = YES;
    _backgroundImageView.image = _backgroundImage;
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_backgroundImageView];
    
    // Add the frost effect
    [self addBlurToView:_containerView];
    
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

- (void) _setupLabels {
    _mainLabel = [UILabel new];
    _mainLabel.backgroundColor = _enterPasscodeLabelBackgroundColor;
    _mainLabel.numberOfLines = 0;
    _mainLabel.textColor = _labelTextColor;
    _mainLabel.font = _labelFont;
    _mainLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview: _mainLabel];
    
    // It is also used to display the "Passcodes did not match" error message
    // if the user fails to confirm the passcode.
    _failedLabel = [UILabel new];
    _failedLabel.text = @"1 Passcode Failed Attempt";
    _failedLabel.numberOfLines = 0;
    _failedLabel.backgroundColor	= _failedAttemptLabelBackgroundColor;
    _failedLabel.hidden = YES;
    _failedLabel.textColor = _failedAttemptLabelTextColor;
    _failedLabel.font = _labelFont;
    _failedLabel.textAlignment = NSTextAlignmentCenter;
    [_containerView addSubview: _failedLabel];
    
    _mainLabel.text = (self.currentOperation==PasscodeOperationChange) ? NSLocalizedStringWithDefaultValue(@"New", _localizationTableName, [NSBundle mainBundle], @"Enter new Passcode", @"The soon-to-be entered passcode") : NSLocalizedStringWithDefaultValue(@"Locked", _localizationTableName, [NSBundle mainBundle], @"Enter Passcode", @"The needed passcode");
    
    _mainLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _failedLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void) _setupPasscodeFields {
    _passcodeTextField = [UITextField new];
    _passcodeTextField.userInteractionEnabled = YES;
    _passcodeTextField.delegate = self;
    _passcodeTextField.secureTextEntry = YES;
    _passcodeTextField.translatesAutoresizingMaskIntoConstraints = NO;
    _passcodeTextField.hidden = YES;
    _passcodeTextField.enabled = YES;
    _passcodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    [_passcodeEntryView addSubview:_passcodeTextField];
    [_passcodeTextField becomeFirstResponder];
    
    _firstDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_firstDigitTextField];
    
    _secondDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_secondDigitTextField];
    
    _thirdDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_thirdDigitTextField];
    
    _fourthDigitTextField = [self _makeDigitField];
    [_passcodeEntryView addSubview:_fourthDigitTextField];
}

- (void)addBlurToView:(UIView *)view {
    UIView *blurView = nil;
    
    if([UIBlurEffect class]) { // iOS 8
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = view.frame;
        
    } else { //iOS 7
        blurView = [[UIToolbar alloc] initWithFrame:view.bounds];
    }
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addSubview:blurView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
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

- (void)_resetTextFields {
    if (![_passcodeTextField isFirstResponder])
        [_passcodeTextField becomeFirstResponder];
    
    _firstDigitTextField.secureTextEntry = NO;
    _secondDigitTextField.secureTextEntry = NO;
    _thirdDigitTextField.secureTextEntry = NO;
    _fourthDigitTextField.secureTextEntry = NO;
}

- (void)resetUI {
    [self _resetTextFields];
    _failedLabel.backgroundColor    = _failedAttemptLabelBackgroundColor;
    _failedLabel.textColor          = _failedAttemptLabelTextColor;
    _passcodeTextField.text         = @"";
    
    switch (_currentOperation) {
        case PasscodeOperationChange:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"New", _localizationTableName, [NSBundle mainBundle], @"Enter new Passcode", @"The soon-to-be entered passcode");
        }
            break;
        case PasscodeOperationChangeVerify:
        {
            _mainLabel.text = NSLocalizedStringWithDefaultValue(@"ReEnter", _localizationTableName, [NSBundle mainBundle], @"Re-enterthe Passcode", @"Re-entered passcode");
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
                                       constant: _verticalGap]];
    
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
                              constant: kFailedAttemptLabelWidth]];
    [_containerView addConstraint:[NSLayoutConstraint
                              constraintWithItem: _failedLabel
                              attribute: NSLayoutAttributeHeight
                              relatedBy: NSLayoutRelationEqual
                              toItem: nil
                              attribute: NSLayoutAttributeNotAnAttribute
                              multiplier: 1.0f
                              constant: kFailedAttemptLabelHeight + 6.0f]];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString: @"\n"])
        return NO;
    
    NSString *typedString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
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
        [self performSelector: @selector(_validatePasscode:)
                   withObject: typedString
                   afterDelay: 0.05];
    }
    
    if (typedString.length > 4)
        return NO;
    
    
    return YES;
}

- (void) _validatePasscode:(NSString*)passcode {
    [[AWPasscodeHandler sharedHandler] validatePasscode:passcode];
}

#pragma mark - Getters/setters
- (UIView*)containerView {
    return _containerView;
}
- (UIView*)passcodeEntryView {
    return _passcodeEntryView;
}

@end
