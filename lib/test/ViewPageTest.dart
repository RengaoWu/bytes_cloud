import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BgWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BgWidget();
  }
}

class _BgWidget extends State<BgWidget> {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0, keepPage: true);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PageView'),
      ),
      body: _createBody(),
    );
  }

  _createBody() {
    return Column(
      children: <Widget>[
        _createTab(),
        Expanded(
            child: PageView(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
          onPageChanged: (page) {
            print('page = $page');
          },
          children: <Widget>[PageListView(), PageListView(), PageListView()],
        ))
      ],
    );
  }

  ///类似tab
  _createTab() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            onPressed: () {
              setState(() {
                pageController.jumpToPage(0);
              });
            },
            child: Text('第一页'),
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {
              setState(() {
                pageController.jumpToPage(1);
              });
            },
            child: Text('第二页'),
          ),
        ),
        Expanded(
          child: RaisedButton(
            onPressed: () {
              setState(() {
                pageController.jumpToPage(2);
              });
            },
            child: Text('第三页'),
          ),
        ),
      ],
    );
  }
}

///PageView子widget
class PageListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PageListView();
  }
}

class _PageListView extends State<PageListView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
        padding: EdgeInsets.only(bottom: 10),
        itemCount: 100,
        itemExtent: 40,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            color: Colors.black12,
            child: Text(' 这是第 $index 行'),
          );
        });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
