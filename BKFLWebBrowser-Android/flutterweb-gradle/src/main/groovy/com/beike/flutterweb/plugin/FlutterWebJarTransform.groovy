package com.beike.flutterweb.plugin

import com.android.build.api.transform.*
import com.android.build.gradle.internal.pipeline.TransformManager
import com.android.utils.FileUtils
import org.gradle.api.Project

/**
 * 生成Dex之前对FlutterWeb的二进制文件二次处理
 */
class FlutterWebJarTransform extends Transform {

  private Project mProject

  FlutterWebJarTransform(Project project) {
    mProject = project
  }

  @Override
  String getName() {
    return "FlutterWebJarTransform"
  }
  /**
   * 输入文件的类型
   * 可供我们去处理的有两种类型, 分别是编译后的java代码, 以及资源文件(非res下文件, 而是assests内的资源)
   */
  @Override
  Set<QualifiedContent.ContentType> getInputTypes() {
    return TransformManager.CONTENT_CLASS
  }
  /**
   * 指定作用范围
   */
  @Override
  Set<? super QualifiedContent.Scope> getScopes() {
    return TransformManager.SCOPE_FULL_PROJECT
  }
  /**
   * 是否支持增量
   * 如果支持增量执行, 则变化输入内容可能包含 修改/删除/添加 文件的列表
   */
  @Override
  boolean isIncremental() {
    return false
  }
  /**
   * transform的执行主函数
   */
  @Override
  void transform(TransformInvocation transformInvocation) throws TransformException, InterruptedException, IOException {
    MyClassPool.resetClassPool(mProject, transformInvocation)

    println FlutterWebPlugin.TAG + "start inject"
    transformInvocation.inputs.each { input ->
      input.directoryInputs.each { directoryInput ->
        def dest = transformInvocation.outputProvider.getContentLocation(directoryInput.name, directoryInput.contentTypes, directoryInput.scopes, Format.DIRECTORY)
        FileUtils.copyDirectory(directoryInput.file, dest)
      }

      input.jarInputs.each { jarInput ->
        File file = InjectByJavassit.injectJar(jarInput, transformInvocation.context, mProject)
        if (file == null) {
          file = jarInput.file
        }
        File dest = transformInvocation.outputProvider.getContentLocation(jarInput.name, jarInput.contentTypes, jarInput.scopes, Format.JAR)
        FileUtils.copyFile(file, dest)
      }
    }
  }
}