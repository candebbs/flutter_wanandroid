import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/ui/drawer_screen.dart';
import 'package:flutter_wanandroid/ui/home_screen.dart';
import 'package:flutter_wanandroid/ui/hot_word_screen.dart';
import 'package:flutter_wanandroid/ui/project_screen.dart';
import 'package:flutter_wanandroid/ui/share_article_screen.dart';
import 'package:flutter_wanandroid/ui/square_screen.dart';
import 'package:flutter_wanandroid/ui/system_screen.dart';
import 'package:flutter_wanandroid/ui/wechat_screen.dart';
import 'package:flutter_wanandroid/utils/index.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';

/// 首页
class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MainScreenState();
  }
}

class MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin { // AutomaticKeepAliveClientMixin 作用：切换tab后保留tab的状态，避免initState方法重复调用

  /// 控制台。用于监听视图的滚动情况。页面视图应该如何响应用户输入。例如，确定用户停止拖动页视图后，页视图如何继续动画。
  PageController _pageController = PageController();

  /// 当前选中的索引
  int _selectedIndex = 0; // 当前选中的索引

  /// tabs的名字
  final bottomBarTitles = ["首页", "广场", "公众号", "体系", "项目"];

  /// 五个Tabs的内容
  var pages = <Widget>[
    HomeScreen(),
    SquareScreen(),
    WeChatScreen(),
    SystemScreen(),
    ProjectScreen(),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope( // 双击返回与界面退出提示
      onWillPop: _onWillPop, // onWillPop 就表示当前页面将退出
      child: Scaffold(
        drawer: DrawerScreen(), // 侧滑页面
        appBar: AppBar(
          title: new Text(bottomBarTitles[_selectedIndex]), // 标题
          bottom: null,
          elevation: 0,  // 阴影的范围，值越大阴影范围越大
          actions: <Widget>[ // 标题栏右上角+和搜索
            IconButton(
              icon: _selectedIndex == 1 ? Icon(Icons.add) : Icon(Icons.search),
              onPressed: () {
                if (_selectedIndex == 1) {
                  RouteUtil.push(context, ShareArticleScreen()); // 跳到分享
                } else {
                  RouteUtil.push(context, HotWordScreen()); // 跳到搜索
                }
              },
            )
          ],
        ),
        body: PageView.builder(
          itemBuilder: (context, index) => pages[index],
          itemCount: pages.length,
          controller: _pageController, // 滑动监听
          /**
           * 设置 ListView 如何响应用户的滑动行为，值为一个 ScrollPhysics 对象，它的实现类常用的有：
                  AlwaysScrollableScrollPhysics：总是可以滑动。
                  NeverScrollableScrollPhysics：禁止滚动。
                  BouncingScrollPhysics：内容超过一屏，上拉有回弹效果。
                  ClampingScrollPhysics：包裹内容，不会有回弹，感觉跟 AlwaysScrollableScrollPhysics 差不多。
           */
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavigationBar( // 显示在页面底部的导航栏。
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: buildImage(0, "ic_home"), //Icon(Icons.home),
              title: Text(bottomBarTitles[0]),
            ),
            BottomNavigationBarItem(
              icon: buildImage(1, "ic_square_line"), //Icon(Icons.assignment),
              title: Text(bottomBarTitles[1]),
            ),
            BottomNavigationBarItem(
              icon: buildImage(2, "ic_wechat"), //Icon(Icons.chat),
              title: Text(bottomBarTitles[2]),
            ),
            BottomNavigationBarItem(
              icon: buildImage(3, "ic_system"), //Icon(Icons.assignment),
              title: Text(bottomBarTitles[3]),
            ),
            BottomNavigationBarItem(
              icon: buildImage(4, "ic_project"), //Icon(Icons.book),
              title: Text(bottomBarTitles[4]),
            ),
          ],
          type: BottomNavigationBarType.fixed, // 设置显示模式  >=4个选项时需要强制设置为BottomNavigationBarType.fixed
          currentIndex: _selectedIndex, // 当前选中项的索引
          onTap: _onItemTapped, // 选择的处理事件 选中变化回调函数
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index); // //点击事件  在点击到指定的图标  改变currentindex
  }

  /// tabs 底总的图片
  Widget buildImage(index, iconPath) {
    return Image.asset(
      Utils.getImgPath(iconPath),
      width: 22,
      height: 22,
      color: _selectedIndex == index
          ? Theme.of(context).primaryColor
          : Colors.grey[600],
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('提示'),
            content: new Text('确定退出应用吗？'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('再看一会', style: TextStyle(color: Colors.cyan)),
              ),
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: new Text('退出', style: TextStyle(color: Colors.cyan)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
