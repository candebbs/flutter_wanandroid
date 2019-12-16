import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/ui/knowledge_tree_screen.dart';
import 'package:flutter_wanandroid/ui/navigation_screen.dart';

/// 体系页面
class SystemScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return SystemScreenState();
  }
}

class SystemScreenState extends BaseWidgetState<SystemScreen>
    with TickerProviderStateMixin {
  /// tabs
  var _list = ["体系", "导航"];

  /// tabs 控制器
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    /// 设置导航栏显示或者隐藏 false 隐藏 true 显示
    setAppBarVisible(false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    showContent();
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(""));
  }

  @override
  Widget attachContentWidget(BuildContext context) {
    _tabController = new TabController(length: _list.length, vsync: this);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: 50,
            child: TabBar(
              indicatorColor: Colors.white, // 指示器颜色
              labelStyle: TextStyle(fontSize: 16), // 选中label的Style
              unselectedLabelStyle: TextStyle(fontSize: 16), // 未选中label的Style
              controller: _tabController, // TabController对象
              isScrollable: false, // 如果多个按钮的话可以滑动 false 不能滚动
              indicatorSize: TabBarIndicatorSize.tab, // // 指示器大小计算方式，TabBarIndicatorSize.label 跟文字等宽,TabBarIndicatorSize.tab 跟每个 tab 等宽
              tabs: _list.map((item) {
                return Tab(text: item);
              }).toList(),
            ),
          ),
          Expanded(
            child: TabBarView(
                controller: _tabController,
                // 知识体系页面  导航页面  tabs
                children: [KnowledgeTreeScreen(), NavigationScreen()]),   //
          )
        ],
      ),
    );
  }

  @override
  void onClickErrorWidget() {}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
