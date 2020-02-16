import 'package:flutter/material.dart';

/**
 *
 */
class ScrollHomeView extends StatefulWidget {
  @override
  _ScrollHomeViewState createState() => _ScrollHomeViewState();
}

class _ScrollHomeViewState extends State<ScrollHomeView> {
  List<String> tabs = ["红色", "橙色", "黄色", "蓝色", "紫色"];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    title: Text(
                      'NestedScrollView & ListView',
                      style: TextStyle(color: Colors.deepOrange),
                    ),
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: Image.network(
                        'https://cdn.duitang.com/uploads/item/201408/11/20140811200850_LUY5c.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    expandedHeight: 200,
                    forceElevated: innerBoxIsScrolled,
                    floating: true,
                    bottom: new TabBar(
                        indicatorColor: Colors.deepOrange,
                        labelColor: Colors.deepOrange,
                        tabs: tabs
                            .map((String name) => new Tab(
                                  text: name,
                                ))
                            .toList()),
                  )
                ];
              },
              body: new TabBarView(
                children: tabs.map((String name) {
                  return new ContentPage(name);
                }).toList(),
              )),
        ));
  }
}

class ContentPage extends StatefulWidget {
  String content;

  ContentPage(this.content);

  @override
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List<String> datas = new List();

  int itemCount = 10;

  Widget divider1 = Divider(
    color: Colors.blue,
  );
  Widget divider2 = Divider(color: Colors.red);

  @override
  void initState() {
    super.initState();
    _onRefresh();
  }

  _onScrollNotification(ScrollNotification scrollInfo) {
    print("pixels=>" + scrollInfo.metrics.pixels.toString());
    print("minScrollExtent=>" + scrollInfo.metrics.minScrollExtent.toString());
    print("maxScrollExtent=>" + scrollInfo.metrics.maxScrollExtent.toString());

    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      //滑到了底部
      _onLoadMore();
    }
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
    datas.clear();
    for (int i = 0; i < itemCount; i++) {
      datas.add(this.widget.content + i.toString());
    }
    setState(() {});
    return null;
  }

  void _onLoadMore() {
    for (int i = 0; i < itemCount; i++) {
      datas.add(this.widget.content + i.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return datas.length == 0
        ? Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.deepOrange,
              strokeWidth: 2,
            ),
          )
        : Center(
            child: NotificationListener<ScrollNotification>(
              child: new RefreshIndicator(
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return _itemView(context, index);
                    },
                    itemCount: datas.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return index % 2 == 0 ? divider1 : divider2;
                    },
                  ),
                  onRefresh: _onRefresh),
              onNotification: (ScrollNotification scrollInfo) =>
                  _onScrollNotification(scrollInfo),
            ),
          );
  }

  Widget _itemView(BuildContext context, int index) {
    return Container(
      alignment: Alignment.center,
      height: 80,
      child: Text(datas[index]),
    );
  }
}
