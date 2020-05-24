import 'dart:math';

import 'package:bytes_cloud/entity/entitys.dart';

abstract class TranslateTask extends Entity {
  int uuid;
  // CancelToken token; // 任务id
  int time;
  int sent = 0;
  int total = 0;
  double v = 0; //速度
  double get progress {
    if (total == 0)
      return 0;
    else
      return sent / total;
  }

  TranslateTask({this.time}) : super.fromMap(null) {
    time = DateTime.now().millisecondsSinceEpoch;
    uuid = _generateUUid(time);
  }

  _generateUUid(int time) => (time - Random(time).nextInt(2000)).hashCode;

  String get name;
  String get pathMsg; // 路径信息
  String get filePath; // 本地全路径 用于打开文件

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslateTask &&
          runtimeType == other.runtimeType &&
          uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'time': time,
      'sent': sent,
      'total': total,
    };
  }

  TranslateTask.fromMap(Map map) : super.fromMap(null) {
    this.uuid = map['uuid'];
    this.time = map['time'];
    this.uuid = _generateUUid(this.time);
    this.sent = map['sent'];
    this.total = map['total'];
  }
}
