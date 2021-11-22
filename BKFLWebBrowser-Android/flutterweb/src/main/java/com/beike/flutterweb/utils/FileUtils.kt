package com.beike.flutterweb.utils

import android.content.Context
import java.io.BufferedReader
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader

object FileUtils {

    fun assetFile2Str(c: Context, urlStr: String?): String? {
        var input: InputStream? = null
        try {
            input = c.assets.open(urlStr!!)
            val bufferedReader = BufferedReader(InputStreamReader(input))
            var line: String?
            val sb = StringBuilder()
            do {
                line = bufferedReader.readLine()
                if (line != null && !line.matches(Regex("^\\s*\\/\\/.*"))) { // 去除注释
                    sb.append(line)
                }
            } while (line != null)
            bufferedReader.close()
            input.close()
            return sb.toString()
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            if (input != null) {
                try {
                    input.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
        }
        return null
    }
}