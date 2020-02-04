package com.bytescloud.bytes_cloud;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.webkit.MimeTypeMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String METHOD_CHANNEL = "openFileChannel";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor(), METHOD_CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
                if (methodCall.method.equals("openFile")) {
                  String path = methodCall.argument("path");
                  openFile(getContext(), path);
                  result.success("");
                } else {
                  result.notImplemented();
                }
              }
            }
    );
  }
  private void openFile(Context context, String path) {
    try {
      if (!path.contains("file://")) {
        path = "file://" + path;
      }
      //获取文件类型
      String[] nameType = path.split("\\.");
      String mimeType = MimeTypeMap.getSingleton().getMimeTypeFromExtension(nameType[1]);

      Intent intent = new Intent();
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent.setAction(Intent.ACTION_VIEW);
      //设置文件的路径和文件类型
      intent.setDataAndType(Uri.parse(path), mimeType);
      //跳转
      context.startActivity(intent);
    } catch (Exception e) {
      System.out.println(e);
    }
  }
}
