import 'dart:async';
import 'dart:io';

import 'package:bytes_cloud/core/Common.dart';
import 'package:bytes_cloud/pages/selectors/CloudFolderSelector.dart';
import 'package:bytes_cloud/pages/widgets/CheckWidget.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
import 'package:bytes_cloud/utils/ThumbUtil.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'SearchFilePage.dart';
import 'package:path/path.dart' as p;

class SysFileSelectorPage extends StatefulWidget {
  final Map<String, dynamic> args;
  SysFileSelectorPage(this.args);

  @override
  _FilesFragmentState createState() {
    return _FilesFragmentState(args);
  }
}

// AutomaticKeepAliveClientMixin 使得即使控件不现实也会保存状态
class _FilesFragmentState extends State<SysFileSelectorPage> {
  ScrollController controller = ScrollController();
  Set<String> selectedFiles = Set();
  int filesSize = 0;
  String root;
  String rootName;

  Directory parentDir;
  List<FileSystemEntity> files = [];
  List<double> position = []; // 栈中位置
  double imageSize;

  _FilesFragmentState(Map args) {
    root = args['root'];
    rootName = args['rootName'];
    parentDir = Directory(root);
    imageSize = UI.dpi2px(UI.DISPLAY_WIDTH / 3);
  }

  @override
  void initState() {
    super.initState();
    if (isImageMode()) {
      getAndSortImages(parentDir, files); // 获取所有的照片
    } else {
      getAndSortFiles(parentDir, files);
    }
  }

  // 截图和相机选择器采用不同的UI展示
  bool isImageMode() {
    return root == Common().camera || root == Common().screamShot;
  }

  // 初始化该路径下的文件、文件夹
  void initPathFiles(String path) {
    setState(() {
      root = path;
      parentDir = Directory(path);
      getAndSortFiles(parentDir, files);
    });
  }

  Future<bool> onWillPop() async {
    if (!isRoot()) {
      position.removeLast();
      initPathFiles(parentDir.parent.path);
      jumpToPosition(false);
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // WillPopScope 拦截back操作，当不在根目录时候，返回上一级目录
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            child: Icon(Icons.arrow_left),
            onTap: () => Navigator.pop(context),
          ),
          title: Text(rootName),
          centerTitle: true,
          actions: <Widget>[
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.file_upload),
                  onPressed: () {
                    UI.newPage(
                        context, CloudFolderSelector(selectedFiles.toList()));
//                    UI.pushToCloud(context, selectedFiles.length, filesSize);
                  },
                );
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: files.length == 0 ? _emptyView() : _bodyView()),
            Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: Text(
                      '总共 ${selectedFiles.length} 项，总共 ${FileUtil.getFileSize(filesSize)}'),
                ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: callNativeFileSearch,
        ),
      ),
    );
  }

  callNativeFileSearch() {
    UI.newPage(
        context,
        SearchFilePage({
          'key': '',
          'roots': [root]
        }));
  }

  _emptyView() =>
      Center(child: SizedBox(width: 160, child: Image.asset(Constants.NULL)));

  Widget bodyView;
  bool notifyListView = true; // 是否刷新列表
  _bodyView() {
    if (bodyView != null && !notifyListView)
      return bodyView;
    else
      bodyView = Scrollbar(
        child: isImageMode() ? imageGridView() : fileListView(),
      );
    return bodyView;
  }

  Widget imageGridView() {
    return GridView.builder(
        itemCount: files.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (context, index) {
          FileSystemEntity entity = files[index];
          Widget image;
          if (FileUtil.isVideo(entity.path)) {
            image = getThumbWidget(
              entity.path,
              width: imageSize,
              height: imageSize,
            );
          } else {
            image = Image.file(
              entity,
              fit: BoxFit.cover,
              cacheWidth: imageSize.toInt(),
            );
          }
          // add hero animator
          image = Hero(
            child: image,
            tag: entity.path,
          );
          Widget result = Stack(
            children: <Widget>[
              SizedBox(
                child: image,
                width: imageSize,
                height: imageSize,
              ),
              Positioned(
                  right: 0,
                  child: CheckWidget(
                    value: selectedFiles.contains(entity.path),
                    onChanged: (value) => onChange(value, entity),
                  ))
            ],
          );
          return InkWell(
              child: result,
              onTap: () => UI.openFile(context, files[index], files: files));
        });
  }

  Widget fileListView() => ListView.builder(
        physics: BouncingScrollPhysics(),
        controller: controller,
        itemCount: files.length,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          if (FileSystemEntity.isFileSync(files[index].path))
            //return _buildFileItem(files[index]);
            return UI.buildFileItem(
                file: files[index],
                isCheck: selectedFiles.contains(files[index].path),
                onChanged: onChange,
                onTap: () => UI.openFile(context, files[index], files: files));
          else
            return UI.buildFolderItem(
                file: files[index],
                onTap: () {
                  // 点进一个文件夹，记录进去之前的offset
                  // 返回上一层跳回这个offset，再清除该offset
                  position.add(controller.offset);
                  print("FileManager ${position.toString()}");
                  initPathFiles(files[index].path);
                  jumpToPosition(true);
                });
        },
      );

  onChange(bool value, FileSystemEntity file) {
    if (value) {
      selectedFiles.add(file.path);
      filesSize += file.statSync().size;
    } else {
      selectedFiles.remove(file.path);
      filesSize -= file.statSync().size;
    }
    notifyListView = false;
    setState(() {});
  }

  void jumpToPosition(bool isEnter) async {
    if (isEnter)
      controller.jumpTo(0.0);
    else {
      try {
        await Future.delayed(Duration(milliseconds: 10)); // 不添加这个下面代码无法生效
        controller?.jumpTo(position[position.length - 1]);
      } catch (e) {}
    }
  }

  // 排序，文件夹在前面、文件在后面，按照字母排序
  getAndSortFiles(Directory parentDir, List<FileSystemEntity> result) {
    result.clear();
    List<FileSystemEntity> _files = [];
    List<FileSystemEntity> _folder = [];

    for (var v in parentDir.listSync()) {
      // 去除以 .开头的文件/文件夹
      if (p.basename(v.path).substring(0, 1) == '.') {
        continue;
      }
      if (FileSystemEntity.isFileSync(v.path))
        _files.add(v);
      else
        _folder.add(v);
    }

    fileFilter(_folder); // 只显示关键文件

    _files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _folder
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    result.addAll(_files);
    result.addAll(_folder);
  }

  void getAndSortImages(Directory parentDir, List<FileSystemEntity> files) {
    files.clear();
    List<FileSystemEntity> realGet(Directory parentDir) {
      List<FileSystemEntity> result = [];
      List<FileSystemEntity> files = parentDir.listSync();
      for (var v in files) {
        if (FileSystemEntity.isFileSync(v.path)) {
          if (FileUtil.isImage(v.path) || FileUtil.isVideo(v.path)) {
            result.add(v);
          }
        } else {
          result.addAll(realGet(v));
        }
      }
      return result;
    }

    files.addAll(realGet(parentDir));
  }

  // QQ 下的文件过滤一下
  void fileFilter(List<FileSystemEntity> _folder) {
    if (root == Common().TencentRoot && isRoot()) {
      _folder.clear();
      Common().qqFiles.forEach((f) {
        if (f.existsSync()) _folder.add(f);
      });
    }
  }

  bool isRoot() => position.length == 0;
}
