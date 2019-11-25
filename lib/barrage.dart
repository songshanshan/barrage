library barrage;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef ClickBarrageItemCallback<T extends BarrageItemBean> = dynamic Function(
    double startX, double startY, T item);

typedef ClickBarrageCallback = dynamic Function();

class BarrageView<T extends BarrageItemBean> extends StatefulWidget {
  final List<T> data;
  final Color textColor;
  final Color selfTextColor;
  final double textSize;
  final int startTimeInSecond;
  final double width;
  final double topPadding;
  final int currentTimeInMs;
  final double velocity;
  final Color itemBgColor;
  final Color selfItemBgColor;
  final double itemHeight;
  final int maxLine;
  final List<Shadow> shadow;
  final double verticalPadding;
  final double horizontalPadding;
  final double innerHorizontalPadding;
  final ClickBarrageItemCallback itemClickCallback;
  final ClickBarrageCallback clickCallback;

  @override
  State<StatefulWidget> createState() {
    return BarrageViewState();
  }

  BarrageView(
      {Key key,
      @required this.data,
      @required this.width,
      this.textColor = Colors.black,
      this.selfTextColor = Colors.black,
      this.itemBgColor = Colors.transparent,
      this.selfItemBgColor = Colors.transparent,
      this.itemHeight = 24,
      this.maxLine = 9,
      this.verticalPadding = 8.0,
      this.topPadding,
      this.horizontalPadding = 16.0,
      this.innerHorizontalPadding = 16.0,
      this.currentTimeInMs = 0,
      this.textSize = 14.0,
      this.velocity = 60 / 1000,
      this.startTimeInSecond = 0,
      this.shadow,
      this.clickCallback,
      this.itemClickCallback})
      : super(key: key);
}

class BarrageViewState<T extends BarrageItemBean> extends State<BarrageView> {
  List<T> get barrageList => widget.data;

  int get currentTimeInMs => widget.currentTimeInMs;

  int get startTimeInSecond => widget.startTimeInSecond;

  int get maxLine => widget.maxLine;

  double get width => widget.width;

  double get textSize => widget.textSize;

  double get velocity => widget.velocity;

  double get itemHeight => widget.itemHeight;

  double get innerHorizontalPadding => widget.innerHorizontalPadding;

  ClickBarrageItemCallback get itemClickCallback => widget.itemClickCallback;

  ClickBarrageCallback get clickCallback => widget.clickCallback;

  double x, y;

  @override
  void initState() {
    super.initState();
    updateBarrageData();
  }

