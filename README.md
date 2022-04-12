# YNStatusBar

* 自定义状态栏：包含：时间、网络状态、电池电量、充电状态

* 横屏时状态栏不显示,这是因为iOS系统(iOS8之后)在视图横屏的时候默认把状态栏隐藏掉了

## 比较常见的应用场景：视频播放器横屏播放

* 目前各大视频APP平台主要的解决方案是，自己画一个？于是参考B站得横屏状态栏，方便各位看官使用，封装成了YNStatusBar.

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
](/demo_01.png)

![
imge02
](/demo_02.png)
