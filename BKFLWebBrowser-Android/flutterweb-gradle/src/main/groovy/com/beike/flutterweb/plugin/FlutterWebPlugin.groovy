package com.beike.flutterweb.plugin


import org.gradle.api.Plugin
import org.gradle.api.Project

class FlutterWebPlugin implements Plugin<Project> {
    public static final TAG = "FlutterWebPlugin"

    @Override
    void apply(Project project) {
        project.android.registerTransform(new FlutterWebJarTransform(project))
    }
}