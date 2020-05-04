import 'dart:io';
import 'dart:ui';

import 'package:bytes_cloud/core/Constants.dart';
import 'package:bytes_cloud/core/manager/CacheManager.dart';
import 'package:bytes_cloud/pages/selectors/CloudFolderSelector.dart';
import 'package:bytes_cloud/pages/widgets/CheckWidget.dart';
import 'package:bytes_cloud/utils/IoslateMethods.dart';
import 'package:bytes_cloud/core/Config.dart';
import 'package:bytes_cloud/utils/ThumbUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class TypeFileSelectorPage extends StatefulWidget {
  final String argType;
  TypeFileSelectorPage(this.argType);
  @override
  State<StatefulWidget> createState() {
    return TypeFileSelectorPageState(argType);
  }
}

class TypeFileSelectorPageState extends State<TypeFileSelectorPage> {
  String argType; // 当前展示的文件类型 ： 文档、视频、音频、压缩包
  List<String> selectedFiles = []; // 被选择的文件
  int filesSize = 0; // 被选择文件的大小
  Map<String, Widget> type2Icon = {};
  Map<String, String> extensionName2Type = {};
  // type2Files 是否初始化完成
  bool isReady = false;
  // 展示的数据
  Map<String, List<FileSystemEntity>> type2Files = {};
  String currentType = Constants.TYPE_ALL; // 默认将该类型所有文件都展示出来

  TypeFileSelectorPageState(this.argType);

