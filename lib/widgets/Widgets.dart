import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseListItem extends StatefulWidget {
  final String title;
  final String subTitle;
  final String hiddenBtnMsg;
  final Function click;
  final Function longPress;

  BaseListItem(
      {this.title,
      this.subTitle,
      this.hiddenBtnMsg,
      this.click(),
      this.longPress()});
  @override
  State<StatefulWidget> createState() {
    return BaseListItemState(
        title: title,
        subTitle: subTitle,
        hiddenBtnMsg: hiddenBtnMsg,
        click: click,
        longPress: longPress);
  }
}

class BaseListItemState extends State<BaseListItem> {
  String title;
  String subTitle;
  Function click;
  Function longPress;
  String hiddenBtnMsg;
  bool hiddenBtn = true;

  BaseListItemState(
      {this.title = "",
      this.subTitle = "",
      this.hiddenBtnMsg,
      this.click,
      this.longPress});

  @override
  Widget build(BuildContext context) {
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
                hiddenBtn
                    ? Container()
                    : RaisedButton(
                        color: Colors.grey,
                        textColor: Colors.white,
                        child: Text(hiddenBtnMsg),
                        onPressed: longPress,
                      ),
              ]),
          onTap: () {
            if (hiddenBtn)
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
      hiddenBtn = !hiddenBtn;
    });
  }
}
