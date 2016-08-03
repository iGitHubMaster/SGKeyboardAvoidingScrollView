//
//  SGKeyboardAvoidingScrollView.m
//  TravelPlugin
//
//  Created by 王少刚 on 16/8/3.
//  Copyright © 2016年 Autohome. All rights reserved.
//

#import "SGKeyboardAvoidingScrollView.h"

@interface SGKeyboardAvoidingScrollView()
{
    CGFloat _distance;
}

@end

@implementation SGKeyboardAvoidingScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initial];
    }
    return self;
}

-(void)awakeFromNib
{
    [self initial];
}

#pragma mark 让所有可能执行的构造方法都调用这个方法
- (void)initial
{
    self.contentSize = self.bounds.size;
    CGSize rect = self.contentSize;
    rect.height += 1;
    self.contentSize = rect;
    
    //注册键盘监听
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark  键盘将要弹出来的时候调用
- (void)keyboardWillShow:(NSNotification *)notification
{
    //    NSLog(@"%@",notification);
    //UIKeyboardFrameEndUserInfoKey
    NSDictionary *dict = notification.userInfo;
    CGRect keyboardRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UITextField *firstResponder = [self findFirstResponder:self];
    //nil默认代表的是当前的window
    CGRect firstResponderRect = [firstResponder convertRect:firstResponder.bounds toView:nil];
    CGFloat distance = firstResponderRect.origin.y + firstResponderRect.size.height - keyboardRect.origin.y;
    _distance = distance;
    //    NSLog(@"键盘出来：%f 第一响应者：%@",_distance,firstResponder);
    //    NSLog(@"%@",firstResponder);
    if (distance > 0) {//说明键盘将第一响应者盖住
        [self animationWithUserInfo:notification.userInfo block:^{
            CGPoint offset = self.contentOffset;
            offset.y += distance;
            self.contentOffset = offset;
//            CGRect firstFrame = firstResponder.superview.frame;
//            firstFrame.origin.y -= _distance;
//            firstResponder.superview.frame = firstFrame;
        }];
    } else {
        _distance = 0;
    }
    
}

#pragma mark 键盘将要隐藏的时候调用
- (void)keyboardWillHide:(NSNotification *)notification
{
    [self animationWithUserInfo:notification.userInfo block:^{
        CGPoint offset = self.contentOffset;
        offset.y -= _distance;
        self.contentOffset = offset;
//         UITextField *firstResponder = [self findFirstResponder:self];
//        CGRect firstFrame = firstResponder.superview.frame;
//        firstFrame.origin.y += _distance;
//        firstResponder.superview.frame = firstFrame;
//        NSLog(@"键盘退出--------------------------：%f",_distance);
        _distance = 0;
    }];
}

#pragma mark 键盘弹出和隐藏的时候改变视图要执行的动画
- (void)animationWithUserInfo:(NSDictionary *)userInfo block:(void(^)(void)) block
{
    CGFloat duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    block();
    
    [UIView commitAnimations];
}

#pragma mark 查找第一响应者
- (UITextField *)findFirstResponder:(UIView *)view
{
    for(UITextField *child in view.subviews) {
        if ([child respondsToSelector:@selector(isFirstResponder)] && [child isFirstResponder]) {
            return child;
        }
        UITextField *textField = [self findFirstResponder:child];
        if (textField) {
            return textField;
        }
    }
    return nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endEditing:YES];
}

- (void)dealloc
{
    //取消键盘监听
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [center removeObserver:self];
}

@end
