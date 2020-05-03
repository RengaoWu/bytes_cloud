package com.bytescloud.bytes_cloud;

import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.StatFs;
import android.os.storage.StorageManager;
import android.provider.MediaStore;
import android.util.Log;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String TAG = "MainActivity";
    private static final String COMMON_CHANNEL = "common";
    private static final Handler ui = new Handler();

    // METHOD LIST
    private static final String getThumbnails = "getThumbnails";
    private static final String getCardState = "getCardState";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor(), COMMON_CHANNEL).setMethodCallHandler(
                (methodCall, result) -> {
                    if (methodCall.method.equals(getThumbnails)) {
                        handleGetThumbanils(methodCall, result);
                    } else if (methodCall.method.equals(getCardState)) {
                        handleGetCardState(methodCall,result);
                    }else {
                        result.notImplemented();
                    }
                }
        );
    }

    private void handleGetCardState(MethodCall methodCall, MethodChannel.Result result) {
//        Map<String, Long> res = new HashMap<String,Long>();
//        String state = Environment.getExternalStorageState();
//        if(Environment.MEDIA_MOUNTED.equals(state)) {
//            File sdcardDir = Environment.getExternalStorageDirectory();
//            StatFs sf = new StatFs(sdcardDir.getPath());
//            long blockSize = sf.getBlockSize();
//            long blockCount = sf.getBlockCount();
//            long availCount = sf.getAvailableBlocks();
//            Log.d("", "block大小:"+ blockSize+",block数目:"+ blockCount+",总大小:"+blockSize*blockCount/(1024*1024*1024)+"GB");
//            Log.d("", "可用的block数目：:"+ availCount+",剩余空间:"+ availCount*blockSize/(1024*1024*1024)+"GB");
//            res.put("SDAll" , blockSize*blockCount);
//            res.put("SDAVA", availCount * blockSize);
//        }
//
//        File root = Environment.getRootDirectory();
//        StatFs sf = new StatFs(root.getPath());
//        long all = sf.getTotalBytes();
//        long ava = sf.getAvailableBytes();
//        res.put("allSize" , all);
//        res.put("availableSize", ava);
        result.success(StorageQueryUtil.queryWithStorageManager(getActivity()));
    }

    private void handleGetThumbanils(MethodCall methodCall, MethodChannel.Result result) {
        ArrayList<String> args = (ArrayList<String>) methodCall.arguments;
        if (args == null) {
            result.error("1", "arg is null", "");
            return;
        }
        new Thread() {
            @Override
            public void run() {
                ArrayList<String> res = userDirectory(args.subList(1, args.size()), args.get(0), 50);
                if (res == null) {
                    ui.post(() -> result.error("2", "create dir failed", ""));
                } else {
                    ui.post(() -> result.success(res));
                }
            }
        }.start();
    }

    private ArrayList<String> userDirectory(List<String> vidPath, String thumbPath, int quality) {
        ArrayList<String> res = new ArrayList<>();
        List<Bitmap> bitmaps = new ArrayList<Bitmap>(vidPath.size());
        List<String> vidNames = new ArrayList<String>(vidPath.size());
        for (int i = 0; i < vidPath.size(); i++) {
            Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(vidPath.get(i), MediaStore.Video.Thumbnails.MINI_KIND);
            bitmaps.add(bitmap);
            vidNames.add(getFileName(Uri.parse(vidPath.get(i)).getLastPathSegment()));
        }
        File fileDir = new File(thumbPath + File.separator);
        if (!fileDir.exists()) {
            boolean b = fileDir.mkdirs();
            if (!b) {
                return null;
            }
        }
        try {
            for (int i = 0; i < bitmaps.size(); i++) {
                Bitmap bitmap = bitmaps.get(i);
                if (bitmap == null) {
                    res.add(""); // 测试发现这里可能为null
                    continue;
                }
                String tempFile = new File(fileDir.getAbsolutePath() + File.separator + vidNames.get(i)).getAbsolutePath();
                FileOutputStream out = new FileOutputStream(new File(tempFile + ".png"));
                Log.d(TAG, "userDirectory: " + tempFile);
                bitmaps.get(i).compress(Bitmap.CompressFormat.PNG, quality, out);
                out.flush();
                out.close();
                res.add(tempFile + ".png");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return res;
    }

    private static final Pattern ext = Pattern.compile("(?<=.)\\.[^.]+$");

    private String getFileName(String s) {
        return ext.matcher(s).replaceAll("");
    }

}
