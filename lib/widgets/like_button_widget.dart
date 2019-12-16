import 'package:flutter/material.dart';

/// 点赞组件
class LikeButtonWidget extends StatefulWidget {
  bool isLike = false;
  Function onClick;

  LikeButtonWidget({Key key, this.isLike, this.onClick}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new LikeButtonWidgetState();
  }
}

class LikeButtonWidgetState extends State<LikeButtonWidget>
    with TickerProviderStateMixin {
  /// AnimationController管理Animation。
  AnimationController controller;
  // 动画
  Animation animation;
  double size = 24.0;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    animation = Tween(begin: size, end: size * 0.5).animate(controller); // 补间(Tween)动画  图片由大缩小到一半
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: LikeAnimation(
        controller: controller,
        animation: animation,
        isLike: widget.isLike,
        onClick: widget.onClick,
      ),
    );
  }
}

class LikeAnimation extends AnimatedWidget implements StatefulWidget {
  AnimationController controller;
  Animation animation;
  Function onClick;
  /// true 点赞了  false 没有点赞
  bool isLike = false;

  LikeAnimation({this.controller, this.animation, this.isLike, this.onClick})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        isLike ? Icons.favorite : Icons.favorite_border,
        size: animation.value,
        color: isLike ? Colors.red : Colors.grey[600],
      ),
      onTapDown: (dragDownDetails) { // 按下，每次和屏幕交互都会调用
        controller.forward(); // forward()方法可以启动动画。
      },
      onTapUp: (dragDownDetails) { //抬起，停止触摸时调用
        Future.delayed(Duration(milliseconds: 100), () {
          controller.reverse(); // 动画反向执行
          onClick();
        });
      },
    );
  }
}
