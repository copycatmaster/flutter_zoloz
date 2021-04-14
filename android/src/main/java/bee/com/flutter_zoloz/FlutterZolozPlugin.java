package bee.com.flutter_zoloz;

import java.util.HashMap;
import androidx.annotation.NonNull;
import android.util.Log;
import android.app.Activity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.ap.zoloz.hummer.api.IZLZCallback;
import com.ap.zoloz.hummer.api.ZLZConstants;
import com.ap.zoloz.hummer.api.ZLZFacade;
import com.ap.zoloz.hummer.api.ZLZRequest;
import com.ap.zoloz.hummer.api.ZLZResponse;

//-dontwarn com.zoloz.**
//        -keep class com.zoloz.zhub.**{
//<fields>;
//<methods>;
//}
//        -keep class com.alipay.zoloz.**{
//<fields>;
//<methods>;
//}
//        -keep class com.alipay.android.phone.zoloz.**{
//<fields>;
//<methods>;
//}
//        -keep class com.alipay.biometrics.**{
//<fields>;
//<methods>;
//}
//        -keep class com.alipay.bis.**{
//<fields>;
//<methods>;
//}
//        -keep class com.alipay.mobile.security.**{
//<fields>;
//<methods>;
//}
//        -keep class com.ap.zoloz.**{
//<fields>;
//<methods>;
//}
//        -keep class com.ap.zhubid.endpoint.**{
//<fields>;
//<methods>;
//}
//        -keep class com.zoloz.android.phone.zdoc.**{
//<fields>;
//<methods>;
//}
//        -keep class zoloz.ap.com.toolkit.**{
//<fields>;
//<methods>;
//}
//        -keep class com.zoloz.builder.** {
//<fields>;
//<methods>;
//}


/** FlutterZolozPlugin */
public class FlutterZolozPlugin implements FlutterPlugin, MethodCallHandler,ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity activity;
  private String metaInfo;
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    //Log.e("flutter"," onAttachedToActivity !!!");
    activity = binding.getActivity();



  }

  public static HashMap<String,Object> packResult(final String code,final  String msg,final  HashMap<String,Object> data) {
    return new HashMap<String,Object>(){{
      put("code",code);
      put("msg",msg);
      put("data",data);
    }};
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    //Log.e("flutter"," onDetachedFromActivityForConfigChanges !!!");
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    //Log.e("flutter"," onReattachedToActivityForConfigChanges !!!");
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    //Log.e("flutter"," onDetachedFromActivity !!!");
    activity = null;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_zoloz");

    metaInfo = ZLZFacade.getMetaInfo(flutterPluginBinding.getApplicationContext());

    channel.setMethodCallHandler(this);


  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.i("flutter","onMethodCall:"+call.method);
    if(activity == null) {
      result.success(packResult("fail", "fail", new HashMap<String,Object>(){{
      }}));
      return;
    }
//
//    if(call.argument("token")!=null) {
//      Log.i("flutter","token:"+call.argument("token").toString());
//    }
    if (call.method.equals("getMetaInfo")) {
      result.success(packResult("ok", "ok", new HashMap<String, Object>() {{
        put("metaInfo",metaInfo);
      }}));
      return;
    } else if (call.method.equals("startAuthWithConfig")) {
      ZLZRequest request = new ZLZRequest();

      if(call.argument("clientCfg")!=null) {
        Log.i("flutter","clientCfg:"+call.argument("clientCfg").toString());
      } else {
        result.success(packResult("param_error", "need clientCfg", new HashMap<String,Object>(){{}}));
        return;
      }
      if(call.argument("callId")!=null) {
        Log.i("flutter","callId:"+call.argument("callId").toString());
      }else {
        result.success(packResult("param_error", "need callId", new HashMap<String,Object>(){{}}));
        return;
      }
      final int callId = Integer.parseInt(call.argument("callId").toString());
      if(call.argument("locate")!=null) {
        Log.i("flutter","locate:"+call.argument("locate").toString());
      }else {
        result.success(packResult("param_error", "need locate", new HashMap<String,Object>(){{}}));
        return;
      }
      if(call.argument("publicKey")!=null) {
        Log.i("flutter","publicKey:"+call.argument("publicKey").toString());
      } else {
        result.success(packResult("param_error", "need publicKey", new HashMap<String,Object>(){{}}));
        return;
      }

      request.bizConfig = new HashMap<>();
      request.bizConfig.put(ZLZConstants.CONTEXT, activity);
      request.bizConfig.put(ZLZConstants.PUBLIC_KEY, call.argument("publicKey").toString());
      request.bizConfig.put(ZLZConstants.LOCALE, call.argument("locate").toString());
      //请求服务器
      String clientCfg = "";
      request.zlzConfig = clientCfg;

      ZLZFacade.getInstance().start(request, new IZLZCallback() {
        @Override
        public void onCompleted(ZLZResponse response) {
          Log.i("flutter", "response:" + response.toString());



          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {

                channel.invokeMethod("VerifyFinish",new HashMap<String, Object>() {{
                    put("callId", callId);
                  }
                }, new MethodChannel.Result() {
                  @Override
                  public void error(String errorCode, String errorMessage, Object errorDetails){}
                  @Override
                  public void success(Object result) {}
                  @Override
                  public void notImplemented() {
                    Log.e("flutter","notImplemented call");
                  }
                });
            }
          });

          
        }

        @Override
        public void onInterrupted(ZLZResponse response) {
          Log.i("flutter", "response:" + response.toString());
          channel.invokeMethod("VerifyFinish",new HashMap<String, Object>() {{
            put("callId", callId);
          }
          }, new MethodChannel.Result() {
            @Override
            public void error(String errorCode, String errorMessage, Object errorDetails){}
            @Override
            public void success(Object result) {}
            @Override
            public void notImplemented() {
              Log.e("flutter","notImplemented call");
            }
          });
        }
      });
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
