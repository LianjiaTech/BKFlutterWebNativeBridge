package com.beike.flutterweb.plugin

import com.android.build.api.transform.Context
import com.android.build.api.transform.JarInput
import com.beike.flutterweb.plugin.utils.Compressor
import com.beike.flutterweb.plugin.utils.Decompression
import com.beike.flutterweb.plugin.utils.StrongFileUtil
import javassist.ClassPool
import javassist.CtClass
import javassist.CtMethod
import javassist.NotFoundException
import org.gradle.api.Project

import static groovy.io.FileType.FILES

class InjectByJavassit {
    static File injectJar(JarInput jarInput, Context context, Project project) throws NotFoundException {
        File jarFile = jarInput.file
        // SB 贝壳里面有个plugin竟然把所有jar都给合并了 不得不全部解压缩
//        if (!jarInput.name.contains("flutter")) {
//            return null
//        }
        String srcPath = jarFile.getAbsolutePath()
        String tmpDirName = jarFile.name.substring(0, jarFile.name.length() - 4)
        String tmpDirPath = context.temporaryDir.getAbsolutePath() + File.separator + tmpDirName
        String targetPath = context.temporaryDir.getAbsolutePath() + File.separator + jarFile.name
        Decompression.uncompress(srcPath, tmpDirPath)
        doInjectJar(tmpDirPath)
        Compressor.compress(tmpDirPath, targetPath)
        StrongFileUtil.deleteDirPath(tmpDirPath)
        File targetFile = new File(targetPath)
        if (targetFile.exists()) {
            return targetFile
        }
        return null
    }
/**
 * 二次处理解压后文件
 */
    private static void doInjectJar(String dirPath) {
        File dir = new File(dirPath)
        if (dir.isDirectory()) {
            dir.eachFileRecurse(FILES) { File file ->
                if (!file.path.contains("io/flutter/")) {
                    return
                }
                if (file.path.endsWith("io/flutter/plugin/common/MethodChannel.class")) {
                    String cls = new File(dirPath).relativePath(file).replace('/', '.')
                    cls = cls.substring(0, cls.lastIndexOf('.class'))
                    ClassPool pool = MyClassPool.getClassPool()
                    CtClass ctClass = pool.getCtClass(cls)
                    if (ctClass.isFrozen()) {
                        ctClass.defrost()
                    }
                    CtMethod ctMethod = ctClass.getDeclaredMethod('setMethodCallHandler')
                    String hookStr = 'com.beike.flutterweb.hook.HookChannel.Companion.methodChannelSetMethodCallHandlerHook(name, messenger, codec, handler);'
                    ctMethod.insertBefore(hookStr)
                    ctClass.writeFile(dirPath)
                    ctClass.detach()
                    println FlutterWebPlugin.TAG + " inject flutter.jar class: MethodChannel  method: setMethodCallHandler insertBefore com.beike.flutterweb.hook.HookChannel.methodChannelSetMethodCallHandlerHook"
                }
            }
        }
    }
}