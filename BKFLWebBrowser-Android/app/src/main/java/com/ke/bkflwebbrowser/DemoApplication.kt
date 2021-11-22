package com.ke.bkflwebbrowser

import android.app.ActivityManager
import android.app.Application
import android.os.Process
import android.webkit.WebView
import com.beike.flutterweb.FlutterWebManager


class DemoApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        if (isMainProcess) {
            val flutterUriRules: MutableList<FlutterWebManager.FlutterUriRule> = mutableListOf()
            flutterUriRules.add(
                FlutterWebManager.FlutterUriRule(
                    "beike://flutter/beike/container",
                    "flutter_url",
                    "beikeft"
                )
            )
            FlutterWebManager.init(flutterUriRules)
            WebView.setWebContentsDebuggingEnabled(true)
        }
    }

    private val isMainProcess: Boolean
        get() {
            val pid = Process.myPid()
            val activityManager = getSystemService(ACTIVITY_SERVICE) as ActivityManager
            for (appProcess in activityManager.runningAppProcesses) {
                if (appProcess.pid == pid) {
                    return applicationInfo.packageName == appProcess.processName
                }
            }
            return false
        }
}