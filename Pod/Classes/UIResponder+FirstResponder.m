//
//  UIResponder+FirstResponder.m
//  Pods
//
//  Created by Xcerion on 2014-10-21.
//
//

#import "UIResponder+FirstResponder.h"
static __weak id currentFirstResponder;
@implementation UIResponder (FirstResponder)
+(id)getCurrentFirstResponderReference {
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
-(void)findFirstResponder:(id)sender {
    currentFirstResponder = self;
}
@end
