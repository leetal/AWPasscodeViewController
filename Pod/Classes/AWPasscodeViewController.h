//
//  AWPasscodeViewController.h
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-07.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PasscodeOperation) {
    PasscodeOperationNone,
    PasscodeOperationEnter,
    PasscodeOperationChange,
    PasscodeOperationChangeVerify,
    PasscodeOperationLocked,
    PasscodeOperationRemove
};

@interface AWPasscodeViewController : UIViewController <UITextFieldDelegate>
/** 
 @brief The current ongoing operation
 */
@property (nonatomic, assign) PasscodeOperation currentOperation;
/**
 @brief The gap between the passcode digits.
 */
@property (nonatomic, assign) CGFloat   horizontalGap;
/**
 @brief The gap between the top label and the passcode digits/field.
 */
@property (nonatomic, assign) CGFloat   verticalGap;
/**
 @brief The gap between the passcode digits and the failed label.
 */
@property (nonatomic, assign) CGFloat   failedAttemptLabelGap;
/**
 @brief The height for the complex passcode overlay.
 */
@property (nonatomic, assign) CGFloat   passcodeOverlayHeight;
/**
 @brief The font size for the top label.
 */
@property (nonatomic, assign) CGFloat   labelFontSize;
/**
 @brief The font size for the passcode digits.
 */
@property (nonatomic, assign) CGFloat   passcodeFontSize;
/**
 @brief The font for the top label.
 */
@property (nonatomic, strong) UIFont    *labelFont;
/**
 @brief The font for the passcode digits.
 */
@property (nonatomic, strong) UIFont    *passcodeFont;
/**
 @brief The background color for the top label.
 */
@property (nonatomic, strong) UIColor   *enterPasscodeLabelBackgroundColor;
/**
 @brief The background color for the view.
 */
@property (nonatomic, strong) UIColor   *backgroundColor;
/**
 @brief The background color for the cover view that appears on top of the app, visible in the multitasking.
 */
@property (nonatomic, strong) UIColor   *coverViewBackgroundColor;
/**
 @brief The background color for the passcode digits.
 */
@property (nonatomic, strong) UIColor   *passcodeBackgroundColor;
/**
 @brief The background color for the failed attempt label.
 */
@property (nonatomic, strong) UIColor   *failedAttemptLabelBackgroundColor;
/**
 @brief The text color for the top label.
 */
@property (nonatomic, strong) UIColor   *labelTextColor;
/**
 @brief The text color for the passcode digits.
 */
@property (nonatomic, strong) UIColor   *passcodeTextColor;
/**
 @brief The text color for the failed attempt label.
 */
@property (nonatomic, strong) UIColor   *failedAttemptLabelTextColor;
/**
 @brief The character for the passcode digit.
 */
@property (nonatomic, strong) NSString  *passcodeCharacter;
/**
 @brief The table name for NSLocalizedStringFromTable.
 */
@property (nonatomic, strong) NSString  *localizationTableName;

// ##########################################################
- (void) prepareAsLockScreen;
- (void) prepareForChangingPasscode;
- (void) prepareForTurningOffPasscode;
- (void) prepareForEnablingPasscode;

@end
