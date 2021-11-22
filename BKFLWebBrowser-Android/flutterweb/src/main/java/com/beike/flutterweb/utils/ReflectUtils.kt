package com.beike.flutterweb.utils

import java.lang.reflect.AccessibleObject
import java.lang.reflect.Field
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method

object ReflectUtils {
    private fun getField(cls: Class<*>, fieldName: String?): Field? {
        var acls: Class<*>? = cls
        while (acls != null) {
            try {
                val field = acls.getDeclaredField(fieldName)
                setAccessible(field, true)
                return field
            } catch (ignore: NoSuchFieldException) { // NOPMD
            }
            acls = acls.superclass
        }
        var match: Field? = null
        for (class1 in cls.interfaces) {
            try {
                val test = class1.getField(fieldName)
                match = test
            } catch (ex: NoSuchFieldException) { // NOPMD
                // ignore
            }
        }
        return match
    }

    @Suppress("NULLABILITY_MISMATCH_BASED_ON_JAVA_ANNOTATIONS")
    fun getMethod(cls: Class<*>, methodName: String?, vararg parameterTypes: Class<*>?): Method? {
        var acls: Class<*>? = cls
        while (acls != null) {
            try {
                val method = acls.getDeclaredMethod(methodName, *parameterTypes)
                setAccessible(method, true)
                return method
            } catch (ignore: NoSuchMethodException) { // NOPMD
            }
            acls = acls.superclass
        }
        var match: Method? = null
        for (class1 in cls.interfaces) {
            try {
                val test = class1.getMethod(methodName, *parameterTypes)
                match = test
            } catch (ex: NoSuchMethodException) { // NOPMD
                // ignore
            }
        }
        return match
    }

    private fun setAccessible(ao: AccessibleObject, value: Boolean) {
        if (ao.isAccessible != value) {
            ao.isAccessible = value
        }
    }

    fun readField(obj: Any, field: String?): Any? {
        return try {
            val f = getField(obj.javaClass, field)
            f!![obj]
        } catch (t: Throwable) {
            null
        }
    }

    @Throws(
        NoSuchMethodException::class,
        IllegalAccessException::class,
        InvocationTargetException::class
    )
    fun invokeMethod(
        any: Any,
        methodName: String?,
        methodParamTypes: Array<Class<*>?>?,
        vararg args: Any?
    ): Any? {
        val clz: Class<*> = any.javaClass
        val m = if (methodParamTypes.isNullOrEmpty()) {
            getMethod(clz, methodName)
        } else {
            getMethod(clz, methodName, *methodParamTypes)
        }
        if (m != null) {
            m.isAccessible = true
            return m.invoke(any, *args)
        }
        return null
    }
}