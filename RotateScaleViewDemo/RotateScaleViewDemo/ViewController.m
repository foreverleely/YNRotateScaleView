//
//  ViewController.m
//  RotateScaleViewDemo
//
//  Created by liyangly on 2018/9/21.
//  Copyright © 2018年 liyang. All rights reserved.
//

#import "ViewController.h"
// pod
#import "Masonry.h"
// view
#import "YNRotateScaleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
    
    YNRotateScaleView *rsView = [[YNRotateScaleView alloc] initWithImageName:@"yn_rotatescale_view_img" borderColor:[UIColor whiteColor]];
    rsView.canEdit = YES;
    [self.view addSubview:rsView];
    [rsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(100);
        make.centerY.mas_equalTo(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
