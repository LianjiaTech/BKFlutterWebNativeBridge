package com.beike.flutterweb.utils

import kotlin.collections.HashMap

object UrlUtils {
    /**
     * 解析出url请求的路径
     * 会返回空字符串
     */
    fun getSchemePrefix(strURL: String?): String? {
        if (strURL == null || !strURL.contains("?")) {
            return strURL
        }
        val arrSplit = strURL.split("[?]".toRegex()).toTypedArray()
        return arrSplit[0]
    }

    /**
     * 解析出url参数中的键值对 如 "index.jsp?Action=del&id=123"，解析出Action:del,id:123存入map中
     *
     * @param URL url地址
     * @return url请求参数部分
     */
    fun getUrlParams(URL: String): HashMap<String, String> {
        val mapRequest = hashMapOf<String,String>()
        val strUrlParam = truncateUrlPage(URL) ?: return mapRequest
        return parseParams(strUrlParam)
    }

    /**
     * 解析出url参数中的键值对 如 "Action=del&id=123"，解析出Action:del,id:123存入map中
     *
     * @param strUrlParam url地址
     * @return url请求参数部分
     */
    private fun parseParams(strUrlParam: String?): HashMap<String, String> {
        val mapRequest= hashMapOf<String, String>()
        if (strUrlParam == null) {
            return mapRequest
        }
        val arrSplit = strUrlParam.split("[&]".toRegex()).toTypedArray()
        for (strSplit in arrSplit) {
            var arrSplitEqual: Array<String>?
            arrSplitEqual = strSplit.split("[=]".toRegex()).toTypedArray()
            // 解析出键值
            if (arrSplitEqual.size > 1) {
                // 正确解析
                mapRequest[arrSplitEqual[0]] = arrSplitEqual[1]
            } else {
                if (arrSplitEqual[0] !== "") {
                    // 只有参数没有值，不加入
                    mapRequest[arrSplitEqual[0]] = ""
                }
            }
        }
        return mapRequest
    }

    /**
     * 去掉url中的路径，留下请求参数部分
     *
     * @param strURL url地址
     * @return url请求参数部分
     */
    private fun truncateUrlPage(strURL: String?): String? {
        if (strURL.isNullOrBlank()) {
            return null
        }
        val url = strURL.trim { it <= ' ' }
        var strAllParam: String? = null
        val arrSplit: Array<String?> = url.split("[?]".toRegex()).toTypedArray()
        if (url.length > 1) {
            if (arrSplit.size > 1) {
                if (arrSplit[1] != null) {
                    strAllParam = arrSplit[1]
                }
            }
        }
        return strAllParam
    }

    /**
     * 给url增加参数
     */
    fun addUrlParams(url: String?, key: String, value: String): String {
        if (url.isNullOrBlank()) {
            return ""
        }
        val urlParams = getUrlParams(url)
        return if (urlParams.isEmpty()) {
            "$url?$key=$value"
        } else {
            "$url&$key=$value"
        }
    }

    fun appendQueryParameters(originalUrl: String?, queryParams: Map<String, String>?): String? {
        if (originalUrl == null || queryParams == null || queryParams.isEmpty()) {
            return originalUrl
        }
        var originalUrl2 = originalUrl
        val originalQueryParams = getUrlParams(originalUrl)
        var appendMark = if (originalQueryParams.isEmpty()) "?" else "&"
        for ((key, value) in queryParams) {
            if (!originalQueryParams.containsKey(key)) {
                originalUrl2 = "$originalUrl$appendMark$key=$value"
                appendMark = "&"
            }
        }
        return originalUrl2
    }
}