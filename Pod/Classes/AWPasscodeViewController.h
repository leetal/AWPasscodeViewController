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
    PasscodeOperationEnable,
    PasscodeOperationChange,
    PasscodeOperationChangeLocked,
    PasscodeOperationChangeVerify,
    PasscodeOperationChangeMissmatch,
    PasscodeOperationLocked,
    PasscodeOperationDisable
};

@interface AWPasscodeViewController : UIViewController <UITextFieldDelegate>
/**
 @brief The actual passcode field (hidden on screen)
 */
@property (nonatomic, strong) UITextField   *passcodeTextField;
/**
 @brief The current ongoing operation
 */
@property (nonatomic, assign) PasscodeOperation currentOperation UI_APPEARANCE_SELECTOR;
/**
 @brief The gap between the passcode digits.
 */
@property (nonatomic, assign) CGFloat   horizontalGap UI_APPEARANCE_SELECTOR;
/**
 @brief The gap between the top label and the passcode digits/field.
 */
@property (nonatomic, assign) CGFloat   verticalGap UI_APPEARANCE_SELECTOR;
/**
 @brief The gap between the passcode digits and the failed label.
 */
@property (nonatomic, assign) CGFloat   failedAttemptLabelGap UI_APPEARANCE_SELECTOR;
/**
 @brief The height for the complex passcode overlay.
 */
@property (nonatomic, assign) CGFloat   passcodeOverlayHeight UI_APPEARANCE_SELECTOR;
/**
 @brief The font size for the top label.
 */
@property (nonatomic, assign) CGFloat   labelFontSize UI_APPEARANCE_SELECTOR;
/**
 @brief The font size for the passcode digits.
 */
@property (nonatomic, assign) CGFloat   passcodeFontSize UI_APPEARANCE_SELECTOR;
/**
 @brief The font for the top label.
 */
@property (nonatomic, strong) UIFont    *labelFont UI_APPEARANCE_SELECTOR;
/**
 @brief The font for the passcode digits.
 */
@property (nonatomic, strong) UIFont    *passcodeFont UI_APPEARANCE_SELECTOR;
/**
 @brief The background color for the top label.
 */
@property (nonatomic, strong) UIColor   *enterPasscodeLabelBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 @brief The background color for the view.
 */
@property (nonatomic, strong) UIColor   *backgroundColor UI_APPEARANCE_SELECTOR;
/**
 @brief The background color for the cover view that appears on top of the app, visible in the multitasking.
 */
@property (nonatomic, strong) UIColor   *coverViewBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 @brief The background color for the passcode digits.
 */
@property (nonatomic, strong) UIColor   *passcodeBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 @brief The background color for the failed attempt label.
 */
@property (nonatomic, strong) UIColor   *failedAttemptLabelBackgroundColor UI_APPEARANCE_SELECTOR;
/**
 @brief The text color for the top label.
 */
@property (nonatomic, strong) UIColor   *labelTextColor UI_APPEARANCE_SELECTOR;
/**
 @brief The text color for the passcode digits.
 */
@property (nonatomic, strong) UIColor   *passcodeTextColor UI_APPEARANCE_SELECTOR;
/**
 @brief The text color for the failed attempt label.
 */
@property (nonatomic, strong) UIColor   *failedAttemptLabelTextColor UI_APPEARANCE_SELECTOR;
/**
 @brief The background image of the presenting view.
 */
@property (nonatomic, weak) UIImage   *backgroundImage;
/**
 @brief The character for the passcode digit.
 */
@property (nonatomic, strong) NSString  *passcodeCharacter;
/**
 @brief The table name for NSLocalizedStringFromTable.
 */
@property (nonatomic, strong) NSString  *localizationTableName;
/**
 @brief Boolean indicationg wheter (@c YES) or not (@c NO) the view is displayed as a passcode screen.
 */
@property (nonatomic, assign) BOOL  isPasscodeScreen;

// ##########################################################

- (UIView*)containerView;
- (UIView*)passcodeEntryView;
- (void)resetUI;
- (void)popToCallerAnimated:(BOOL)animated;
- (void)increaseFailCount:(NSUInteger)fails;

@end