package com.beike.flutterweb.plugin.utils;

import java.io.File;

public class StrongFileUtil {

    public static boolean deleteDirPath(String filepath) {
        File file = new File(filepath);
        if (!file.exists()) {
            return true;
        } else {
            return deleteDir(file);
        }

    }

    public static boolean deleteDir(File file) {
        if (!file.exists()) {
            return false;
        }
        if (file.isDirectory()) {
            File[] files = file.listFiles();
            for (File subFile : files) {
                boolean isSuccess = deleteDir(subFile);
                if (!isSuccess) {
                    return isSuccess;
                }
            }
        } else {
            boolean isSuccess = file.delete();
            if (!isSuccess) {
                return isSuccess;
            }
        }
        if (file.isDirectory()) {
            return file.delete();
        } else {
            return true;
        }
    }

}
