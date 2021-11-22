package com.beike.flutterweb.plugin.utils;


import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import java.util.Enumeration;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import static org.codehaus.groovy.runtime.DefaultGroovyMethods.println;

/**
 * 解压缩
 */
public class Decompression {
    private static final int BUFFER = 8192;

    /**
     * 解压缩jar
     *
     * @param jarFilePath jar源文件路径
     * @param tarDirPath  解压目标路径
     */
    public static void uncompress(String jarFilePath, String tarDirPath) {
        File jarFile = new File(jarFilePath);
        File tarDir = new File(tarDirPath);
        if (!jarFile.exists())
            throw new RuntimeException(jarFilePath + "does not exist!");
        try {
            JarFile jfInst = new JarFile(jarFile);
            Enumeration<JarEntry> enumEntry = jfInst.entries();
            while (enumEntry.hasMoreElements()) {
                JarEntry jarEntry = enumEntry.nextElement();
                File tarFile = new File(tarDir, jarEntry.getName());
                if (jarEntry.getName().contains("META-INF")) {
                    File miFile = new File(tarDir, "META-INF");
                    if (!miFile.exists()) {
                        miFile.mkdirs();
                    }

                }
                makeFile(jarEntry, tarFile);
                if (jarEntry.isDirectory()) {
                    continue;
                }
                FileChannel fileChannel = new FileOutputStream(tarFile).getChannel();
                InputStream ins = jfInst.getInputStream(jarEntry);
                transferStream(ins, fileChannel);
            }
        } catch (Throwable e) {
            println(" decompress error >>>" + e);
        }
    }

    private static void transferStream(InputStream ins, FileChannel channel) {
        ByteBuffer byteBuffer = ByteBuffer.allocate(BUFFER);
        ReadableByteChannel rbcInst = Channels.newChannel(ins);
        try {
            while (-1 != (rbcInst.read(byteBuffer))) {
                byteBuffer.flip();
                channel.write(byteBuffer);
                byteBuffer.clear();
            }
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } finally {
            if (null != rbcInst) {
                try {
                    rbcInst.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != channel) {
                try {
                    channel.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public static void makeFile(JarEntry jarEntry, File fileInst) {
        if (!fileInst.exists()) {
            if (jarEntry.isDirectory()) {
                fileInst.mkdirs();
            } else {
                try {
                    if (!fileInst.getParentFile().exists()) {
                        fileInst.getParentFile().mkdirs();
                    }
                    fileInst.createNewFile();
                } catch (IOException e) {
                    println(" create file error >>>".concat(fileInst.getPath()));
                }
            }
        }
    }

}