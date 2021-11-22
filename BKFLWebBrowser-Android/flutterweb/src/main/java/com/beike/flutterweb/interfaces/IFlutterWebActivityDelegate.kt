package com.beike.flutterweb.interfaces

import android.app.Activity
import com.beike.flutterweb.FlutterWebChannelManager
import com.beike.flutterweb.web.FWWebView


interface IFlutterWebActivityDelegate {
    companion object{
        var RESULT_KEY = "_flutter_result_"
        var REQUEST_CODE = "_requestCode_"
        var RESULT_CODE = "_resultCode_"
        var RESULT_DATA = "_resultData_"
        var RESULT_STATE = "Activity.RESULT"
        var RESULT_STATE_OK = "RESULT_OK"
        var RESULT_STATE_CANCEL = "RESULT_CANCEL"
    }

    fun uniqueId(): String?

    fun getContainerActivity(): Activity?

    fun getFWWebView(): FWWebView

    fun getFlutterWebChannelManager(): FlutterWebChannelManager

    fun finishContainer(result: Map<String, Any>?)

    fun initialRoute(): String

    fun invokeChannelWithParams(method: String?)

    fun isUserVisible(): Boolean

    fun getRequestCodeAndCallBack(): HashMap<Int, String>
}