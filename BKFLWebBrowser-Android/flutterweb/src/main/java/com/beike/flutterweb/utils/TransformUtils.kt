@file:Suppress("UNCHECKED_CAST")

package com.beike.flutterweb.utils

import android.annotation.TargetApi
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.util.Log
import android.util.SparseArray
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import org.json.JSONTokener
import kotlin.collections.ArrayList
import kotlin.collections.HashMap

object TransformUtils {
    private const val TAG = "TransformUtils"

    /**
     * 标准的只有Map List 基础类型
     * 参考类: StandardMessageCodec
     */
    fun standardMessageTransform(json: String?, type: String?): Any? {
        when (type) {
            "object" -> try {
                val jsonTokener = JSONTokener(json)
                val jsonObj = jsonTokener.nextValue()
                require(!jsonTokener.more()) { "Invalid JSON" }
                return transformSimpleObject(jsonObj)
            } catch (e: JSONException) {
                Log.e(TAG, "standardMessageTransform exception")
                e.printStackTrace()
            }
            "boolean" -> return java.lang.Boolean.parseBoolean(json)
            "number" ->         // int float double long byte...
                return json
            "string" -> return json
            else -> return null
        }
        return json
    }

    private fun transformSimpleObject(originObject: Any?): Any? {
        if (originObject is JSONObject) {
            val map: MutableMap<String, Any?> = HashMap()
            val iterable = originObject.keys()
            while (iterable.hasNext()) {
                val key = iterable.next()
                val o = originObject.opt(key)
                map[key] = transformSimpleObject(o)
            }
            return map
        } else if (originObject is JSONArray) {
            val ll: MutableList<Any?> = ArrayList()
            val length = originObject.length()
            for (i in 0 until length) {
                try {
                    ll.add(
                        transformSimpleObject(
                            originObject[i]
                        )
                    )
                } catch (e: JSONException) {
                    Log.e(TAG, "transformSimpleObject exception")
                    e.printStackTrace()
                }
            }
            return ll
        }
        return originObject
    }

    /**
     * 对应的JSONObject
     * 参考类: JSONMessageCodec
     * @param json
     * @param type
     * @return
     */
    fun jsonMessageTransform(json: String?, type: String?): Any? {
        return null
    }

    @TargetApi(21)
    fun map2Bundle(paramMap: Map<String?, Any?>?): Bundle {
        val bundle = Bundle()
        return if (paramMap != null && paramMap.isNotEmpty()) {
            val var2: Iterator<*> = paramMap.entries.iterator()
            while (var2.hasNext()) {
                val entry = var2.next() as Map.Entry<String, Any>
                val key = entry.key
                val value = entry.value
                if ("params".equals(key, ignoreCase = true)) {
                    Log.d("FlutterRunnerUtils", "map2Bundle params json : $value")
                    bundle.putAll(
                        map2Bundle(
                            json2Map(
                                value.toString()
                            )
                        )
                    )
                } else if (value is Bundle) {
                    bundle.putBundle(key, value)
                } else if (value is Byte) {
                    bundle.putByte(key, value)
                } else if (value is Short) {
                    bundle.putShort(key, value)
                } else if (value is Int) {
                    bundle.putInt(key, value)
                } else if (value is Long) {
                    bundle.putLong(key, value)
                } else if (value is Char) {
                    bundle.putChar(key, value)
                } else if (value is Boolean) {
                    bundle.putBoolean(key, value)
                } else if (value is Float) {
                    bundle.putFloat(key, value)
                } else if (value is Double) {
                    bundle.putDouble(key, value)
                } else if (value is String) {
                    bundle.putString(key, value)
                } else if (value is CharSequence) {
                    bundle.putCharSequence(key, value)
                } else if (value is ByteArray) {
                    bundle.putByteArray(key, value)
                } else if (value is ShortArray) {
                    bundle.putShortArray(key, value)
                } else if (value is IntArray) {
                    bundle.putIntArray(key, value)
                } else if (value is LongArray) {
                    bundle.putLongArray(key, value)
                } else if (value is CharArray) {
                    bundle.putCharArray(key, value)
                } else if (value is BooleanArray) {
                    bundle.putBooleanArray(key, value)
                } else if (value is FloatArray) {
                    bundle.putFloatArray(key, value)
                } else if (value is DoubleArray) {
                    bundle.putDoubleArray(key, value)
                } else if (value is Array<*>) {
                    if (value[0] is String) {
                        bundle.putStringArray(
                            key,
                            value as Array<String?>
                        )
                    } else if (value[0] is CharSequence) {
                        bundle.putCharSequenceArray(
                            key,
                            value as Array<CharSequence?>
                        )
                    }
                } else if (value is ArrayList<*>) {
                    if (value.isNotEmpty()) {
                        when (value[0]) {
                            is Int -> {
                                bundle.putIntegerArrayList(key, value as ArrayList<Int>)
                            }
                            is String -> {
                                bundle.putStringArrayList(key, value as ArrayList<String>)
                            }
                            is CharSequence -> {
                                bundle.putCharSequenceArrayList(
                                    key,
                                    value as ArrayList<CharSequence>
                                )
                            }
                            is Parcelable -> {
                                bundle.putParcelableArrayList(key, value as ArrayList<Parcelable>)
                            }
                            else -> {
                                Log.w("FlutterRunnerUtils", "Unknown object mType.")
                            }
                        }
                    }
                } else if (value is SparseArray<*>) {
                    bundle.putSparseParcelableArray(key, value as SparseArray<Parcelable>)
                } else if (value is Parcelable) {
                    bundle.putParcelable(key, value)
                } else {
                    Log.w("FlutterRunnerUtils", "Unknown object mType.")
                }
            }
            bundle
        } else {
            bundle
        }
    }

    fun bundle2Map(bundle: Bundle?): HashMap<String?, Any?> {
        val paramMap = hashMapOf<String?, Any?>()
        if (bundle != null) {
            val keySet = bundle.keySet()
            val var3: Iterator<*> = keySet.iterator()
            while (var3.hasNext()) {
                val key = var3.next() as String
                paramMap[key] = bundle[key]
            }
        }
        return paramMap
    }

    fun json2Map(json: String?): Map<String?, Any?> {
        if (json.isNullOrBlank()) {
            return hashMapOf()
        }
        val params = HashMap<String?, Any?>()
        try {
            val paramJson = JSONObject(json)
            val it: Iterator<*> = paramJson.keys()
            while (it.hasNext()) {
                val key = it.next().toString()
                params[key] = paramJson.opt(key)
            }
        } catch (var5: JSONException) {
            var5.printStackTrace()
        }
        return params
    }

    fun decodeUriQuery(query: String?): String {
        return Uri.decode(query)
    }
}