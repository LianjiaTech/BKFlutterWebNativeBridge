package com.beike.flutterweb

import android.text.TextUtils
import android.util.Log
import android.webkit.WebView
import androidx.annotation.UiThread
import com.beike.flutterweb.utils.WebUtils
import com.beike.flutterweb.web.FWJsBridge
import com.google.gson.Gson
import io.flutter.plugin.common.*

import java.util.*

class FlutterWebChannelManager {
    private val flutterMethodChannelMap: MutableMap<String, String> = HashMap()

    // 保存Result，当H5回调回来结果的时候匹配  key: channel.method
    private val nativeInvokeFlutterMethodResult: MutableMap<String, MethodChannel.Result> =
        mutableMapOf()

    fun getFlutterMethodChannel(name: String): String? {
        return flutterMethodChannelMap[name]
    }

    fun putFlutterMethodChannel(name: String, callbackFun: String) {
        flutterMethodChannelMap[name] = callbackFun
    }

    // 这个key应该用生成的唯一标识来处理,否则channel_name + "_" + method 也可能重复
    fun getNativeInvokeFlutterMethodResult(key: String): MethodChannel.Result? {
        return nativeInvokeFlutterMethodResult[key]
    }

    fun putNativeInvokeFlutterMethodResult(key: String, result: MethodChannel.Result) {
        nativeInvokeFlutterMethodResult[key] = result
    }

    fun nativeInvokeFlutterMethod(
        webView: WebView?,
        channelName: String,
        method: String?,
        args: Any?,
        result: MethodChannel.Result?
    ) {
        val func = getFlutterMethodChannel(Consts.BEIKE_METHOD_CHANNEL + "_" + channelName)
        if (!TextUtils.isEmpty(func)) {
            val params = HashMap<String, String>()
            val gson = Gson()
            params["method"] = method!!
            params["args"] = gson.toJson(args)
            params["type"] = WebUtils.transferJSType(args)
            WebUtils.notifyWebView(
                webView, WebUtils.buildCallFunJS(
                    func!!, gson.toJson(params)!!,
                    "'" + FWJsBridge.JS_BRIDGE_NAME + ".callFlutterChannelResponse" + "'"
                )
            )
            if (result != null) {
                putNativeInvokeFlutterMethodResult(channelName + "_" + method, result)
            }
            Log.d(
                TAG,
                String.format(
                    "Native invoke FlutterWeb methodChannel Success, Channel: %s Method: %s",
                    channelName,
                    method
                )
            )
        } else {
            Log.e(
                TAG,
                String.format(
                    "Native invoke FlutterWeb methodChannel Failed, Channel: %s  Method: %s",
                    channelName,
                    method
                )
            )
        }
    }

    class MethodChannelWrapper @JvmOverloads constructor(
        name: String?,
        codec: MethodCodec? = StandardMethodCodec.INSTANCE
    ) {
        val name: String?
        private val codec: MethodCodec?
        private var handler: MethodChannel.MethodCallHandler? = null

        @UiThread
        fun invokeMethod(method: String, arguments: Any?) {
            this.invokeMethod(method, arguments, null as MethodChannel.Result?)
        }

        @UiThread
        fun invokeMethod(
            method: String?, arguments: Any?,
            callback: MethodChannel.Result?
        ) {
            if (handler != null) {
                try {
                    handler!!.onMethodCall(MethodCall(method, arguments), callback!!)
                } catch (ignore: Throwable) {
                }
            }
        }

        @UiThread
        fun setMethodCallHandler(handler: MethodChannel.MethodCallHandler?) {
            this.handler = handler
        }

        init {
            if (name == null) {
                Log.e("MethodChannel#", "Parameter name must not be null.")
            }
            if (codec == null) {
                Log.e("MethodChannel#", "Parameter codec must not be null.")
            }
            this.name = name
            this.codec = codec
        }
    }

    companion object {
        private const val TAG = "FlutterWebChannelMgr"
        private val nativeMethodChannelMap: MutableMap<String, MethodChannelWrapper> = HashMap()
        fun getNativeMethodChannel(name: String): MethodChannelWrapper? {
            return nativeMethodChannelMap[name]
        }

        fun putNativeMethodChannel(
            name: String,
            messenger: BinaryMessenger?,
            codec: MethodCodec?
        ): MethodChannelWrapper? {
            var name2 = name
            name2 = Consts.BEIKE_METHOD_CHANNEL + "_" + name2
            if (!nativeMethodChannelMap.containsKey(name2)) {
                nativeMethodChannelMap[name2] = MethodChannelWrapper(name2, codec)
            }
            return nativeMethodChannelMap[name2]
        }

        fun attachNativeMethodChannel(webView: WebView?) {
            for ((key) in nativeMethodChannelMap) {
                WebUtils.notifyWebView(
                    webView,
                    "lianjia_method_channel_register("
                            + "'" + key + "'"
                            + ");" +
                            "lianjia_method_channel_register_by_native("
                            + "'" + key + "'"
                            + ","
                            + "'" + Consts.BEIKE_CHANNEL_NATIVE_HANDLER + "'"
                            + ");"
                )
            }
        }
    }
}