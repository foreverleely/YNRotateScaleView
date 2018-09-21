# YNRotateScaleView

1.注意不要忽略canEdit的初始化；

2.注意view的frame初始化，使用Masonry布局，布局时注意仅设定如下几个参数
```
        make.centerX.mas_equalTo(100);
        make.centerY.mas_equalTo(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
```
