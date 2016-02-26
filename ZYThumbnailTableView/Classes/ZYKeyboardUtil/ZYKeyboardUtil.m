//
//  ZYKeyboardUtil.m
//  ZYKeyboardUtil
//
//  Created by lzy on 15/12/26.
//  Copyright © 2015年 lzy . All rights reserved.
//

#import "ZYKeyboardUtil.h"

#define MARGIN_KEYBOARD_DEFAULT 10


@interface ZYKeyboardUtil()

@property (assign, nonatomic) BOOL keyboardObserveEnabled;
@property (assign, nonatomic) int appearPostIndex;
@property (strong, nonatomic) KeyboardInfo *keyboardInfo;
@property (assign, nonatomic) BOOL haveRegisterObserver;


@property (copy, nonatomic) animateWhenKeyboardAppearBlock animateWhenKeyboardAppearBlock;
@property (copy, nonatomic) animateWhenKeyboardAppearAutomaticAnimBlock animateWhenKeyboardAppearAutomaticAnimBlock;
@property (copy, nonatomic) animateWhenKeyboardDisappearBlock animateWhenKeyboardDisappearBlock;
@property (copy, nonatomic) printKeyboardInfoBlock printKeyboardInfoBlock;

@end


@implementation ZYKeyboardUtil

- (instancetype)init {
    self = [super init];
    if(self) {
        //        [self registerObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 懒加载方式注册观察者
- (void)registerObserver {
    if (_haveRegisterObserver == YES) {
        return;
    }
    
    self.haveRegisterObserver = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark - 重写KeyboardInfo set方法，调用animationBlock
- (void)setKeyboardInfo:(KeyboardInfo *)keyboardInfo {
    //home键使应用进入后台也会有某些通知
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    
    _keyboardInfo = keyboardInfo;
    
    if(!keyboardInfo.isSameAction || (keyboardInfo.heightIncrement != 0)) {
        
        [UIView animateWithDuration:keyboardInfo.animationDuration animations:^{
            switch (keyboardInfo.action) {
                case KeyboardActionShow:
                    if(self.animateWhenKeyboardAppearBlock != nil) {
                        self.animateWhenKeyboardAppearBlock(++self.appearPostIndex, keyboardInfo.frameEnd, keyboardInfo.frameEnd.size.height, keyboardInfo.heightIncrement);
                        //                        self.appearPostIndex ++;
                    } else if (self.animateWhenKeyboardAppearAutomaticAnimBlock != nil) {
                        NSDictionary *adaptiveDict =  self.animateWhenKeyboardAppearAutomaticAnimBlock();
                        UIView *keyboardAdaptiveView = adaptiveDict[ADAPTIVE_VIEW];
                        UIView *controllerView = adaptiveDict[CONTROLLER_VIEW];
                        [self fitKeyboardAutoAutomatically:keyboardAdaptiveView controllerView:controllerView keyboardRect:keyboardInfo.frameEnd];
                    }
                    break;
                case KeyboardActionHide:
                    if(self.animateWhenKeyboardDisappearBlock != nil) {
                        self.animateWhenKeyboardDisappearBlock(keyboardInfo.frameEnd.size.height);
                        self.appearPostIndex = 0;
                    }
                    break;
                default:
                    break;
            }
        }completion:^(BOOL finished) {
            if(self.printKeyboardInfoBlock != nil && self.keyboardInfo != nil) {
                self.printKeyboardInfoBlock(self, keyboardInfo);
            }
        }];
    }
}

- (void)fitKeyboardAutoAutomatically:(UIView *)adaptiveView controllerView:(UIView *)controllerView keyboardRect:(CGRect)keyboardRect {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGRect convertRect = [adaptiveView.superview convertRect:adaptiveView.frame toView:window];
    
    if (CGRectGetMinY(keyboardRect) - MARGIN_KEYBOARD_DEFAULT < CGRectGetMaxY(convertRect)) {
        CGFloat signedDiff = CGRectGetMinY(keyboardRect) - CGRectGetMaxY(convertRect) - MARGIN_KEYBOARD_DEFAULT;
        //updateOriginY
        CGFloat newOriginY = CGRectGetMinY(controllerView.frame) + signedDiff;
        controllerView.frame = CGRectMake(controllerView.frame.origin.x, newOriginY, controllerView.frame.size.width, controllerView.frame.size.height);
    }
}

#pragma mark - 重写Block set方法，懒加载方式注册观察者
- (void)setAnimateWhenKeyboardAppearBlock:(animateWhenKeyboardAppearBlock)animateWhenKeyboardAppearBlock {
    _animateWhenKeyboardAppearBlock = animateWhenKeyboardAppearBlock;
    [self registerObserver];
}

- (void)setAnimateWhenKeyboardAppearAutomaticAnimBlock:(animateWhenKeyboardAppearAutomaticAnimBlock)animateWhenKeyboardAppearBlockAutomaticAnim {
    _animateWhenKeyboardAppearAutomaticAnimBlock = animateWhenKeyboardAppearBlockAutomaticAnim;
    [self registerObserver];
}

- (void)setAnimateWhenKeyboardDisappearBlock:(animateWhenKeyboardDisappearBlock)animateWhenKeyboardDisappearBlock {
    _animateWhenKeyboardDisappearBlock = animateWhenKeyboardDisappearBlock;
    [self registerObserver];
}

- (void)setPrintKeyboardInfoBlock:(printKeyboardInfoBlock)printKeyboardInfoBlock {
    _printKeyboardInfoBlock = printKeyboardInfoBlock;
    [self registerObserver];
}

#pragma mark 响应selector
- (void)keyboardWillShow:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionShow];
}

//UIKeyboardWillChangeFrameNotification 可解决ios9 对于 第三方键盘 UIKeyboardWillShowNotification漏发的问题
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    if(self.keyboardInfo.action == KeyboardActionShow){
        //只要前一次是show，这次change就是show
        //        [self handleKeyboard:notification keyboardAction:KeyboardActionShow];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self handleKeyboard:notification keyboardAction:KeyboardActionHide];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    //置空
    self.keyboardInfo = nil;
}

#pragma mark 处理键盘事件
- (void)handleKeyboard:(NSNotification *)notification keyboardAction:(KeyboardAction)keyboardAction {
    //home键使应用进入后台也会有某些通知,不响应
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        return;
    }
    //解析通知
    NSDictionary *infoDict = [notification userInfo];
    CGRect frameBegin = [[infoDict objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect frameEnd = [[infoDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat previousHeight;
    if(self.keyboardInfo.frameEnd.size.height > 0) {
        previousHeight = self.keyboardInfo.frameEnd.size.height;
    }else {
        previousHeight = 0;
    }
    
    CGFloat heightIncrement = frameEnd.size.height - previousHeight;
    
    BOOL isSameAction;
    if(self.keyboardInfo.action == keyboardAction) {
        isSameAction = YES;
    }else {
        isSameAction = NO;
    }
    
    KeyboardInfo *info = [[KeyboardInfo alloc] init];
    [info fillKeyboardInfoWithDuration:DURATION_ANIMATION frameBegin:frameBegin frameEnd:frameEnd heightIncrement:heightIncrement action:keyboardAction isSameAction:isSameAction];
    
    self.keyboardInfo = info;
}

- (void)fillKeyboardInfoWithKeyboardInfo:(KeyboardInfo *)keyboardInfo duration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction {
    keyboardInfo.animationDuration = duration;
    keyboardInfo.frameBegin = frameBegin;
    keyboardInfo.frameEnd = frameEnd;
    keyboardInfo.heightIncrement = heightIncrement;
    keyboardInfo.action = action;
    keyboardInfo.isSameAction = isSameAction;
}

@end




#pragma mark - KeyboardInfo(model)
@interface KeyboardInfo()
- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction;
@end

@implementation KeyboardInfo

- (void)fillKeyboardInfoWithDuration:(CGFloat)duration frameBegin:(CGRect)frameBegin frameEnd:(CGRect)frameEnd heightIncrement:(CGFloat)heightIncrement action:(KeyboardAction)action isSameAction:(BOOL)isSameAction {
    self.animationDuration = duration;
    self.frameBegin = frameBegin;
    self.frameEnd = frameEnd;
    self.heightIncrement = heightIncrement;
    self.action = action;
    self.isSameAction = isSameAction;
}


@end
