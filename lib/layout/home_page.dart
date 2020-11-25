import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:free_players/user/user_info.dart';

import '../home/chewie_demo.dart';
import '../home/home.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  double scrollHeight = getData()["scrollHeight"];
  double screenWidth = getData()["screenWidth"];
  var testAnimation = Container();
  @override
  Widget build(BuildContext context) {
    final tabs = [1, 2, 3, 4, 5];

    TabController _homeTabController =
        new TabController(length: tabs.length, vsync: this);

    TabController _tabcontroller = new TabController(length: 3, vsync: this);
    return Scaffold(
      key: _scaffoldKey,

      endDrawer: Container(
        color: Colors.blue,
        height: scrollHeight,
        width: screenWidth,
        child: Text("drawer"),
      ),
      backgroundColor: Colors.blue,
      // appBar: AppBar(
      //   title: Text("appbar"),
      // ),

      body: appLayout(_tabcontroller),
    );
  }

  Container appLayout(TabController _tabcontroller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        overflow: Overflow.visible,
        children: [
          TabBarView(
            controller: _tabcontroller,
            children: [
              Column(
                children: [
                  Container(
                    child: Home(_scaffoldKey),
                  ),
                ],
              ),
              Text("消息"),
              UserInfo(),
            ],
          ),
          Positioned(
            bottom: 0,
            width: screenWidth,
            height: 48,
            child: TabBar(
                indicator: BoxDecoration(),
                labelStyle: TextStyle(fontSize: 16),
                controller: _tabcontroller,
                tabs: [
                  Tab(
                    text: "首页",
                  ),
                  Tab(
                    text: "消息",
                  ),
                  Tab(
                    text: "我",
                  ),
                ]),
          ),
          //   Positioned(
          //     bottom: 0,
          //     child: AnimatedSwitcher(
          //       transitionBuilder: (child, animation) {
          //         return SizeTransition(
          //           sizeFactor: animation,
          //           child: child,
          //         );
          //       },
          //       duration: const Duration(milliseconds: 500),
          //       child: testAnimation,
          //     ),
          //   ),
          //   FlatButton(
          //     onPressed: () => {
          //       this.setState(() {
          //         testAnimation = Container(
          //           key: ValueKey("2"),
          //           width: MediaQuery.of(context).size.width,
          //           height: 100,
          //           decoration: BoxDecoration(
          //             borderRadius: BorderRadius.only(
          //               topLeft: Radius.circular(10),
          //               topRight: Radius.circular(10),
          //             ),
          //             color: Colors.blue,
          //           ),
          //           child: Column(
          //             children: [Container()],
          //           ),
          //         );
          //       }),
          //     },
          //     child: Text("test"),
          //   )
          //
        ],
      ),
    );
  }
}
