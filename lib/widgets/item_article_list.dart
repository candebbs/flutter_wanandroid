import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wanandroid/common/common.dart';
import 'package:flutter_wanandroid/common/user.dart';
import 'package:flutter_wanandroid/data/api/apis_service.dart';
import 'package:flutter_wanandroid/data/model/article_model.dart';
import 'package:flutter_wanandroid/data/model/base_model.dart';
import 'package:flutter_wanandroid/utils/index.dart';
import 'package:flutter_wanandroid/widgets/custom_cached_image.dart';
import 'package:flutter_wanandroid/widgets/like_button_widget.dart';

/// 首页文章的item
class ItemArticleList extends StatefulWidget {
  ArticleBean item;

  ItemArticleList({this.item});

  @override
  State<StatefulWidget> createState() {
    return new ItemArticleListState();
  }
}

class ItemArticleListState extends State<ItemArticleList> {
  @override
  Widget build(BuildContext context) {
    var item = widget.item;
    return InkWell( // InkWell管理点击回调和水波动画。
      onTap: () { // 点击事件，跳到WebView
        RouteUtil.toWebView(context, item.title, item.link);
      },
      child: Column( //  Column 是一个可以沿垂直方向展示它的子组件的组件。
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row( //  Column 是一个可以沿水平方向展示它的子组件的组件。
              children: <Widget>[
                Offstage(
                  offstage: item.top == 0,
                  child: Container( /// 置顶
                    decoration: new BoxDecoration( // 背景
                      border:
                          new Border.all(color: Color(0xFFF44336), width: 0.5), // 边框
                      borderRadius: new BorderRadius.vertical(  ///创建垂直对称的边框半径，其中顶部和底部矩形的边具有相同的半径。
                          top: Radius.elliptical(2, 2),
                          bottom: Radius.elliptical(2, 2)),
                    ),
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                    margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: Text(
                      "置顶",
                      style: TextStyle(
                          fontSize: 10, color: const Color(0xFFF44336)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Offstage(
                  offstage: !item.fresh, // 是否新文章
                  child: Container(
                    decoration: new BoxDecoration(
                      border:
                          new Border.all(color: Color(0xFFF44336), width: 0.5),
                      borderRadius: new BorderRadius.vertical(
                          top: Radius.elliptical(2, 2),
                          bottom: Radius.elliptical(2, 2)),
                    ),
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                    margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: Text(
                      "新",
                      style: TextStyle(
                          fontSize: 10, color: const Color(0xFFF44336)),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Offstage( // 标记
                  offstage: item.tags.length == 0,
                  child: Container(
                    decoration: new BoxDecoration(
                      border: new Border.all(color: Colors.cyan, width: 0.5),
                      borderRadius: new BorderRadius.vertical(
                          top: Radius.elliptical(2, 2),
                          bottom: Radius.elliptical(2, 2)),
                    ),
                    padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                    margin: EdgeInsets.fromLTRB(0, 0, 4, 0),
                    child: Text(
                      item.tags.length > 0 ? item.tags[0].name : "",
                      style: TextStyle(fontSize: 10, color: Colors.cyan),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Text( // 作者或者分享用户
                  item.author.isNotEmpty ? item.author : item.shareUser,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.left,
                ),
                Expanded(
                  child: Text( // 日期
                    item.niceDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Offstage( // 显示封面图
                  offstage: item.envelopePic == "",
                  child: Container(
                      width: 100,
                      height: 80,
                      padding: EdgeInsets.fromLTRB(16, 8, 0, 8),
                      child: CustomCachedImage(imageUrl: item.envelopePic)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container( // 标题
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Text(
                          item.title,
                          maxLines: 2,
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text( // 大约是分类吧
                                item.superChapterName +
                                    " / " +
                                    item.chapterName,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            LikeButtonWidget( /// 点赞组件
                              isLike: item.collect,
                              onClick: () {
                                addOrCancelCollect(item); // 添加收藏或者取消收藏
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1) // 分割线
        ],
      ),
    );
  }

  /// 添加收藏或者取消收藏
  void addOrCancelCollect(item) {
    List<String> cookies = User.singleton.cookie;
    if (cookies == null || cookies.length == 0) {
      T.show(msg: '请先登录~');
    } else {
      if (item.collect) { //  取消收藏
        apiService.cancelCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '已取消收藏~');
            setState(() {
              item.collect = false;
            });
          } else {
            T.show(msg: '取消收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      } else { // 取消收藏
        apiService.addCollection((BaseModel model) {
          if (model.errorCode == Constants.STATUS_SUCCESS) {
            T.show(msg: '取消收藏~');
            setState(() {
              item.collect = true;
            });
          } else {
            T.show(msg: '收藏失败~');
          }
        }, (DioError error) {
          print(error.response);
        }, item.id);
      }
    }
  }
}
