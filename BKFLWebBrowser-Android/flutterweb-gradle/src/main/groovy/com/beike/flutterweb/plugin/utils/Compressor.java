package com.beike.flutterweb.plugin.utils;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.zip.CRC32;
import java.util.zip.CheckedOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * 压缩
 */
public class Compressor {
    private static final int BUFFER = 8192;

    /**
     * 压缩文件
     * @param srcDirPath 源文件路径
     * @param tarJarPath 目标路径
     */
    public static void compress(String srcDirPath, String tarJarPath) {
        File fileName = new File(tarJarPath);
        File file = new File(srcDirPath);
        if (!file.exists())
            throw new RuntimeException(srcDirPath + "does not exist!");
        try {
            File[] sourceFiles = file.listFiles();
            if (sourceFiles != null && sourceFiles.length > 0) {
                FileOutputStream fileOutputStream = new FileOutputStream(fileName);
                CheckedOutputStream cos = new CheckedOutputStream(fileOutputStream,
                        new CRC32());
                ZipOutputStream out = new ZipOutputStream(cos);
                String basedir = "";
                for (int i = 0; i < sourceFiles.length; i++) {
                    compress(sourceFiles[i], out, basedir);
                }
                out.close();
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static void compress(File file, ZipOutputStream out, String basedir) {
        if (file.isDirectory()) {
            compressDirectory(file, out, basedir);
        } else {
            compressFile(file, out, basedir);
        }
    }

    private static void compressDirectory(File dir, ZipOutputStream out, String basedir) {
        if (!dir.exists())
            return;

        File[] files = dir.listFiles();
        for (int i = 0; i < files.length; i++) {
            compress(files[i], out, basedir + dir.getName() + "/");
        }
    }

    private static void compressFile(File file, ZipOutputStream out, String basedir) {
        if (!file.exists()) {
            return;
        }
        try {
            BufferedInputStream bis = new BufferedInputStream(
                    new FileInputStream(file));
            String filePath = basedir + file.getName();
            ZipEntry entry = new ZipEntry(filePath);
            out.putNextEntry(entry);
            int count;
            byte data[] = new byte[BUFFER];
            while ((count = bis.read(data, 0, BUFFER)) != -1) {
                out.write(data, 0, count);
            }
            bis.close();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