  initData() {
    Config.convert(argType, type2Icon, extensionName2Type);
    type2Icon.keys.forEach((key) {
      type2Files[key] = []; // 初始化数据
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: NestedScrollView(
      body: isReady
          ? fileList(type2Files[currentType])
          : loadFilesFuture(), // 根据当前的currentType返回List
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            leading: InkWell(
              child: Icon(Icons.arrow_left),
              onTap: () => Navigator.pop(context),
            ),
            title: Text('$currentType'),
            pinned: false, //
            expandedHeight: Config.showType(argType)
                ? UI.kToolbarHeight + 32
                : UI.kToolbarHeight, // 向下滑动是否保留 bottom
            forceElevated: innerBoxIsScrolled,
            centerTitle: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                  padding: EdgeInsets.only(top: UI.kToolbarHeight + 8),
                  child: fileTypeGridView()),
            ),
            actions: <Widget>[
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: Icon(Icons.file_upload),
                    onPressed: () {
                      UI.newPage(context, CloudFolderSelector(selectedFiles));
//                      UI.pushToCloud(context, selectedFiles.length, filesSize);
                    },
                  );
                },
              ),
            ],
          )
        ];
      },
    ));
  }

  loadFilesFuture() {
    return FutureBuilder(
      future: getAllFile(Config.getPaths(argType)),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return handleLoadFiles(snapshot.data);
        }
      },
    );
  }

  // 查询数据并缓存
  Future<List<FileSystemEntity>> getAllFile(List<String> paths) async {
    List<FileSystemEntity> res = [];
    // 缓存中有
    if (cache[argType] != null) {
      cache[argType].forEach((f) {
        if (f.existsSync()) {
          res.add(f);
        }
      });
      return res;
    }
    res = await computeGetAllFiles(
        roots: paths, keys: extensionName2Type.keys.toList(), isExt: true);
    cache[argType] = res;

    return res;
  }

  handleLoadFiles(List<FileSystemEntity> list) {
    sortFiles(list); // 按照时间排序
    mapTypeFiles(list); // 按照文件类型分组
    isReady = true; // 数据加载完成
    return fileList(list); // 展示UI
  }

  // 时间降序排列
  sortFiles(List<FileSystemEntity> list) => list
      .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  // map操作
  mapTypeFiles(List<FileSystemEntity> list) {
    type2Files[currentType].addAll(list); // 添加到数据源中
    list.forEach((file) {
      String extension = file.path.substring(file.path.lastIndexOf('.'));
      if (extension != null && extensionName2Type.keys.contains(extension)) {
        type2Files[extensionName2Type[extension]]
            .add(file); // 查询的数据map到 type2Files类型中
      }
    });
  }

  // 展示UI
  Widget fileList(List<FileSystemEntity> list) {
    return Scrollbar(child: showSelectorList(list));
  }

  Widget showSelectorList(List<FileSystemEntity> list) {
    List<_ViewHolder> holders = insertGroupItem(list); // 插入分组的数据
    return MediaQuery.removePadding(
      removeTop: true,
      child: argType == Config.ARG_VIDEO
          ? mediaGridView(holders)
          : generalListView(holders),
      context: context,
    );
  }

  Widget generalListView(List<_ViewHolder> list) {
    return ListView.builder(
        //physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return generalListViewItem(context, list[index]);
        });
  }

  Widget generalListViewItem(BuildContext context, _ViewHolder holder) {
    if (holder.type == _ViewHolder.GROUP) {
      return groupItemCard(holder);
    }
    File file = holder.entity;
    return UI.buildFileItem(
        file: file,
        isCheck: selectedFiles.contains(file.path),
        onChanged: onChange,
        onTap: onTap);
  }

  // 按照日期进行分组
  List<_ViewHolder> insertGroupItem(List<FileSystemEntity> list) {
    // generate group
    List<_ViewHolder> holders = [];
    for (int i = 0; i < list.length; i++) {
      FileSystemEntity entity = list[i];
      var dataTime = entity.statSync().modified;
      if (i == 0) {
        holders.add(_ViewHolder(entity, dataTime, 1)); // group
        holders.add(_ViewHolder(entity, dataTime, 0)); //child
        continue;
      }
      var lastDataTime = list[i - 1].statSync().modified;
      if (dataTime.month == lastDataTime.month &&
          dataTime.year == lastDataTime.year) {
        holders.add(_ViewHolder(entity, dataTime, 0));
      } else {
        holders.add(_ViewHolder(entity, dataTime, 1)); // group
        holders.add(_ViewHolder(entity, dataTime, 0)); //child
      }
    }
    return holders;
  }

  // image or video use this item
  Widget mediaGridView(List<_ViewHolder> holders) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: holders.length,
      itemBuilder: (BuildContext context, int index) {
        _ViewHolder holder = holders[index];
        return holder.type == _ViewHolder.CHILD
            ? inkwellItemCard(holder)
            : groupItemCard(holder);
      },
      staggeredTileBuilder: (int index) {
        _ViewHolder holder = holders[index];
        if (holder.type == _ViewHolder.GROUP) {
          return new StaggeredTile.count(2, 0.3);
        } else {
          return new StaggeredTile.count(1, 1);
        }
      },
    );
  }

  Widget groupItemCard(_ViewHolder holder) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Text(
        '-  ${holder.dataTime.year} 年 ${holder.dataTime.month} 月 -',
        style: TextStyle(fontSize: 15, color: Colors.black38),
      ),
      alignment: Alignment.center,
    );
  }

  Widget inkwellItemCard(_ViewHolder holder) {
    return InkWell(
      child: itemCard(holder),
      onTap: () => UI.openFile(context, holder.entity),
    );
  }

  Widget itemCard(_ViewHolder holder) {
    String path = holder.entity.path;
    return Card(
      elevation: 4,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          getThumbWidget(path),
          Positioned(
              right: 0,
              top: 0,
              child: CheckWidget(
                  value: selectedFiles.contains(path),
                  onChanged: (value) {
                    if (value) {
                      selectedFiles.add(path);
                      filesSize += holder.entity.statSync().size;
                    } else {
                      selectedFiles.remove(path);
                      filesSize -= holder.entity.statSync().size;
                    }
                  })),
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              UI.convertTimeToString(holder.dataTime),
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  onChange(bool value, FileSystemEntity file) {
    if (value) {
      selectedFiles.add(file.path);
      filesSize += file.statSync().size;
    } else {
      selectedFiles.remove(file.path);
      filesSize -= file.statSync().size;
    }
  }

  onTap(FileSystemEntity file) {
    UI.openFile(context, file,
        files: type2Files[currentType]); // 打开文件，传入当前展示的整个数据源
  }

  // 修改当前展示的数据分组
  notifyCurrentType(String type) {
    print(type);
    if (type == currentType) {
      return;
    }
    setState(() {
      currentType = type;
    });
  }

  // 类型筛选Grid
  Widget fileTypeGridView() {
    if (!Config.showType(argType)) {
      return Container();
    }
    List<String> types = type2Files.keys.toList();
    types.forEach(print);
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: types.length,
      itemBuilder: (context, index) {
        String type = types[index];
        return Padding(
            padding: EdgeInsets.only(right: 2, left: 2),
            child: UI.chipText(type2Icon[type], type, notifyCurrentType));
      },
    );
  }
}

class _ViewHolder {
  static const CHILD = 0;
  static const GROUP = 1;
  int type = 0; // type 0 is child, type 1 is group name
  FileSystemEntity entity;
  DateTime dataTime;
  _ViewHolder(this.entity, this.dataTime, this.type);
}
