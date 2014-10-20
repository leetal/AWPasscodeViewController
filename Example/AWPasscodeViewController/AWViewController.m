//
//  AWViewController.m
//  AWPasscodeViewController
//
//  Created by Alexander Widerberg on 10/07/2014.
//  Copyright (c) 2014 Alexander Widerberg. All rights reserved.
//

#import "AWViewController.h"

@interface AWViewController ()

@end

@implementation AWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add a dummy image view to show fancy effects
    UIImageView *imageV = [UIImageView new];
    imageV.image = [UIImage imageNamed:@"Backgrounds"];
    imageV.contentMode = UIViewContentModeBottomLeft;
    imageV.layer.masksToBounds = YES;
    [imageV setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addSubview:imageV];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageV]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageV)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageV]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(imageV)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willClose:) name:@"passcodeViewControllerWillClose" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClose:) name:@"passcodeViewControllerDidClose" object:nil];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AWPasscodeHandler* handler = [AWPasscodeHandler sharedHandler];
    [handler showLockScreenWithAnimation:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification handlers

- (void) willClose:(NSNotification*)note {
}

- (void) didClose:(NSNotification*)note {
}

@end
