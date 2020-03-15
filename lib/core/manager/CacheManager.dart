import 'dart:core';

import 'dart:io';

// keys : FileTypeUtils.ARG : photo, video,
Map<String, List<FileSystemEntity>> cache = {}; // 缓存
