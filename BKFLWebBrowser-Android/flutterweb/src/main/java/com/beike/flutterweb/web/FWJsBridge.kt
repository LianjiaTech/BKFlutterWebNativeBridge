package com.beike.flutterweb.web

import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import android.webkit.JavascriptInterface
import android.webkit.WebView
import com.beike.flutterweb.Consts
import com.beike.flutterweb.FlutterWebChannelManager
import com.beike.flutterweb.interfaces.IFlutterWebActivityDelegate
import com.beike.flutterweb.interfaces.IFlutterWebJsBridgeCallBack
import com.beike.flutterweb.utils.TransformUtils
import com.beike.flutterweb.utils.WebUtils
import com.google.gson.Gson

import io.flutter.plugin.common.MethodChannel
import org.json.JSONException
import org.json.JSONObject
import java.util.*

class FWJsBridge(
    private val mDelegate: IFlutterWebActivityDelegate,
    private val callBack: IFlutterWebJsBridgeCallBack
) {
    private val mHandler = Handler(Looper.getMainLooper())

    /**
     * 注册Handler
     * 参考:flutter_message_channel_specific.js
     * registerHandler(bridge_handler_name, (request/BridgeData/, callback) => {})
     */
    @JavascriptInterface
    fun registerHandler(bridgeHandlerName: String?, func: String?) {
        if (bridgeHandlerName.isNullOrBlank() || func.isNullOrBlank()) {
            return
        }
        mDelegate.getFlutterWebChannelManager().putFlutterMethodChannel(
            bridgeHandlerName.replace(
                ".${Consts.BEIKE_CHANNEL_FLUTTER_HANDLER}",
                ""
            ), func
        )
        if ("lianjia_method_channel_flutter_runner.FlutterHandler" == bridgeHandlerName) {
            runOnUiThread(Runnable { callBack.onFlutterRunnerReady() })
        }
        Log.d(
            TAG,
            String.format(
                "FlutterWeb register Handler success, Channel: %s  func: %s",
                bridgeHandlerName,
                func
            )
        )
    }

    /**
     * 调用Handler
     * 参考:flutter_message_channel_specific.js
     * callHandler(bridge_handler_name, request, (response/BridgeData/) => {})
     */
    @JavascriptInterface
    fun callHandler(bridgeHandlerName: String, request: String?, callback: String?) {
        Log.d(
            TAG,
            String.format(
                "FlutterWeb callHandler:HandlerName: %s  request: %s",
                bridgeHandlerName,
                request
            )
        )
        val methodChannel = FlutterWebChannelManager.getNativeMethodChannel(
            bridgeHandlerName.replace(
                ".${Consts.BEIKE_CHANNEL_NATIVE_HANDLER}",
                ""
            )
        )
        if (methodChannel == null || request.isNullOrBlank()) {
            Log.e(
                TAG,
                String.format(
                    "FlutterWeb callHandler failed:HandlerName: %s  request: %s",
                    bridgeHandlerName,
                    request
                )
            )
            return
        }
        try {
            val requestObj = JSONObject(request)
            val method = requestObj.optString("method")
            val args = requestObj.optString("args")
            val type = requestObj.optString("type")
            if (TextUtils.isEmpty(method)) {
                return
            }
            val fwWebView = mDelegate.getFWWebView()
            if ("lianjia_method_channel_lianjia_device_info_plugin" == methodChannel.name && method == "deviceInfo") {
                // 设备信息的plugin MethodChannel 这里需要仿照FlutterView处理,而Plugin里面没法处理View,所以这里特殊处理下
                val resultMap: MutableMap<String, Any> = HashMap()
                resultMap["devicePixelRatio"] = fwWebView.metrics.devicePixelRatio
                resultMap["paddingTop"] = fwWebView.metrics.physicalPaddingTop
                resultMap["paddingBottom"] = fwWebView.metrics.physicalPaddingBottom
                notifyWebView(
                    fwWebView,
                   WebUtils. buildCallFunJSWithType(callback!!, Gson().toJson(resultMap))
                )
                return
            }
            if ("lianjia_method_channel_flutter_runner" == methodChannel.name) {
                // 这里因为我们无法完全模拟Flutter Runner内容,部分方法需要迁移到自己容器处理 参见:com.ke.flutterrunner.FlutterRunnerPlugin
                when (method) {
                    "openPage", "openPageFromFragment" -> {
                        if (TextUtils.isEmpty(args)) {
                            return
                        }
                        val argsMap =
                            TransformUtils.standardMessageTransform(args, type) as HashMap<*, *>?
                        val params = argsMap!!["urlParams"] as MutableMap<String?, Any?>?
                        val url = argsMap["url"] as String?
                        var requestCode = -1
                        if (params != null) {
                            val v = params.remove(IFlutterWebActivityDelegate.REQUEST_CODE)
                            if (v != null) {
                                requestCode = Integer.valueOf(v.toString())
                            }
                        }
                        if (requestCode > 0) {
                            mDelegate.getRequestCodeAndCallBack()[requestCode] = callback!!
                        }
                        val targetUrl = TransformUtils.decodeUriQuery(url)
                        val bundle = TransformUtils.map2Bundle(params)
                        //当 requestCode > 0的时候，才是startActivityForResult()
                        Log.i(TAG,"open page $targetUrl params $params")
                        return
                    }
                    "closePage" -> {
                        val argsMapClosePage =
                           TransformUtils. standardMessageTransform(args, type) as HashMap<*, *>?
                        val resultMap = argsMapClosePage!!["result"] as Map<String, Any>?
                        mDelegate.finishContainer(resultMap)
                        return
                    }
                    "onPageStart" -> {
                        mDelegate.invokeChannelWithParams("onPageStart")
                        return
                    }
                    "initialRoute" -> {
                        notifyWebView(
                            fwWebView,
                            WebUtils.buildCallFunJSWithType(callback!!, mDelegate.initialRoute())
                        )
                        return
                    }
                    "isUserVisible" -> {
                        notifyWebView(
                            fwWebView,
                            WebUtils.buildCallFunJSWithType(
                                callback!!,
                                mDelegate.isUserVisible().toString()
                            )
                        )
                        return
                    }
                }
            }
            methodChannel.invokeMethod(method,
                TransformUtils.standardMessageTransform(args, type),
                object : MethodChannel.Result {
                    override fun success(o: Any?) {
                        notifyWebView(fwWebView,  WebUtils.buildCallFunJSWithType(callback!!, o!!))
                    }

                    override fun error(s: String, s1: String?, o: Any?) {
                        notifyWebView(fwWebView,  WebUtils.buildCallFunJSWithType(callback!!, o!!))
                    }

                    override fun notImplemented() {
                        notifyWebView(fwWebView,  WebUtils.buildCallFunJSWithType(callback!!, ""))
                    }
                })
        } catch (e: Throwable) {
            Log.e(
                TAG,
                String.format(
                    "FlutterWeb callHandler failed:HandlerName: %s  request: %s",
                    bridgeHandlerName,
                    request
                )
            )
            e.printStackTrace()
        }
    }

    /**
     * 调用Flutter channel 返回的结果
     * data = {
     * 'channel_name' : channel_name,
     * 'method' : method_name,
     * 'args' : _args,
     * 'type' : type
     * }
     * @param response
     */
    @JavascriptInterface
    fun callFlutterChannelResponse(response: String?) {
        Log.d(TAG, "callFlutterChannelResponse=>response:$response")
        if (response != null) {
            try {
                val obj = JSONObject(response)
                val result = mDelegate.getFlutterWebChannelManager().getNativeInvokeFlutterMethodResult(
                    obj.optString("channel_name") + "_" + obj.optString("method")
                )
                result?.success(obj.optString("response"))
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    fun notifyWebView(webView: WebView?, js: String) {
        runOnUiThread(Runnable { WebUtils.notifyWebView(webView, js) })
    }

    private fun runOnUiThread(action: Runnable) {
        if (Looper.getMainLooper() != Looper.myLooper()) {
            mHandler.post(action)
        } else {
            action.run()
        }
    }

    companion object {
        private const val TAG = "FlutterWebJsBridge"
        const val JS_BRIDGE_NAME = "WebViewJavascriptBridge"
    }
}