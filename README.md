# barrage

A new Flutter package project.


## 弹幕展示

![](https://tva1.sinaimg.cn/large/006y8mN6ly1g9a9n8x4vsg30hs0vdu0x.gif)

### 使用
```dart
import 'package:barrage/barrage.dart';
```
```dart
BarrageView<TestDataBean>(
                key: _barrageKey,
                data: dataList,
                width: width,
                topPadding: 30,
                itemBgColor: Colors.transparent,
                itemHeight: 24,
                selfItemBgColor: Colors.transparent,
                textColor: Colors.red,
                textSize: 16,
                selfTextColor: Colors.red,
                currentTimeInMs: currentTimeInMs,
                startTimeInSecond: 0,
                clickCallback: () {},
                itemClickCallback: (startX, startY, item) {},
              )
```
### 属性说明
|  字段 | 含义   |
| ------------ | ------------ |
| data  |   弹幕数据 Lst<T>|
| witdh  | 整个弹幕展示宽度   |
| maxLine  | 显示的最大行数  |
|  topPadding |  离顶部距离 |
|  itemHeight |  每个弹幕的高度 |
|  itemBgColor | 每个弹幕的背景颜色  |
|  selfItemBgColor |自己发的弹幕的背景颜色  |
|  textSize | 每个弹幕的字体大小  |
| textColor  |  每个弹幕的颜色|
|  selfTextColor | 自己发的弹幕的颜色   |
| startTimeInSecond  | 弹幕起始播放时间   |
|  currentTimeInMs | 当前时间  |
|  velocity | 移动速度  |
|  itemClickCallback |  点击每一个弹幕的回调|
| verticalPadding  |  弹幕之间的纵向距离 |
| horizontalPadding  |  弹幕之间的横向距离 |
| innerHorizontalPadding  |  每个弹幕本身的水平padding |



