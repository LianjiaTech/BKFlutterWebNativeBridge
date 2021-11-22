package com.beike.flutterweb.plugin

import com.android.build.api.transform.DirectoryInput
import com.android.build.api.transform.JarInput
import com.android.build.api.transform.TransformInput
import com.android.build.api.transform.TransformInvocation
import javassist.ClassPool
import org.gradle.api.Project

class MyClassPool {

  private static ClassPool sClassPool

  static ClassPool getClassPool() {
    return sClassPool
  }

  static void resetClassPool(Project project, TransformInvocation transformInvocation) {

    // ClassPool.getDefault() 有可能被其他使用 Javassist 的插件污染（如 nuwa），
    // 导致ClassPool中出现重复的类，Javassist抛出异常，所以不能使用默认的
    sClassPool = new ClassPool()

    for (TransformInput input : transformInvocation.getInputs()) {
      for (JarInput jarInput : input.getJarInputs()) {
        sClassPool.appendClassPath(jarInput.file.getAbsolutePath())
      }
      for (DirectoryInput directoryInput : input.getDirectoryInputs()) {
        sClassPool.appendClassPath(directoryInput.file.getAbsolutePath())
      }
    }
  }
}
