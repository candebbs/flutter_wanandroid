import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/data/model/banner_model.dart';
import 'package:flutter_wanandroid/ui/base_widget.dart';
import 'package:flutter_wanandroid/utils/route_util.dart';
import 'package:flutter_wanandroid/utils/toast_util.dart';
import 'package:flutter_wanandroid/widgets/custom_cached_image.dart';
import 'package:flutter_wanandroid/widgets/item_article_list.dart';
import 'package:flutter_wanandroid/widgets/refresh_helper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 首页
class HomeScreen extends BaseWidget {
  @override
  BaseWidgetState<BaseWidget> attachState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends BaseWidgetState<HomeScreen> {
  /// 首页轮播图数据
  List<BannerBean> _bannerList = new List();

  /// 首页文章列表数据
  List<ArticleBean> _articles = new List();

  /// listView 滑动控制器
  ScrollController _scrollController = new ScrollController();

  /// 是否显示悬浮按钮  false 不显示 true 显示
  bool _isShowFAB = false;

  /// 页码，从0开始
  int _page = 0;

  /// 下拉刷新 控制器
  RefreshController _refreshController =
      new RefreshController(initialRefresh: false);

  /// 插入到渲染树时调用，只执行一次。
  @override
  void initState() {
    super.initState();
    setAppBarVisible(false);
  }

  /// 1、在初始化initState后执行； 2、显示/关闭其它widget。 3、可执行多次；
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bannerList.add(null);

    showLoading().then((value) { // then 估计是链式调用
      getBannerList();
      getTopArticleList();
    });

    _scrollController.addListener(() {
      /// 滑动到底部，加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // getMoreArticleList();
      }
      if (_scrollController.offset < 200 && _isShowFAB) { // offset 偏移量
        setState(() {
          _isShowFAB = false;
        });
      } else if (_scrollController.offset >= 200 && !_isShowFAB) {
        setState(() {
          _isShowFAB = true;
        });
      }
    });
  }

  /// 获取轮播数据
  Future getBannerList() async {
    apiService.getBannerList((BannerModel bannerModel) {
      if (bannerModel.data.length > 0) {
        setState(() {
          _bannerList = bannerModel.data;
        });
      }
    });
  }

  /// 获取置顶文章数据 获取成功后，获取文章列表数据
  Future getTopArticleList() async {
    // 传参是两个函数
    apiService.getTopArticleList((TopArticleModel topArticleModel) {
      if (topArticleModel.errorCode == Constants.STATUS_SUCCESS) {
        topArticleModel.data.forEach((v) {
          v.top = 1;
        });
        _articles.clear();
        _articles.addAll(topArticleModel.data);
      }
      getArticleList();
    }, (DioError error) {
      showError();
    });
  }

  /// 获取文章列表数据
  Future getArticleList() async {
    _page = 0;
    apiService.getArticleList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          showContent().then((value) {
            _refreshController.refreshCompleted(resetFooterState: true);
            setState(() {
              _articles.addAll(model.data.datas);
            });
          });
        } else { // 空数据
          showEmpty();
        }
      } else {
        showError();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      showError();
    }, _page);
  }

  /// 获取更多文章列表数据 就是加载更多
  Future getMoreArticleList() async {
    _page++;
    apiService.getArticleList((ArticleModel model) {
      if (model.errorCode == Constants.STATUS_SUCCESS) {
        if (model.data.datas.length > 0) {
          _refreshController.loadComplete();
          setState(() {
            _articles.addAll(model.data.datas);
          });
        } else {
          _refreshController.loadNoData();
        }
      } else {
        _refreshController.loadFailed();
        T.show(msg: model.errorMsg);
      }
    }, (DioError error) {
      _refreshController.loadFailed();
    }, _page);
  }

  @override
  AppBar attachAppBar() {
    return AppBar(title: Text(""));
  }

  /// 暴露内容视图
  @override
  Widget attachContentWidget(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: MaterialClassicHeader(), // 系统的下拉头
        footer: RefreshFooter(), //  自定义 FooterView
        controller: _refreshController,
        onRefresh: getTopArticleList, // 下拉刷新
        onLoading: getMoreArticleList, // 加载更多
        child: ListView.builder(
          itemBuilder: itemView,
          physics: new AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          itemCount: _articles.length + 1,
        ),
      ),
      floatingActionButton: !_isShowFAB
          ? null
          : FloatingActionButton(
              heroTag: "home",
              child: Icon(Icons.arrow_upward),
              onPressed: () {
                /// 回到顶部时要执行的动画
                _scrollController.animateTo(0,
                    duration: Duration(milliseconds: 2000), curve: Curves.ease);
              },
            ),
    );
  }

  @override
  void onClickErrorWidget() {
    showLoading().then((value) {
      getBannerList();
      getTopArticleList();
    });
  }

  /// ListView 中每一行的视图
  Widget itemView(BuildContext context, int index) {
    if (index == 0) { // 第一个index是轮播图
      return Container(
        height: 200,
        color: Colors.transparent,
        child: _buildBannerWidget(),
      );
    } else {
      ArticleBean item = _articles[index - 1];
      return ItemArticleList(item: item); // 首页文章的item
    }
  }

  /// 构建轮播视图
  Widget _buildBannerWidget() {
    return Offstage( //  当offstage为true，控件隐藏； 当offstage为false，显示；注意,当offstage不可见,如果child有动画,应该手动停止动画,offstage不会停止动画;
      offstage: _bannerList.length == 0, // 等于0不显示轮播图，
      child: Swiper( // 第三方轮播图  https://github.com/best-flutter/flutter_swiper
        itemBuilder: (BuildContext context, int index) {
          if (index >= _bannerList.length || _bannerList[index] == null ||
              _bannerList[index].imagePath == null) {
            return new Container(height: 0);
          } else {
            return InkWell( // InkWell管理点击回调和水波动画。
              child: new Container(
                child:
                    CustomCachedImage(imageUrl: _bannerList[index].imagePath), /// 自定义带有缓存的Image
              ),
              onTap: () { // 点击事件
                RouteUtil.toWebView( // 打开WebView
                    context, _bannerList[index].title, _bannerList[index].url);
              },
            );
          }
        },
        itemCount: _bannerList.length,
        autoplay: true, // 自动播放开关
        pagination: new SwiperPagination(), // 设置 new SwiperPagination() 展示默认分页指示器
        // control: new SwiperControl(),
      ),
    );
  }

  //  表示组件已销毁；
  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
