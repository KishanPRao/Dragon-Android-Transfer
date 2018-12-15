package com.kishanprao.datHelper.base

import java.io.File

class Utils {
    companion object {

        private fun getFilesInDirRecursively(directoryWithPath: String): Pair<ArrayList<String>, Long> {
            var totalSize: Long = 0
            val files = ArrayList<String>()
            for (file in File(directoryWithPath).listFiles()) {
                if (file.isDirectory) {
                    val (f, size) = getFilesInDirRecursively(file.path)
                    files.addAll(f)
                    totalSize += size
                } else {
                    files.add(file.path)
                    totalSize += file.length()
                }
            }
            return Pair(files, totalSize)
        }

        fun getFilesInDirectory(directoryWithPath: String): Pair<ArrayList<String>, Long> {
            val (files, totalSize) = getFilesInDirRecursively(directoryWithPath)
            for (i in 0 until files.count()) {
                val dirPath = File(directoryWithPath).path
                files[i] = files[i].replace("$dirPath/", "")
            }
            return Pair(files, totalSize)
        }
    }
}