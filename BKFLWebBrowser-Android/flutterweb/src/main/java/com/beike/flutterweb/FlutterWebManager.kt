package com.beike.flutterweb

import android.app.Activity
import androidx.lifecycle.Lifecycle
import com.beike.flutterweb.utils.ReflectUtils
import io.flutter.embedding.engine.FlutterEngine

/**
 * FlutterWeb降级功能
 */
object FlutterWebManager {
    var mFlutterWebEngine = FlutterWebEngine()

    @JvmField
    var mFlutterUriRules: List<FlutterUriRule>? = null
    fun init(
        flutterUriRules: List<FlutterUriRule>
    ) {
        mFlutterUriRules = flutterUriRules
    }

    fun creatingFlutterEngineForWeb(): Boolean {
        return mFlutterWebEngine.creatingFlutterEngineForWeb()
    }

    class FlutterWebEngine {
        // 因为不同的Plugin里面的Channel使用的时候可能会需要初始化,所以后期会进行模拟初始化
        private var mFlutterEngineToFlutterWeb: FlutterEngine? = null
        private var creatingFlutterEngineForWeb = false
        fun creatingFlutterEngineForWeb(): Boolean {
            return creatingFlutterEngineForWeb
        }

        /**
         * 要避免Hook那边取到真正Flutter容器里面的Plugin, 进而对其修改影响原有Flutter,
         * 而等到Flutter web页面打开才初始化, 才放开Hook, 可以精确取得自己那套FlutterEngine的Plugin
         */
        fun attachToActivity(activity: Activity, lifecycle: Lifecycle) {
            try {
                if (mFlutterEngineToFlutterWeb == null) {
                    creatingFlutterEngineForWeb = true
                    mFlutterEngineToFlutterWeb = FlutterEngine(activity.applicationContext)
                    creatingFlutterEngineForWeb = false
                }
                // FlutterEnginePluginRegistry
                val pluginRegistry = mFlutterEngineToFlutterWeb!!.plugins
                val attachedActivity =
                    ReflectUtils.readField(pluginRegistry, "activity") as Activity?
                if (attachedActivity === activity) {
                    return
                }
                ReflectUtils.invokeMethod(
                    pluginRegistry, "attachToActivity", arrayOf(
                        Activity::class.java, Lifecycle::class.java
                    ), activity, lifecycle
                )
            } catch (t: Throwable) {
                t.printStackTrace()
            }
        }

        fun detachFromActivity() {
            try {
                val pluginRegistry = mFlutterEngineToFlutterWeb!!.plugins
                ReflectUtils.invokeMethod(pluginRegistry, "detachFromActivity", null)
            } catch (t: Throwable) {
                t.printStackTrace()
            }
        }
    }

    class FlutterUriRule
    /**
     * @param flutterNativeContainerRouterUri    flutter容器Router scheme  eg: "beike://flutter/beike/container"
     * @param flutterNativeContainerRouterUriFlutterKey flutter容器Router scheme中flutter url的参数key值  eg: "flutter_url"
     * @param flutterRouterScheme                flutter url的scheme eg: "beikeft"
     */(
        var flutterNativeContainerRouterUri: String,
        var flutterNativeContainerRouterUriFlutterKey: String,
        var flutterRouterScheme: String
    )
}