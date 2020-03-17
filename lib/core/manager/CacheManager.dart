import 'dart:collection';
import 'dart:core';

import 'dart:io';

import 'package:flutter/material.dart';

// keys : FileTypeUtils.ARG : photo, video,
Map<String, List<FileSystemEntity>> cache = {}; // 缓存

//LinkedHashMap<String, Widget> widgetCache = LinkedHashMap();
//addWidgetCache(String k, Widget w) {
//  print('add cache');
//  if (widgetCache.length > 100) {
//    print('remove cache ${widgetCache.length}');
//    widgetCache.remove(widgetCache.keys.toList()[0]);
//  }
//  widgetCache[k] = w;
//}
//
//getWidgetCache(String key) {
//  print('hit key');
//  Widget w = widgetCache[key];
//  widgetCache.remove(key);
//  widgetCache[key] = w;
//  return w;
//}
