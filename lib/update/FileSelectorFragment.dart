import 'dart:async';

import 'package:bytes_cloud/utils/Constants.dart';
import 'package:bytes_cloud/utils/UI.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../EventBusUtil.dart';
import '../common.dart';

/// 点击一个文件夹，传入文件夹的路径，显示该文件夹下的文件和文件夹
/// 点击一个文件，打开
/// 返回上一层，返回上一层目录路径 [dir.parent.path]
class FileSelectorFragment extends StatefulWidget {
  @override
  _FilesFragmentState createState() {
    return _FilesFragmentState();
  }
}

// AutomaticKeepAliveClientMixin 使得即使控件不现实也会保存状态
class _FilesFragmentState extends State<FileSelectorFragment>
    with AutomaticKeepAliveClientMixin {
  MethodChannel _channel = MethodChannel('openFileChannel');
  ScrollController controller = ScrollController();
  Set<String> selectedFiles = Set();
  int filesSize = 0;

  Directory parentDir;
  List<FileSystemEntity> files = [];
  List<double> position = []; // 栈中位置

  @override
  void initState() {
    super.initState();
    // 监听用户点击上传按钮的动作
    GlobalEventBus().event.on<FilesPushEvent>().listen((event) {
      String content = '';
      if (selectedFiles.length == 0) {
        content = '没有选择任何文件';
      } else {
        content =
            '开始上传，总共${selectedFiles.length}个文件，共${Common().getFileSize(filesSize)}';
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(content)));
    });
    parentDir = Directory(Common().sDCardDir);
    initPathFiles(Common().sDCardDir);
  }

  Future<bool> onWillPop() async {
    if (parentDir.path != Common().sDCardDir) {
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
        body: Column(
          children: <Widget>[
            Expanded(child: files.length == 0 ? _emptyView() : _listView()),
            Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child:
                      Text('上传到ByteCloud，总共${Common().getFileSize(filesSize)}'),
                ))
          ],
        ),
      ),
    );
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
              return _buildFileItem(files[index]);
            else
              return _buildFolderItem(files[index]);
          },
        ),
      );

  Widget _buildFileItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 0.5, color: Color(Constants.COLOR_DIVIDER))),
        ),
        child: ListTile(
            leading: Image.asset(Common().selectIcon(p.extension(file.path))),
            title: Text(file.path.substring(file.parent.path.length + 1)),
            subtitle: Text(
                '$modifiedTime  ${Common().getFileSize(file.statSync().size)}',
                style: TextStyle(fontSize: 12.0)),
            trailing: Checkbox(
              value: selectedFiles.contains(file.path),
              onChanged: (bool value) {
                setState(() {
                  if (value) {
                    selectedFiles.add(file.path);
                    filesSize += file.statSync().size;
                  } else {
                    selectedFiles.remove(file.path);
                    filesSize -= file.statSync().size;
                  }
                });
              },
            )),
      ),
      onTap: () {
        openFile(file.path);
      },
    );
  }

  Widget _buildFolderItem(FileSystemEntity file) {
    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss', 'zh_CN')
        .format(file.statSync().modified.toLocal());

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
      position.removeLast();
    }
  }

  // 初始化该路径下的文件、文件夹
  void initPathFiles(String path) {
    setState(() {
      parentDir = Directory(path);
      sortFiles();
    });
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

    _files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    _folder
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.clear();
    files.addAll(_folder);
    files.addAll(_files);
  }

  Future openFile(String path) async {
    final Map<String, dynamic> args = <String, dynamic>{'path': path};
    await _channel.invokeMethod('openFile', args);
  }

  @override
  bool get wantKeepAlive => true;
}
