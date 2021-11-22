package com.beike.flutterweb.hook

import android.text.TextUtils
import android.util.Log
import androidx.annotation.Keep
import com.beike.flutterweb.Consts
import com.beike.flutterweb.FlutterWebChannelManager
import com.beike.flutterweb.FlutterWebManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodCodec

@Keep
open class HookChannel {
    companion object {
        private const val TAG = "HookChannel"

        /**
         * FlutterWebPlugin hook
         * @param name
         * @param messenger
         * @param codec
         * @param handler
         */
        @Keep
        fun methodChannelSetMethodCallHandlerHook(
            name: String,
            messenger: BinaryMessenger?,
            codec: MethodCodec?,
            handler: MethodChannel.MethodCallHandler?
        ) {
            if (TextUtils.isEmpty(name)) {
                return
            }
            try {
                if (!FlutterWebManager.creatingFlutterEngineForWeb()) {
                    return
                }
                if (name.contains("/") || name.startsWith(Consts.BEIKE_METHOD_CHANNEL)) {
                    return
                }
                val newMethodChannel = FlutterWebChannelManager.putNativeMethodChannel(name, messenger, codec)
                newMethodChannel?.setMethodCallHandler(handler)
                Log.d(
                    TAG,
                    String.format("Native set MethodCallHandler success, Channel: %s", name)
                )
            } catch (ignore: Throwable) {
            }
        }
    }
}