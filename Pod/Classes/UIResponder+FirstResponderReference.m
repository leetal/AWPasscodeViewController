//
//  UIResponder+FirstResponderReference.m
//  Pods
//
//  Created by Alexander Widerberg on 2014-10-21.
//
//

#import "UIResponder+FirstResponderReference.h"
static __weak id currentFirstResponderReference;
@implementation UIResponder (FirstResponderReference)
+(id)getCurrentFirstResponderReference {
    currentFirstResponderReference = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponderReference;
}
-(void)findFirstResponder:(id)sender {
    currentFirstResponderReference = self;
}
@end
