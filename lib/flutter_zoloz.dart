
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterZoloz {
  static const MethodChannel _channel =
      const MethodChannel('flutter_zoloz');
  static int idPool = 1;
  static Map<int, Function> callbacks = {};
  static Future<bool> init() async {
    print("init flutter MethodChannel name: flutter_zoloz ");
    Future<Map> _methodCallHandler(MethodCall call) async {
      print("_methodCallHandler call");
      print(call.toString());
      if (call.method == "VerifyFinish") {
        int callId = call.arguments['callId'];
        //TODO
        String token = call.arguments['token'];
        int result = call.arguments['result'];
        String resultCode = call.arguments['resultCode'];
        String resultMsg = call.arguments['resultMsg'];
        if (callbacks[callId] != null) {
          callbacks[callId](token, result, resultCode, resultMsg, callId);
          Map ret = {};
          ret['code'] = "ok";
          return ret;
        } else {
          print("error! bad callId" + callId.toString());
        }
      } else {
        Map ret = {};
        ret['code'] = 'no_method';
        ret['msg'] = "no this method";
        ret['data'] = {};
        return ret;
      }
    }
    _channel.setMethodCallHandler(_methodCallHandler);
    return true;
  }
  static Future<Map> getMetaInfo() async{
    final Map ret = await _channel.invokeMethod('getMetaInfo');
    return ret;
  }
  static Future<Map> startAuthWithConfig(
      Map config, Function resultCallback) async {
    idPool += 1;
    callbacks[idPool] = resultCallback;
    
    config['callId'] = idPool;
    Map ret;
    try {
      print("call _channel startAuthWithConfig");
      ret = await _channel.invokeMethod('startAuthWithConfig', config);
      print("call _channel startAuthWithConfig done");
    } catch(e) {
      print("!!!!!! exception"+e.toString());
    }
    ret['callId'] = idPool;
    return ret;
  }
}
