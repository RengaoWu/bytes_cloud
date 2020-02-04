import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Ch8Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试点击"),
      ),

// 点击文字都会相应
//      body: Listener(
//          child: ConstrainedBox(
//            constraints: BoxConstraints.tight(Size(300.0, 150.0)),
//            child: Listener(
//                child: Center(child : Text("Box A")),
//                behavior: HitTestBehavior.translucent,
//                onPointerDown: (event) => print("ch8 B")),
//          ),
//          behavior: HitTestBehavior.opaque,
//          onPointerDown: (event) => print("ch8 A")),

      body: Stack(
        children: <Widget>[
          Listener(
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(300.0, 500.0)),
              child:
                  DecoratedBox(decoration: BoxDecoration(color: Colors.blue)),
            ),
            onPointerDown: (event) => print("log down0"),
            behavior: HitTestBehavior.opaque,
          ),
          Listener(
            child: ConstrainedBox(
              constraints: BoxConstraints.tight(Size(300.0, 300.0)),
              child: Listener(
                child: Center(child: Text("左上角200*100范围内非文本区域点击")),
                onPointerDown: (event) => print("log down2"),
                behavior: HitTestBehavior.translucent,
              ),
            ),
            onPointerDown: (event) => print("log down1"),
            behavior: HitTestBehavior.deferToChild, //放开此行注释后可以"点透"
          )
        ],
      ),
    );
  }
}

// AboutListener # behavior
// return widget.child == null ? HitTestBehavior.translucent : HitTestBehavior.deferToChild;
// deferToChild 传递给子Widget
// opaque

// 手势识别
// 当同时有 onTap 和 onDoubleTap 的时候，onTap会有200ms的延时
class GestureDetectorRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return GestureDetectorRouteState();
  }
}

class GestureDetectorRouteState extends State<GestureDetectorRoute> {
  String _operation = "No Gesture";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("test"),
      ),
      body: Center(
          child: GestureDetector(
        child: Container(
          alignment: Alignment.center,
          width: 200,
          height: 200,
          color: Colors.blue,
          child: Text(_operation),
        ),
        onTap: () => updateText("TAP"),
        onDoubleTap: () => updateText("DoubleTap"),
        onLongPress: () => updateText("LongPress"),
      )),
    );
  }

  void updateText(String text) {
    setState(() {
      _operation = text;
    });
  }
}

class DragRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    //return DragRouteState();
    //return ScaleRouteState();
    return RichTextState();
  }
}

// 拖动效果
class DragRouteState extends State<DragRoute>
    with SingleTickerProviderStateMixin {
  double _top = 0;
  double _left = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
              top: _top,
              left: _left,
              child: GestureDetector(
                child: CircleAvatar(
                  child: Text("A"),
                ),
                onPanDown: (DragDownDetails e) {
                  print("TAG ${e.globalPosition}");
                },
                onPanUpdate: (DragUpdateDetails e) {
                  setState(() {
                    _left += e.delta.dx; // 将其注释就只能在竖直方向移动
                    _top += e.delta.dy;
                  });
                },
                onPanEnd: (DragEndDetails e) {
                  print("TAG " + e.velocity.toString());
                },
              ))
        ],
      ),
    );
  }
}

// 缩放效果
class ScaleRouteState extends State<DragRoute> {
  double _width = 200; //   tonguo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Image.network(
          "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1578131604578&di=78183baa2ad9596c42d4dcead1a141dc&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201601%2F28%2F20160128104952_wNhRt.thumb.700_0.jpeg",
          width: _width,
        ),
        onScaleUpdate: (ScaleUpdateDetails details) {
          setState(() {
            _width = 200 * details.scale.clamp(.8, 10);
          });
        },
      ),
    );
  }
}

// 富文本
// TextSpan 不是Widget，所以不能将其传入GestureDetector
// 如果需要对其添加点击事件，需要给他添加一个Gesture Recognizer
// Flutter Framework底层识别各种手势就是通过 Recognizer操作的
class RichTextState extends State<DragRoute> {
  TapGestureRecognizer _tapGestureRecognizer = new TapGestureRecognizer();

  bool _flag = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(TextSpan(children: [
        TextSpan(text: "Hello world"),
        TextSpan(
            text: "点我变色",
            style: TextStyle(
                fontSize: 30, color: _flag ? Colors.blue : Colors.amber),
            recognizer: _tapGestureRecognizer..onTap = () {
                setState(() {
                  _flag = !_flag;
                });
              }),
        TextSpan(text: "你好世界"),
      ])),
    );
  }
}

// 手势竞争与冲突
class BothDirectionTestRouteState extends State<DragRoute> {
  double _top = 0.0;
  double _left = 0.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: _top,
          left: _left,
          child: GestureDetector(
            child: CircleAvatar(child: Text("A")),
            //垂直方向拖动事件
            onVerticalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                _top += details.delta.dy;
              });
            },
            onHorizontalDragUpdate: (DragUpdateDetails details) {
              setState(() {
                _left += details.delta.dx;
              });
            },
          ),
        )
      ],
    );
  }
}

typedef void EventCallback(arg);

class EventBus {
  // 私有构造函数
  EventBus._init();
  // 保存单例
  static EventBus _instance = new EventBus._init();

  // 工厂构造函数
  factory EventBus() => _instance;

  // 保存事件订阅者队列，Key：事件名id，value：对应事件的订阅者队列
  var _emap = new Map<Object, List<EventCallback>>();

  // 添加订阅者
  void on(eventName, EventCallback f) {
    if (eventName == null || f == null) return;
    _emap[eventName] ??= new List<EventCallback>();
    _emap[eventName].add(f);
  }

  //移除订阅者
  void off(eventName, [EventCallback f]) {
    var list = _emap[eventName];
    if (eventName == null || list == null) return;
    if (f == null) {
      _emap[eventName] = null;
    } else {
      list.remove(f);
    }
  }

  // 触发事件、事件触发吼该事件所有的订阅者会被调用
  void emit(eventName, [arg]) {
    var list = _emap[eventName];
    if (list == null) return;
    int len = list.length - 1;
    for (var i = len; i > -1; --i) {
      list[i](arg);
    }
  }
}
