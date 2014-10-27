//
//  UIResponder+FirstResponder.m
//  Pods
//
//  Created by Xcerion on 2014-10-21.
//
//

#import "UIResponder+FirstResponder.h"
static __weak id currentFirstResponderReference;
@implementation UIResponder (FirstResponder)
+(id)getCurrentFirstResponderReference {
    currentFirstResponderReference = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponderReference;
}
-(void)findFirstResponder:(id)sender {
    currentFirstResponderReference = self;
}
@end
