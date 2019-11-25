import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barrage/barrage.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer timer;
  int currentTimeInMs = 0;
  List<TestDataBean> dataList = List();
  GlobalKey<BarrageViewState> _barrageKey = new GlobalKey<BarrageViewState>();

  @override
  void initState() {
    super.initState();
    getData();
    timer = Timer.periodic(Duration(milliseconds: 16), (t) {
      currentTimeInMs+=16;
      setState(() {});
    });
  }

  getData() async {
    String data = await rootBundle.loadString("assets/test_data.json");
    var result = json.decode(data);

    if (result is List) {
      result.forEach((item) {
        TestDataBean bean = TestDataBean.fromJson(item);
        dataList.add(bean);
      });

      _barrageKey.currentState.updateBarrageData();
      setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
              child: BarrageView<TestDataBean>(
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
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          timer.cancel();
        },
        tooltip: 'stop',
        child: Icon(Icons.pause),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TestDataBean extends BarrageItemBean {
  int commentId;
  String content;
  String createTime;
  int danmuTime;
  bool isFake;

  factory TestDataBean.fromJson(Map<String, dynamic> json) => TestDataBean(
      commentId: json['commentId'] as int,
      content: json['content'] as String,
      createTime: json['createTime'] as String,
      danmuTime: json['danmuTime'] as int,
      isFake: json['isFake'] as bool);

  TestDataBean(
      {this.commentId,
      this.content,
      this.createTime,
      this.danmuTime,
      this.isFake});

  @override
  getBarrageContent() {
    return content;
  }

  @override
  getBarrageCreateTime() {
    return createTime;
  }

  @override
  getBarrageId() {
    return commentId;
  }

  @override
  getBarrageShowTime() {
    return danmuTime;
  }

  @override
  isSelf() {
    return isFake;
  }
}
