import 'dart:async';
import 'dart:io';

import 'package:bytes_cloud/core/common.dart';
import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/FileUtil.dart';
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
class _FilesFragmentState extends State<SysFileSelectorPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();
  Set<String> selectedFiles = Set();
  int filesSize = 0;
  String root;
  String rootName;

  Directory parentDir;
  List<FileSystemEntity> files = [];
  List<double> position = []; // 栈中位置

  _FilesFragmentState(Map args) {
    root = args['root'];
    rootName = args['rootName'];
  }

  @override
  void initState() {
    super.initState();
    initPathFiles(root);
  }

  // 初始化该路径下的文件、文件夹
  void initPathFiles(String path) {
    setState(() {
      root = path;
      parentDir = Directory(path);
      sortFiles();
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
    super.build(context);
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
                    UI.pushToCloud(context, selectedFiles.length, filesSize);
                  },
                );
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: files.length == 0 ? _emptyView() : _listView()),
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
    UI.newPage(context, SearchFilePage({'key': '', 'root': root}));
  }

  _emptyView() =>
      Center(child: SizedBox(width: 160, child: Image.asset(Constants.NULL)));

  _listView() => Scrollbar(
        child: ListView.builder(
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
                  onTap: onTap);
            else
              return _buildFolderItem(files[index]);
          },
        ),
      );
  onTap(FileSystemEntity file) {
    print('open file ' + file.path);
    UI.openFile(context, file, files: files);
  }

  onChange(bool value, FileSystemEntity file) {
    setState(() {
      if (value) {
        selectedFiles.add(file.path);
        filesSize += file.statSync().size;
      } else {
        selectedFiles.remove(file.path);
        filesSize -= file.statSync().size;
      }
    });
  }

  Widget _buildFolderItem(FileSystemEntity file) {
    String modifiedTime;
    try {
      modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
          .format(file.statSync().modified.toLocal());
    } catch (e) {
      modifiedTime = '';
    }

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(width: 0.5, color: Color(0xffe5e5e5))),
        ),
        child: ListTile(
          leading: Image.asset('assets/images/folder.png'),
          title: Row(
            children: <Widget>[
              Expanded(
                  child:
                      Text(file.path.substring(file.parent.path.length + 1))),
              Text(
                '${_calculateFilesCountByFolder(file)}项',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
          subtitle: Text(modifiedTime, style: TextStyle(fontSize: 12.0)),
          trailing: Icon(Icons.chevron_right),
        ),
      ),
      onTap: () {
        // 点进一个文件夹，记录进去之前的offset
        // 返回上一层跳回这个offset，再清除该offset
        position.add(controller.offset);
        print("FileManager ${position.toString()}");
        initPathFiles(file.path);
        jumpToPosition(true);
      },
    );
  }

  // 计算以 . 开头的文件、文件夹总数
  int _calculatePointBegin(List<FileSystemEntity> fileList) {
    int count = 0;
    for (var v in fileList) {
      if (p.basename(v.path).substring(0, 1) == '.') count++;
    }
    return count;
  }

  // 计算文件夹内 文件、文件夹的数量，以 . 开头的除外
  int _calculateFilesCountByFolder(Directory path) {
    var dir = path.listSync();
    int count = dir.length - _calculatePointBegin(dir);
    return count;
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
  void sortFiles() {
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
    files.clear();
    files.addAll(_folder);
    files.addAll(_files);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void deactivate() {
    super.deactivate();
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
