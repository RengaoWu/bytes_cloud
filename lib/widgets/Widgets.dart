import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseListItem extends StatefulWidget {
  final String title;
  final String subTitle;
  final String hiddenMsg;
  final Function click;
  final Function hiddenCall;

  BaseListItem(
      {this.title,
      this.subTitle,
      this.hiddenMsg,
      this.click(),
      this.hiddenCall()});
  @override
  State<StatefulWidget> createState() {
    return BaseListItemState(
        title: title,
        subTitle: subTitle,
        hiddenMsg: hiddenMsg,
        click: click,
        hiddenCall: hiddenCall);
  }
}

class BaseListItemState extends State<BaseListItem> {
  String title;
  String subTitle;
  Function click;
  Function hiddenCall;
  String hiddenMsg;
  bool isHidden = true;

  BaseListItemState(
      {this.title = "",
      this.subTitle = "",
      this.hiddenMsg = "",
      this.click,
      this.hiddenCall}) {
    print('BaseListItemState create');
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initData();
    print("$title + " " + $isHidden");
    print('didChangeDependencies');
  }

  // 先调用 didChangeDependencies 再调用 build，调用
  initData() {
    BaseHolder holder = ShareDataWidget.of(context).data;
    print('initData ${holder == null}');
    if (holder == null) return;
    title = holder.title;
    subTitle = holder.subTitle;
  }

  @override
  Widget build(BuildContext context) {
    print('BaseListItemState build');
    return Padding(
        padding: EdgeInsets.all(8),
        child: InkWell(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(fontSize: 18),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: Text(subTitle),
                        )
                      ],
                    )),
                isHidden
                    ? Container()
                    : RaisedButton(
                        color: Colors.grey,
                        textColor: Colors.white,
                        child: Text(hiddenMsg),
                        onPressed: () {
                          hiddenCall();
                          setState(() {});
                        },
                      ),
              ]),
          onTap: () {
            if (isHidden)
              click();
            else
              setStateHiddenBtn();
          },
          onLongPress: () {
            setStateHiddenBtn();
          },
        ));
  }

  setStateHiddenBtn() {
    setState(() {
      isHidden = !isHidden;
    });
  }
}

class BaseHolder {
  String title;
  String subTitle;
  BaseHolder(this.title, this.subTitle);
}

class ShareDataWidget extends InheritedWidget {
  ShareDataWidget({@required this.data, Widget child}) : super(child: child);

  final BaseHolder data; //需要在子树中共享的数据，保存点击次数

  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType(aspect: ShareDataWidget);
  }

  //该回调决定当data发生变化时，是否通知子树中依赖data的Widget
  @override
  bool updateShouldNotify(ShareDataWidget old) {
    //如果返回true，则子树中依赖(build函数中有调用)本widget
    //的子widget的`state.didChangeDependencies`会被调用
    print('updateShouldNotify');
    return old.data.title != data.title || old.data.subTitle != data.subTitle;
  }
}
