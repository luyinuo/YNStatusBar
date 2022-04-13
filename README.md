# YNStatusBar

* 自定义状态栏：包含：时间、网络状态、电池电量、充电状态

* 在iOS13更新后，在横屏模式下看不到状态栏的信息了。目前各大视频APP平台，状态栏都是自家添加的，你会发现各家基本上都不太一样。但都有共同点：时间+电池+网络状态。于是参考B站的横屏状态栏，自己封装了一个状态栏。



## 集成

```
pod 'YNStatusBar'
```
## 使用

一行代码搞定

```
    YNStatusBar *bar = [[YNStatusBar alloc] initWithFrame:topToolView.bounds];
    bar.refreshTime = 2;//刷新时间，默认是5秒
    [topToolView addSubview:bar];
```

## Screenshots

![
imge01
](https://github.com/luyinuo/YNStatusBar/blob/master/demo_01.PNG)

## Bilibili截屏
![
imge02
](https://github.com/luyinuo/YNStatusBar/blob/master/demo_02.PNG)
