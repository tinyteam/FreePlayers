import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'chewie_demo.dart';
import 'dart:ui' as ui show window;

GlobalKey<ScaffoldState> scaffoldKey;

class Home extends StatefulWidget {
  Home(GlobalKey<ScaffoldState> _scaffoldKey, {Key key}) : super(key: key) {
    scaffoldKey = _scaffoldKey;
  }

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  _HomeState() {
    super.initState();
  }
  var _isLove = false, _isFocus = false;

  @override
  Widget build(BuildContext context) {
    TabController _homeHorizontalTabcontroller = new TabController(
      length: 2,
      vsync: this,
    );
    TabController _homeTabcontroller = new TabController(
      length: 2,
      vsync: this,
    );
    double pageHeight =
        MediaQuery.of(context).size.height - kMinInteractiveDimension;
    double scrollHeight = MediaQuery.of(context).size.height;
    double scrollWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        homeView(scrollHeight, scrollWidth, _homeTabcontroller,
            _homeHorizontalTabcontroller),
        homeTabBar(pageHeight, _homeHorizontalTabcontroller),
      ],
    );
  }

  Center homeTabBar(
      double pageHeight, TabController _homeHorizontalTabcontroller) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 30),
        height: pageHeight * 0.1,
        width: 140,
        child: TabBar(
          indicatorPadding: EdgeInsets.all(16),
          indicatorColor: Colors.white,
          tabs: [
            Text(
              "推荐",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            Text(
              "关注",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
          controller: _homeHorizontalTabcontroller,
        ),
      ),
    );
  }

  Container homeView(
      double scrollHeight,
      double scrollWidth,
      TabController _homeTabcontroller,
      TabController _homeHorizontalTabcontroller) {
    return Container(
      margin: EdgeInsets.all(0),
      height: scrollHeight,
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: Stack(
          overflow: Overflow.visible,
          children: [
            TabBarView(
              children: [
                Container(
                  height: scrollHeight,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: TabBarView(
                      controller: _homeTabcontroller,
                      children: [
                        videoItem(scrollHeight, scrollWidth),
                        videoItem(scrollHeight, scrollWidth),
                      ],
                    ),
                  ),
                ),
                Text("dsf"),
              ],
              controller: _homeHorizontalTabcontroller,
            ),
          ],
        ),
      ),
    );
  }

  RotatedBox videoItem(double scrollHeight, double scrollWidth) {
    // Future<ClosedCaptionFile> _loadCaptions() async {
    //   final String fileContents =
    //       await DefaultAssetBundle.of(context).loadString('assets/zimu.srt');
    //   return SubRipCaptionFile(fileContents);
    // }

    return RotatedBox(
      quarterTurns: 1,
      child: Container(
        height: scrollHeight - 56,
        child: Stack(
          children: [
            // VideoPage(scrollWidth),
            Container(
              height: scrollHeight - 56,
              child: ChewieDemo(),
            ),
            Positioned(
              width: 60,
              bottom: 100,
              right: 8,
              child: Container(
                height: scrollHeight / 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    picAndTextButton(
                      imgpath: "assets/images/portrait_xxx.jpg",
                      text: "",
                      onPressed: () => {
                        this.setState(() {
                          _isFocus = !_isFocus;
                        })
                      },
                      isFocus: _isFocus,
                    ),
                    Column(
                      children: [
                        InkWell(
                          child: Icon(
                            Icons.favorite,
                            size: 34,
                            color: () {
                              print("eeeeeeeeeeeeeeeeeeeee${_isLove}");
                              return _isLove ? Colors.red : Colors.white;
                            }(),
                          ),
                          onTap: () => {
                            this.setState(() {
                              _isLove = !_isLove;
                              print("isLove:${_isLove}");
                            })
                          },
                        ),
                        Text(
                          "100M",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.battery_charging_full,
                      color: Colors.white,
                      size: 34,
                    ),
                    Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 34,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Map getData() {
//   MediaQueryData mediaQuery = MediaQueryData.fromWindow(ui.window);
//   var screenUtil = ScreenUtil.getInstance();
//   var pageHeight = screenUtil.screenHeight - kMinInteractiveDimension,
//       screenWidth = screenUtil.screenWidth,
//       scrollHeight = screenUtil.screenHeight;
//   print("屏幕高度:${screenUtil.screenHeight}");
//   print("底部工具栏高度:${kBottomNavigationBarHeight}");
//   print("page高度:${pageHeight}");
//   print("tabBar高度:${pageHeight * 0.1}");
//   print("tabView高度:${pageHeight * 0.9}");
//   print("系统状态栏高度:${screenUtil.statusBarHeight}");
//   print("获取屏幕密度:${screenUtil.screenDensity}");
//   print("获取系统AppBar高度:${screenUtil.appBarHeight}");
//   print("获取屏幕密度:${screenUtil.screenDensity}");
//   print("屏幕宽度:${screenWidth}");
//   print("json:${mediaQuery.padding}");
//   print("json:${kTabLabelPadding.left}");
//   return {
//     "screenWidth": screenWidth,
//     "pageHeight": pageHeight,
//     "scrollHeight": scrollHeight,
//   };
// }

Widget picAndTextButton(
    {String imgpath, String text, Function onPressed, isFocus}) {
  return Column(
    children: [
      Container(
        height: 75,
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(30)),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              image:
                  DecorationImage(image: AssetImage(imgpath), fit: BoxFit.fill),
            ),
            child: Stack(
              overflow: Overflow.visible,
              children: [
                Positioned(
                  width: 24,
                  height: 24,
                  bottom: -10,
                  left: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: isFocus
                          ? Icon(
                              Icons.check,
                            )
                          : Icon(
                              Icons.add,
                            ),
                    ),
                  ),
                ),
                FlatButton(
                  onPressed: onPressed,
                  child: Text(text),
                  color: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
      ),
      Text(
        "100M",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      )
    ],
  );
}

var _timer;
bool _handleScrollNotification(Notification notification) {
  switch (notification.runtimeType) {
    case OverscrollNotification:
      () {
        if (notification.toString().indexOf("Offset(-") > 0) {
          scaffoldKey.currentState.openEndDrawer();
        }
      }();
      break;
  }
}
