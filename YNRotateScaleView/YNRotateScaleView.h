//
//  YNRotateScaleView.h
//  RotateScaleViewDemo
//
//  Created by liyangly on 2018/9/21.
//  Copyright © 2018年 liyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YNRotateScaleView : UIView

- (instancetype)initWithImageName:(NSString *)imgName
                      borderColor:(UIColor *)bordercolor;

// 当前视图是否可旋转缩放删除，是否有虚线边框
@property (nonatomic, assign) BOOL canEdit;

@property (nonatomic, copy) void (^deleteAction)(void);

// 当前视图的中心偏移量
@property(assign,nonatomic) CGFloat beforeCenterOffsetX;
@property(assign,nonatomic) CGFloat beforeCenterOffsetY;

@end
