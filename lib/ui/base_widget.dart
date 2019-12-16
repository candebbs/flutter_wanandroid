import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 封装一个通用的Widget
/// 这个 widget 作用这个应用的顶层 widget.
/// 这个 widget 是无状态的，所以我们继承的是 [StatelessWidget].
/// 对应的，有状态的 widget 可以继承 [StatefulWidget]
abstract class BaseWidget extends StatefulWidget {

  BaseWidgetState baseWidgetState;

  @override
  State<StatefulWidget> createState() {
    baseWidgetState = attachState();
    return baseWidgetState;
  }

  BaseWidgetState attachState();
}

abstract class BaseWidgetState<T extends BaseWidget> extends State<T>
    with AutomaticKeepAliveClientMixin { // AutomaticKeepAliveClientMixin 作用：切换tab后保留tab的状态，避免initState方法重复调用
  /// 导航栏是否显示
  bool _isAppBarShow = true;

  /// 错误信息是否显示 true 显示  false 隐藏
  bool _isErrorWidgetShow = false;
  /// 网络提示出错信息
  String _errorContentMsg = "网络请求失败，请检查您的网络";
  /// 网络提示出错图片
  String _errorImgPath = "assets/images/ic_error.png";

  /// 加载中信息是否显示 true 显示  false 隐藏
  bool _isLoadingWidgetShow = false;

  /// 无数据信息是否显示 true 显示  false 隐藏
  bool _isEmptyWidgetShow = false;

  /// 无数据提示
  String _emptyContentMsg = "暂无数据";
  /// 无数据提示图片
  String _emptyImgPath = "assets/images/ic_empty.png";

  /// 显示内容 true 显示  false 隐藏
  bool _isShowContent = false;

  /// 错误页面和空页面的字体粗度
  FontWeight _fontWidget = FontWeight.w600;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: _attachBaseAppBar(),
      body: Container(
        child: Stack(
          children: <Widget>[
            _attachBaseContentWidget(context), // 内容页面
            _attachBaseErrorWidget(), // 错误页面
            _attachBaseLoadingWidget(), // 正在加载页面
            _attachBaseEmptyWidget() // 数据为空的页面
          ],
        ),
      ),
      floatingActionButton: fabWidget(), // 悬浮按钮
    );
  }

  /// 悬浮按钮
  Widget fabWidget() {
    return null;
  }

  /// 导航栏  AppBar
  AppBar attachAppBar();

  /// 暴露内容视图
  Widget attachContentWidget(BuildContext context);

  /// 点击错误页面后展示内容
  void onClickErrorWidget();

  /// 导航栏 AppBar
  PreferredSizeWidget _attachBaseAppBar() {
    return PreferredSize(
      child: Offstage(
        offstage: !_isAppBarShow,
        child: attachAppBar(),
      ),
      preferredSize: Size.fromHeight(56),
    );
  }

  /// 内容页面
  Widget _attachBaseContentWidget(BuildContext context) {
    return Offstage( // 控制child是否显示
      offstage: !_isShowContent, // 当offstage为true，控件隐藏； 当offstage为false，显示；注意,当offstage不可见,如果child有动画,应该手动停止动画,offstage不会停止动画;
      child: attachContentWidget(context),
    );
  }

  /// 错误页面
  Widget _attachBaseErrorWidget() {
    return Offstage(
      offstage: !_isErrorWidgetShow,
      child: attachErrorWidget(),
    );
  }

  /// 暴露的错误页面方法，可以自己重写定制
  Widget attachErrorWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
              image: AssetImage(_errorImgPath),
              width: 120,
              height: 120,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Text(
                _errorContentMsg,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: _fontWidget,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: OutlineButton(
                child: Text("重新加载",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: _fontWidget,
                    )),
                onPressed: () => {onClickErrorWidget()},
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 正在加载页面
  Widget _attachBaseLoadingWidget() {
    return Offstage(
      offstage: !_isLoadingWidgetShow,
      child: attachLoadingWidget(),
    );
  }

  /// 暴露的正在加载页面方法，可以自己重写定制
  Widget attachLoadingWidget() {
    return Center(
      /**
       * strokeWidth:用于绘制圆的线条的宽度。
          backgroundColor:背景颜色。
          value:如果为非null，则该进度指示器的值为0.0，对应于没有进度，1.0对应于所有进度。
          valueColor：动画的颜色值。
       */
      child: CircularProgressIndicator( // CircularProgressIndicator
        strokeWidth: 2.0,
      ),
    );
  }

  /// 数据为空的页面
  Widget _attachBaseEmptyWidget() {
    return Offstage(
      offstage: !_isEmptyWidgetShow,
      child: attachEmptyWidget(),
    );
  }

  /// 暴露的数据为空页面方法，可以自己重写定制
  Widget attachEmptyWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                color: Colors.black12,
                image: AssetImage(_emptyImgPath),
                width: 150,
                height: 150,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(_emptyContentMsg,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: _fontWidget,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// 设置错误提示信息
  Future setErrorContent(String content) async {
    if (content != null) {
      setState(() {
        _errorContentMsg = content;
      });
    }
  }

  /// 设置空页面信息
  Future setEmptyContent(String content) async {
    if (content != null) {
      setState(() {
        _emptyContentMsg = content;
      });
    }
  }

  /// 设置错误页面图片
  Future setErrorImg(String imgPath) async {
    if (imgPath != null) {
      setState(() {
        _errorImgPath = imgPath;
      });
    }
  }

  /// 设置空页面图片
  Future setEmptyImg(String imgPath) async {
    if (imgPath != null) {
      setState(() {
        _emptyImgPath = imgPath;
      });
    }
  }

  /// 设置导航栏显示或者隐藏 false 隐藏 true 显示
  Future setAppBarVisible(bool visible) async {
    setState(() {
      _isAppBarShow = visible;
    });
  }

  /// 显示展示的内容
  Future showContent() async {
    setState(() {
      _isShowContent = true;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示正在加载
  Future showLoading() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = true;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示空数据页面
  Future showEmpty() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = true;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = false;
    });
  }

  /// 显示错误页面
  Future showError() async {
    setState(() {
      _isShowContent = false;
      _isEmptyWidgetShow = false;
      _isLoadingWidgetShow = false;
      _isErrorWidgetShow = true;
    });
  }
}
