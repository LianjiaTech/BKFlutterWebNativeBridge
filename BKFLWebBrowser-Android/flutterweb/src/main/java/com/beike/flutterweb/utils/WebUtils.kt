package com.beike.flutterweb.utils

import android.webkit.WebView
import com.google.gson.Gson

object WebUtils {
    private const val TAG = "WebUtils"
    fun webViewLoadLocalJs(webView: WebView, jsName: String?) {
        val jsContent = FileUtils.assetFile2Str(webView.context, jsName)
        loadUrl(webView, jsContent)
    }

    fun notifyWebView(webView: WebView?, js: String?) {
        if (webView != null) {
            loadUrl(webView, js)
        }
    }

    private fun loadUrl(webView: WebView?, js: String?) {
        webView?.evaluateJavascript(js!!) { }
    }

    fun buildCallFunJSWithType(func: String, param: Any): String {
        val paramMap: MutableMap<String, Any> = HashMap()
        val type = getFlutterDynamicDataType(param)
        var p = param
        val gson=Gson()
        paramMap["type"] = type
        if (type == "map") {
            p = gson.toJson(param)
        }
        paramMap["obj"] = p
        return func + "(" + gson.toJson(paramMap) + ");"
    }

    private fun getFlutterDynamicDataType(o: Any?): String {
        if (o == null) {
            return "unknown"
        }
        if (o is String) {
            return "string"
        }
        if (o is Map<*, *>) {
            return "map"
        }
        return if (o is List<*> || o.javaClass.isArray) {
            "list"
        } else "unknown"
    }

    fun buildCallFunJS(`fun`: String, param: String): String {
        return "$`fun`($param);"
    }

    fun buildCallFunJS(`fun`: String, param1: String, param2: String): String {
        return "$`fun`($param1, $param2);"
    }

    private const val JS_TYPE_OBJECT = "object" //[JS]
    private const val JS_TYPE_FUNC = "function" //[JS]
    private const val JS_TYPE_SYMBOL = "symbol" //[JS]
    private const val JS_TYPE_NUMBER = "number" //[JS]
    private const val JS_TYPE_BIGINT = "bigint" //[JS]
    private const val JS_TYPE_BOOLEAN = "boolean" //[JS]
    private const val JS_TYPE_STRING = "string" //[JS]
    private const val JS_TYPE_UNDEFINED = "undefined" //[JS]
    private const val JS_TYPE_DATA = "data" //[Native]
    private const val JS_TYPE_IMAGE = "image" //[Native]
    fun transferJSType(o: Any?): String {
        return if (o is String) {
            JS_TYPE_STRING
        } else if (o is Boolean) {
            JS_TYPE_BOOLEAN
        } else if (o is Int || o is Float || o is Double) {
            JS_TYPE_NUMBER
        } else if (o == null) {
            JS_TYPE_UNDEFINED
        } else {
            JS_TYPE_OBJECT
        }
    }
}