  updateBarrageData([bool isRefresh = false]) {
    barrageList.sort((a, b) => a.getBarrageShowTime() - b.getBarrageShowTime());

    ///每一行的弹幕的当前长度 list length固定为maxLine
    List<double> xLengthList = List<double>.filled(maxLine, 0);
    for (T item in barrageList) {
      int barrageTime = item.getBarrageShowTime() * 1000;
      item.width = item.getBarrageContent().length * textSize;
      if (item.width < 60) {
        item.velocity = velocity;
      } else {
        item.velocity = (item.width + 360) / 6000;
      }
      double initX = (barrageTime - startTimeInSecond) * item.velocity;
      int lineIndex;

      Map<int, double> vaildLineMap = {};

      ///遍历每一行的长度 找到最适合的line
      for (int i = 0; i < maxLine; i++) {
        if (xLengthList[i] <= initX) {
          vaildLineMap.putIfAbsent(i, () => xLengthList[i]);
          item.x = initX;
        }
      }
      if (vaildLineMap.isNotEmpty) {
        double min;
        vaildLineMap.forEach((line, length) {
          if (min == null) {
            min = length;
            lineIndex = line;
          }
          if (length < min) {
            min = length;
            lineIndex = line;
          }
        });
      }

      ///说明按照initX的位置站位的话 在所有行中（maxLine）都已经没有位置 只能偏移站位（找到最短的一行）
      if (lineIndex == null) {
        ///找到最短的一行
        lineIndex = 0;
        double min = xLengthList[0];
        item.x = min;
        for (int i = 0; i < maxLine; i++) {
          if (xLengthList[i] < min) {
            min = xLengthList[i];
            lineIndex = i;
            item.x = min;
          }
        }
      }
      item.line = lineIndex;
      item.y = lineIndex * (itemHeight + widget.verticalPadding);

      ///更新当前弹幕所在行的弹幕总长度
      xLengthList[lineIndex] = item.x +
          item.width +
          2 * innerHorizontalPadding +
          widget.horizontalPadding;
    }
    if (isRefresh) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    BarrageViewPainter barragePainter = BarrageViewPainter(
        data: barrageList,
        time: currentTimeInMs,
        width: width,
        bgHeight: itemHeight,
        backgroundColor: widget.itemBgColor,
        selfBackgroundColor: widget.selfItemBgColor,
        textColor: widget.textColor,
        selfTextColor: widget.selfTextColor,
        shadow: widget.shadow,
        innerHorizontalPadding: innerHorizontalPadding);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Container(
        child: Padding(
            padding: EdgeInsets.only(top: widget.topPadding),
            child: Align(
              child: CustomPaint(
                painter: barragePainter,
              ),
              alignment: Alignment.topRight,
            )),
        color: Colors.transparent,
      ),
      onPanDown: (details) {
        x = details.globalPosition.dx - width;
        y = details.globalPosition.dy - widget.topPadding;
      },
      onTap: () {
        bool isSelected = false;

        ///由大到小排序 对于重叠的弹幕 选中后面的
        barragePainter.dataInScreen
            ?.sort((a, b) => b.getBarrageShowTime() - a.getBarrageShowTime());
        for (T item in barragePainter.dataInScreen) {
          double startX = item.x - item.velocity * currentTimeInMs;
          double startY = item.y;

          double endX = startX + item.width + 2 * innerHorizontalPadding;
          double endY = startY + itemHeight;

          int commentId = item.getBarrageId();

          ///选中弹幕 弹幕消失 弹出弹幕操作框
          if (x >= startX &&
              x < endX &&
              y >= startY &&
              y <= endY &&
              commentId != null) {
            if (itemClickCallback != null) {
              itemClickCallback(startX, startY, item);
              isSelected = true;
            }
            break;
          }
        }

        ///说明没有选中 点击效果同播放暂停按钮效果
        if (!isSelected) {
          if (clickCallback != null) {
            clickCallback();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

///使用CustomPainter 画弹幕
class BarrageViewPainter<T extends BarrageItemBean> extends CustomPainter {
  final int time;
  final List<T> data;
  final Color textColor;
  final Color selfTextColor;
  final Color backgroundColor;
  final Color selfBackgroundColor;
  final double width;
  final double textSize;
  final List<Shadow> shadow;
  final double bgHeight;
  final double innerHorizontalPadding;
  List<T> dataInScreen = [];

  BarrageViewPainter(
      {this.time,
      this.data,
      this.textColor,
      this.selfTextColor,
      this.textSize,
      this.backgroundColor,
      this.selfBackgroundColor,
      this.shadow,
      this.innerHorizontalPadding,
      this.bgHeight,
      this.width});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    dataInScreen.clear();
    for (T item in data) {
      if (item.x == null || item.y == null) {
        break;
      }
      double offsetX = item.x - item.velocity * time;
      double itemWidth = item.width + 2 * innerHorizontalPadding;

      /// 说明该弹幕在屏幕内
      if (offsetX <= 0 && offsetX >= -(width + itemWidth)) {
        bool isSelf = item.isSelf() ?? false;
        if (isSelf != null && isSelf) {
          paint.color = selfBackgroundColor;
        } else {
          paint.color = backgroundColor ?? Colors.transparent;
        }

        Offset offset = Offset(offsetX, item.y);
        TextSpan textSpan = new TextSpan(
            text: item.getBarrageContent(),
            style: TextStyle(
                color: isSelf ? selfTextColor : textColor,
                fontSize: textSize,
                shadows: shadow));
        TextPainter textPainter = new TextPainter(
            textDirection: TextDirection.ltr, text: textSpan, maxLines: 1);
        textPainter.layout();

        ///文字真正的宽和高  item.width是根据textSize*length计算的 对于字符等偏大
        double textHeight = textPainter.height;
        double textWidth = textPainter.width;
        item.width = textWidth;
        dataInScreen.add(item);

        ///画背景图

        Rect rt = Rect.fromLTWH(offset.dx, offset.dy,
            textWidth + 2 * innerHorizontalPadding, bgHeight);
        RRect rrect =
            RRect.fromRectAndRadius(rt, Radius.circular(bgHeight / 2));
        canvas.drawRRect(rrect, paint);

        ///画文字
        double textVerticalPadding = (bgHeight - textHeight) / 2;
        Offset textOffset = Offset(
            offset.dx + innerHorizontalPadding, item.y + textVerticalPadding);
        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(BarrageViewPainter oldPainter) {
    return oldPainter.time != time;
  }
}

abstract class BarrageItemBean {
  double x;
  double y;
  double width;
  int line;
  double velocity;

  getBarrageId() {}

  getBarrageContent() {}

  getBarrageCreateTime() {}

  getBarrageShowTime() {}

  isSelf() {}

  BarrageItemBean({this.x, this.y, this.width, this.line, this.velocity});
}
