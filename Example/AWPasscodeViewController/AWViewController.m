//
//  AWViewController.m
//  AWPasscodeViewController
//
//  Created by Alexander Widerberg on 10/07/2014.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWViewController.h"
#import <AWPasscodeViewController/AWPasscodeHandler.h>

@interface AWViewController ()
@property (nonatomic, strong) UIButton *enable;
@property (nonatomic, strong) UIButton *change;
@property (nonatomic, strong) UIButton *test;
@property (nonatomic, strong) UIButton *disable;
@end

@implementation AWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    
    // Add a dummy image view to show frost effect (iOS7+ only)
    UIImageView *imageV = [UIImageView new];
    UIImage *image = [UIImage imageNamed:@"Background"];
    imageV.image = image;
    imageV.contentMode = UIViewContentModeBottomLeft;
    imageV.layer.masksToBounds = YES;
    [imageV setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:imageV];
    
    // Add constraints to the imageView
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageV]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageV)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageV]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageV)]];
    
    // Add buttons to the view
    _enable = [UIButton buttonWithType: UIButtonTypeSystem];
    [_enable setTitle:@"Enable" forState:UIControlStateNormal];
    _enable.translatesAutoresizingMaskIntoConstraints = NO;
    _change = [UIButton buttonWithType: UIButtonTypeSystem];
    [_change setTitle:@"Change" forState:UIControlStateNormal];
    _change.translatesAutoresizingMaskIntoConstraints = NO;
    _test = [UIButton buttonWithType: UIButtonTypeSystem];
    [_test setTitle:@"Test" forState:UIControlStateNormal];
    _test.translatesAutoresizingMaskIntoConstraints = NO;
    _disable = [UIButton buttonWithType: UIButtonTypeSystem];
    [_disable setTitle:@"Disable" forState:UIControlStateNormal];
    _disable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_enable];
    [self.view addSubview:_change];
    [self.view addSubview:_test];
    [self.view addSubview:_disable];
    
    // Add constraints to the buttons
    NSDictionary *views = NSDictionaryOfVariableBindings(_enable,_change,_test,_disable);
    NSDictionary *metrics = @{@"padding":@15.0};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=70-[_enable(>=30,<=44)]-padding-[_change(==_enable)]-padding-[_test(==_enable)]-padding-[_disable(==_enable)]" options:0 metrics:metrics views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_enable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_change attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_test attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_disable attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    
    // Subscribe to the passcode notifactions.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_passcodeWillClose:) name:@"passcodeViewControllerWillClose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_passcodeDidClose:) name:@"passcodeViewControllerDidClose" object:nil];
    
    // Add button handlers
    [_enable addTarget: self action: @selector(enablePasscode) forControlEvents: UIControlEventTouchUpInside];
    [_change addTarget: self action: @selector(changePasscode) forControlEvents: UIControlEventTouchUpInside];
    [_test addTarget: self action: @selector(testPasscode) forControlEvents: UIControlEventTouchUpInside];
    [_disable addTarget: self action: @selector(disablePasscode) forControlEvents: UIControlEventTouchUpInside];
    
    self.title = @"Demo";
    [self updateSettings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateSettings {
    if ([AWPasscodeHandler doesPasscodeExist]) {
        _enable.enabled = NO;
        _change.enabled = YES;
        _test.enabled = YES;
        _disable.enabled = YES;
    }
    else {
        _enable.enabled = YES;
        _change.enabled = NO;
        _test.enabled = NO;
        _disable.enabled = NO;
    }
}

#pragma mark -
#pragma mark - Button handlers
- (void)enablePasscode {
    [[AWPasscodeHandler sharedHandler] displayPasscodeToEnable:self asModal:NO];
}

- (void)changePasscode {
    [[AWPasscodeHandler sharedHandler] displayPasscodeToChange:self asModal:YES];
}

- (void)testPasscode {
    [[AWPasscodeHandler sharedHandler] showLockScreenWithAnimation:YES];
}

- (void)disablePasscode {
    [[AWPasscodeHandler sharedHandler] displayPasscodeToDisable:self asModal:YES];
}

#pragma mark - Notification handlers

- (void)_passcodeWillClose:(NSNotification*)note {
    [self updateSettings];
}

- (void)_passcodeDidClose:(NSNotification*)note {
    
}

@end
