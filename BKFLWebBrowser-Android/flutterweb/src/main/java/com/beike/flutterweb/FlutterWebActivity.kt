package com.beike.flutterweb

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Bundle
import android.os.SystemClock
import android.util.Log
import android.view.ViewGroup
import android.webkit.*
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import com.beike.flutterweb.interfaces.IFlutterWebActivityDelegate
import com.beike.flutterweb.interfaces.IFlutterWebJsBridgeCallBack
import com.beike.flutterweb.utils.TransformUtils
import com.beike.flutterweb.utils.WebUtils
import com.beike.flutterweb.web.FWJsBridge
import com.beike.flutterweb.web.FWWebView
import com.google.gson.Gson

import io.flutter.plugin.common.MethodChannel
import kotlin.collections.HashMap

/**
 * FlutterWeb通用容器
 * 可以集成Router，提升调用时的灵活性
 */
class FlutterWebActivity : AppCompatActivity(), IFlutterWebActivityDelegate {
    private lateinit var mFWWebView: FWWebView
    private val mUniqueId = genUniqueId()
    private var mUrl: String? = ""
    private var mInitialRoute = "/"
    private val mFlutterWebChannelManager = FlutterWebChannelManager()

    // 存储跳转时RequestCode和回来后回调到Web的CallBack方法
    private val mRequestCodeAndCallBack = hashMapOf<Int,String>()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val rootView = findViewById<ViewGroup>(android.R.id.content)
        val bundle=intent.extras
        if (bundle==null){
            return
        }
        mUrl = bundle.getString("flutter_url")
        if (mUrl.isNullOrEmpty()) {
            return
        }
        mInitialRoute = parseExtras()
        mFWWebView = FWWebView(this)
        mFWWebView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        rootView.addView(mFWWebView)
        setUpWebView()
        addJsBridge()
        loadUrl(mUrl!!)
    }

    override fun onStart() {
        super.onStart()
        FlutterWebManager.mFlutterWebEngine.attachToActivity(this, lifecycle)
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun setUpWebView() {
        // 基类只设置通用的
        mFWWebView.isVerticalScrollBarEnabled = true
        mFWWebView.isHorizontalScrollBarEnabled = false
        mFWWebView.scrollBarStyle = WebView.SCROLLBARS_OUTSIDE_OVERLAY
        mFWWebView.webViewClient = initWebViewClient()
        mFWWebView.webChromeClient = initWebChromeClient()
        val settings = mFWWebView.settings

        // 开启 DOM storage API 功能
        settings.domStorageEnabled = true
        // 支持js
        settings.javaScriptEnabled = true

        // TODO note 这块有安全隐患
        // 阻止 file scheme URL 的访问
        settings.allowFileAccess = true
        settings.allowFileAccessFromFileURLs = true
        settings.allowUniversalAccessFromFileURLs = true

        // 设置可以支持缩放
        settings.setSupportZoom(false)
        // 设置出现缩放工具
        settings.builtInZoomControls = false
        // 扩大比例的缩放
        settings.useWideViewPort = true
        // 自适应屏幕
        settings.layoutAlgorithm = WebSettings.LayoutAlgorithm.SINGLE_COLUMN
        // 可任意比例缩放
        settings.useWideViewPort = true
        // 缩放至屏幕的大小
        settings.loadWithOverviewMode = true
        settings.loadsImagesAutomatically = true
            //在安卓5.0之后，默认不允许加载http与https混合内容，需要设置webView允许其加载混合网络协议内容
            settings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            //设置运行跨域读取cookie
            CookieManager.getInstance().setAcceptThirdPartyCookies(mFWWebView, true)
    }

    private fun initWebChromeClient(): WebChromeClient {
        return object : WebChromeClient() {
            // 处理进度
            override fun onProgressChanged(view: WebView, newProgress: Int) {
                //为什么要在这里注入JS
                //1 OnPageStarted中注入有可能全局注入不成功，导致页面脚本上所有接口任何时候都不可用
                //2 OnPageFinished中注入，虽然最后都会全局注入成功，但是完成时间有可能太晚，当页面在初始化调用接口函数时会等待时间过长
                //3 在进度变化时注入，刚好可以在上面两个问题中得到一个折中处理
                //为什么是进度大于25%才进行注入，因为从测试看来只有进度大于这个数字页面才真正得到框架刷新加载，保证100%注入成功
                super.onProgressChanged(view, newProgress)
            }

            override fun onJsAlert(
                view: WebView,
                url: String,
                message: String,
                result: JsResult
            ): Boolean {
                return super.onJsAlert(view, url, message, result)
            }

            override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
                return super.onConsoleMessage(consoleMessage)
            }
        }
    }

    private fun initWebViewClient(): WebViewClient {
        return object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                return super.shouldOverrideUrlLoading(view, url)
            }

            /**
             * 通知主程序页面当前开始加载。该方法只有在加载 main frame 时加载一次，
             * 如果一个页面有多个frame，onPageStarted只在加载 main frame 时调用一次。
             * 也意味着若内置frame发生变化，onPageStarted不会被调用。
             */
            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {}
            override fun onPageFinished(view: WebView?, url: String?) {
                loadLocalJS()
            }

            override fun onReceivedError(
                view: WebView?, errorCode: Int, description: String?,
                failingUrl: String?
            ) {
                Log.e(TAG, "onReceivedError:$failingUrl")
            }

            /**
             * 当出现SSL错误时，WebView默认是取消加载当前页面，只有去掉onReceivedSslError的默认操作，
             * 然后添加SslErrorHandler.proceed()才能继续加载出错页面
             * 当HTTPS传输出现SSL错误时，错误会只通过onReceivedSslError回调传过来
             */
            override fun onReceivedSslError(
                view: WebView?,
                handler: SslErrorHandler?,
                error: SslError?
            ) {
                Log.e(TAG, "onReceivedSslError:" + error?.url)
                if (error?.primaryError == SslError.SSL_INVALID) {
                    handler?.proceed()
                } else if (view?.url == null || view.url == error?.url) {
                    super.onReceivedSslError(view, handler, error)
                }
            }
        }
    }

    private fun addJsBridge() {
        mFWWebView.addJavascriptInterface(
            FWJsBridge(this,
                object : IFlutterWebJsBridgeCallBack {
                    override fun onFlutterRunnerReady() {
                        invokeChannelWithParams("onResume")
                    }
                }),
            FWJsBridge.JS_BRIDGE_NAME
        )
    }

    private fun loadLocalJS() {
        //loadLocalJSFile();
        FlutterWebChannelManager.attachNativeMethodChannel(mFWWebView)
    }

    /**
     * TODO 本地注入文件总是找不到好的时机,因为这些js需要最早加载,后续需要进一步看看怎么才能成功加载到所有js前面
     */
    private fun loadLocalJSFile() {
        WebUtils.webViewLoadLocalJs(
            mFWWebView,
            "web/flutter_channel_js/Foundation/foundation_stringify.js"
        )
        WebUtils.webViewLoadLocalJs(mFWWebView, "web/flutter_channel_js/Bridge/bridge_webkit.js")
        WebUtils.webViewLoadLocalJs(
            mFWWebView,
            "web/flutter_channel_js/Flutter/Channel/Android/flutter_channel_specific.js"
        )
        WebUtils. webViewLoadLocalJs(
            mFWWebView,
            "web/flutter_channel_js/Flutter/Channel/Android/flutter_message_channel_specific.js"
        )
        WebUtils.webViewLoadLocalJs(
            mFWWebView,
            "web/flutter_channel_js/Flutter/Channel/Android/flutter_method_channel_specific.js"
        )
        WebUtils.webViewLoadLocalJs(
            mFWWebView,
            "web/flutter_channel_js/Flutter/Context/flutter_context.js"
        )
        WebUtils.webViewLoadLocalJs(mFWWebView, "web/flutter_channel_js/Hook/Log/hook_log.js")
        //WebUtils.webViewLoadLocalJs(mWebView, "flutter_channel_js/Hook/Ajax/proxy_ajax.js");
    }

    private fun loadUrl(url: String) {
        try {
            mFWWebView.loadUrl(url)
        } catch (e: Throwable) {
            Log.e(TAG, "WebView load errorMsg: " + e.message)
        }
    }

    @TargetApi(21)
    private fun parseExtras(): String {
        return if (this.intent.hasExtra("initial_route")) {
            initialRouteIntent
        } else {
            val builder = StringBuilder()
            val bundle = this.intent.extras
            if (bundle != null) {
                Log.d("RunnerFlutterActivity", "parseExtras key: " + bundle.size())
                val queryKeys = bundle.keySet()
                val var4: Iterator<*> = queryKeys.iterator()
                while (var4.hasNext()) {
                    var key = var4.next() as String
                    val value = bundle[key] as String?
                    if (Consts.FLUTTER_WEB_CONTAINER_PATH_KEY == key) {
                        key = FLUTTER_URL_KEY
                    }
                    builder.append(key).append("=").append(value)
                    builder.append("&")
                }
                builder.deleteCharAt(builder.lastIndexOf("&"))
            }
            builder.toString()
        }
    }

    private val initialRouteIntent: String
        get() = if (this.intent.hasExtra("route")) {
            this.intent.getStringExtra("route") ?: "/"
        } else {
            try {
                val activityInfo = this.packageManager.getActivityInfo(
                    this.componentName,
                    PackageManager.GET_META_DATA
                )
                val metadata = activityInfo.metaData
                val desiredInitialRoute = metadata?.getString("io.flutter.InitialRoute")
                desiredInitialRoute ?: "/"
            } catch (var4: PackageManager.NameNotFoundException) {
                "/"
            }
        }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.i("RunnerFlutterActivity", "== onNewIntent ==$mUniqueId")
    }

    override fun onBackPressed() {
        invokeChannelWithParams("onBackPressed")
    }

    override fun onPause() {
        super.onPause()
        invokeChannelWithParams("onPause")
    }

    override fun onDestroy() {
        FlutterWebManager.mFlutterWebEngine.detachFromActivity()
        super.onDestroy()
        invokeChannelWithParams("onDestroy")
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // 兼容旧模式
        onContainerResult(requestCode, resultCode, data)
        // 新模式
        if (mRequestCodeAndCallBack.containsKey(requestCode)) {
            var containerResult = hashMapOf<String?, Any?>()
            if (data != null) {
                containerResult = TransformUtils.bundle2Map(data.extras)
            }
            containerResult[IFlutterWebActivityDelegate.REQUEST_CODE] = requestCode
            containerResult[IFlutterWebActivityDelegate.RESULT_CODE] = resultCode
            WebUtils.notifyWebView(
                mFWWebView,WebUtils. buildCallFunJS(
                    mRequestCodeAndCallBack.remove(requestCode)!!,
                    Gson().toJson(containerResult)
                )
            )
        }
    }

    override fun uniqueId(): String {
        return mUniqueId
    }

    override fun initialRoute(): String {
        return mInitialRoute
    }

    override fun getContainerActivity(): Activity {
        return this
    }

    override fun getFWWebView(): FWWebView {
        return mFWWebView
    }

    override fun getFlutterWebChannelManager(): FlutterWebChannelManager {
        return mFlutterWebChannelManager
    }

    val containerFragment: Fragment?
        get() = null

    override fun finishContainer(result: Map<String, Any>?) {
        if (result.isNullOrEmpty()) {
            finish()
        }
        val map = hashMapOf<String?, Any?>()
        map.putAll(result!!)
        setFlutterPageResult(this, map)
        finish()
    }

    private fun onContainerResult(requestCode: Int, resultCode: Int, data: Intent?) {
        val result = hashMapOf<String?, Any?>()
        result[IFlutterWebActivityDelegate.REQUEST_CODE] = requestCode
        result[IFlutterWebActivityDelegate.RESULT_CODE] = resultCode
        if (data != null) {
            val rlt = data.getSerializableExtra(IFlutterWebActivityDelegate.RESULT_KEY)
            if (rlt is Map<*, *>) {
                result[IFlutterWebActivityDelegate.RESULT_DATA] = rlt
            }
        }
        invokeRunnerChannelWithParams("onActivityResult", result, null)
    }

    private fun setFlutterPageResult(activity: Activity?, result: HashMap<String?, Any?>?) {
        val intent = Intent()
        var resultState = IFlutterWebActivityDelegate.RESULT_STATE_OK
        if (result != null) {
            resultState = result.remove(IFlutterWebActivityDelegate.RESULT_STATE).toString()
            val bundle = TransformUtils.map2Bundle(result)
            // 新方式
            intent.putExtras(bundle)
            // 这个兼容老方式，存了2份
            intent.putExtra(IFlutterWebActivityDelegate.RESULT_KEY, result)
        }
        if (IFlutterWebActivityDelegate.RESULT_STATE_CANCEL.equals(
                resultState,
                ignoreCase = true
            )
        ) {
            this.setResult(RESULT_CANCELED, intent)
        } else {
            this.setResult(RESULT_OK, intent)
        }
    }

    override fun invokeChannelWithParams(method: String?) {
        Log.d("RunnerFlutterActivity", "registerHandler=>bridgeHandlerName:$method")
        val args = hashMapOf<String, Any?>()
        args["initialRoute"] = initialRoute()
        args["uniqueId"] = mUniqueId
        Log.d("RunnerFlutterActivity", "invokeChannelWithParams: $method")
        invokeRunnerChannelWithParams(method, args, null)
    }

    private fun invokeRunnerChannelWithParams(
        method: String?,
        args: Map<*, *>,
        result: MethodChannel.Result?
    ) {
        mFlutterWebChannelManager.nativeInvokeFlutterMethod(
            mFWWebView,
            "flutter_runner",
            method,
            args,
            result
        )
    }

    override fun isUserVisible(): Boolean {
        return false
    }

    override fun getRequestCodeAndCallBack(): HashMap<Int, String> {
        return mRequestCodeAndCallBack
    }

    companion object {
        private const val TAG = "FlutterWebActivity"
        private const val FLUTTER_URL_KEY = "flutter_url"
        fun genUniqueId(): String {
            return String.format("uniqueId-%s", SystemClock.uptimeMillis())
        }
    }
}