package com.bytescloud.bytes_cloud;

import android.annotation.TargetApi;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.webkit.MimeTypeMap;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String TAG = "MainActivity";
  private static final String METHOD_CHANNEL = "openFileChannel";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    //getPhoto();
  }

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    new MethodChannel(flutterEngine.getDartExecutor(), METHOD_CHANNEL).setMethodCallHandler(
            (methodCall, result) -> {
              if (methodCall.method.equals("openFile")) {
                String path = methodCall.argument("path");
                openFile(getContext(), path);
                result.success("");
              } else {
                result.notImplemented();
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
  private void getPhoto(){
    Cursor cursor = getContentResolver().query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, null, null, null, null);
    if (cursor == null) {
      Log.d(TAG, "getPhoto: cursor is null");
      return;
    }
    while (cursor.moveToNext()) {
      //String desc = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.RELATIVE_PATH));
      String isPrivide = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.IS_PRIVATE));

      String name = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME));
      int size = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.SIZE));
      int width = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.WIDTH));
      int height = cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.HEIGHT));
      byte[] data = cursor.getBlob(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
      //Log.d(TAG, name + " " + size + " " + desc);
      //getInfo(desc);
    }
    cursor.close();
  }

  @TargetApi(Build.VERSION_CODES.ECLAIR)
  private void getInfo(String path) {
    try {

      ExifInterface exifInterface = new ExifInterface(path);

      String guangquan = exifInterface.getAttribute(ExifInterface.TAG_APERTURE);
      String shijain = exifInterface.getAttribute(ExifInterface.TAG_DATETIME);
      String baoguangshijian = exifInterface.getAttribute(ExifInterface.TAG_EXPOSURE_TIME);
      String jiaoju = exifInterface.getAttribute(ExifInterface.TAG_FOCAL_LENGTH);
      String chang = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_LENGTH);
      String kuan = exifInterface.getAttribute(ExifInterface.TAG_IMAGE_WIDTH);
      String moshi = exifInterface.getAttribute(ExifInterface.TAG_MODEL);
      String zhizaoshang = exifInterface.getAttribute(ExifInterface.TAG_MAKE);
      String iso = exifInterface.getAttribute(ExifInterface.TAG_ISO);
      String jiaodu = exifInterface.getAttribute(ExifInterface.TAG_ORIENTATION);
      String baiph = exifInterface.getAttribute(ExifInterface.TAG_WHITE_BALANCE);
      String altitude_ref = exifInterface.getAttribute(ExifInterface.TAG_GPS_ALTITUDE_REF);
      String altitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_ALTITUDE);
      String latitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LATITUDE);
      String latitude_ref = exifInterface.getAttribute(ExifInterface.TAG_GPS_LATITUDE_REF);
      String longitude_ref = exifInterface.getAttribute(ExifInterface.TAG_GPS_LONGITUDE_REF);
      String longitude = exifInterface.getAttribute(ExifInterface.TAG_GPS_LONGITUDE);
      String timestamp = exifInterface.getAttribute(ExifInterface.TAG_GPS_TIMESTAMP);
      String processing_method = exifInterface.getAttribute(ExifInterface.TAG_GPS_PROCESSING_METHOD);


      StringBuilder stringBuilder = new StringBuilder();
      stringBuilder.append("光圈 = " + guangquan+"\n")
              .append("时间 = " + shijain+"\n")
              .append("曝光时长 = " + baoguangshijian+"\n")
              .append("焦距 = " + jiaoju+"\n")
              .append("长 = " + chang+"\n")
              .append("宽 = " + kuan+"\n")
              .append("型号 = " + moshi+"\n")
              .append("制造商 = " + zhizaoshang+"\n")
              .append("ISO = " + iso+"\n")
              .append("角度 = " + jiaodu+"\n")
              .append("白平衡 = " + baiph+"\n")
              .append("海拔高度 = " + altitude_ref+"\n")
              .append("GPS参考高度 = " + altitude+"\n")
              .append("GPS时间戳 = " + timestamp+"\n")
              .append("GPS定位类型 = " + processing_method+"\n")
              .append("GPS参考经度 = " + latitude_ref+"\n")
              .append("GPS参考纬度 = " + longitude_ref+"\n")
              .append("GPS经度 = " + latitude+"\n")
              .append("GPS经度 = " + longitude+"\n");
      Log.d(TAG, "getInfo: " + stringBuilder.toString());
      //将获取的到的信息设置到TextView上

      /**
       * 将wgs坐标转换成百度坐标
       * 就可以用这个坐标通过百度SDK 去获取该经纬度的地址描述
       */
      // double[] wgs2bd = GpsUtil.wgs2bd(lat, lon);


    } catch (Exception e) {
      e.printStackTrace();
    }
  }

}
