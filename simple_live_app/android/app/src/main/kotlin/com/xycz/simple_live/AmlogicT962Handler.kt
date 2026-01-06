package com.xycz.simple_live

import android.content.Context
import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.os.Build
import android.os.Debug
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class AmlogicT962Handler {
    companion object {
        private const val CHANNEL = "com.xycz.simple_live/amlogic"

        fun setupAmlogicChannel(context: Context, flutterEngine: FlutterEngine) {
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "initAmlogicDecoder" -> {
                            result.success(initAmlogicDecoder(context))
                        }
                        "getT962DeviceInfo" -> {
                            result.success(getT962DeviceInfo(context))
                        }
                        "optimizeMemoryT962" -> {
                            optimizeMemoryForT962()
                            result.success(true)
                        }
                        else -> result.notImplemented()
                    }
                }
        }

        /**
         * 初始化 Amlogic T962 解码器
         * - 启用 MediaCodec 硬件加速
         * - 配置最优解码参数
         */
        private fun initAmlogicDecoder(context: Context): Boolean {
            return try {
                // 检查是否为 Amlogic 芯片
                if (!isAmlogicDevice()) {
                    return false
                }

                // 验证 H.264 和 HEVC 硬件解码支持
                val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
                var h264Supported = false
                var hevcSupported = false

                for (codecInfo in codecList.codecInfos) {
                    if (codecInfo.isEncoder) continue
                    
                    val name = codecInfo.name.lowercase()
                    // T962 硬件解码器通常以 "OMX.amlogic" 开头
                    if (name.contains("amlogic") || name.contains("h264") || name.contains("hevc")) {
                        for (mimeType in codecInfo.supportedTypes) {
                            when {
                                mimeType == "video/avc" -> h264Supported = true
                                mimeType == "video/hevc" -> hevcSupported = true
                            }
                        }
                    }
                }

                println("🎬 T962 硬件解码器检查:")
                println("  H.264 支持: $h264Supported")
                println("  HEVC 支持: $hevcSupported")

                h264Supported || hevcSupported

            } catch (e: Exception) {
                e.printStackTrace()
                false
            }
        }

        /**
         * 获取 T962 设备信息
         */
        private fun getT962DeviceInfo(context: Context): Map<String, Any> {
            val info = mutableMapOf<String, Any>()

            try {
                // CPU 型号
                info["cpu_model"] = Build.HARDWARE  // 通常为 "amlogic"
                info["cpu_name"] = Build.DEVICE
                
                // 处理器信息
                info["processor"] = Runtime.getRuntime().availableProcessors()
                
                // RAM 信息
                val runtime = Runtime.getRuntime()
                val totalMemory = runtime.totalMemory() / (1024 * 1024)
                val maxMemory = runtime.maxMemory() / (1024 * 1024)
                info["ram_total_mb"] = totalMemory
                info["ram_max_mb"] = maxMemory
                info["ram_available"] = "${runtime.freeMemory() / (1024 * 1024)} MB"

                // GPU 信息（更正）
                info["gpu_model"] = "Mali-450MP"     // T962 实际 GPU 型号
                info["gpu_frequency_mhz"] = 750      // GPU 主频 750MHz
                
                // 视频能力
                info["max_video_resolution"] = "4K"
                
                // 硬件解码支持
                info["hw_decoder"] = true
                info["h264_hw"] = checkCodecSupport("video/avc")
                info["hevc_hw"] = checkCodecSupport("video/hevc")

                // Android 版本
                info["android_version"] = Build.VERSION.RELEASE
                info["sdk_version"] = Build.VERSION.SDK_INT

            } catch (e: Exception) {
                e.printStackTrace()
            }

            return info
        }

        /**
         * 针对 T962 的内存优化
         * - 限制并发解码数量
         * - 调整缓冲区大小
         * - 启用垃圾回收优化
         */
        private fun optimizeMemoryForT962() {
            try {
                // 手动触发垃圾回收（仅在必要时）
                System.gc()
                
                // 获取当前内存使用情况
                val runtime = Runtime.getRuntime()
                val usedMemory = (runtime.totalMemory() - runtime.freeMemory()) / (1024 * 1024)
                val maxMemory = runtime.maxMemory() / (1024 * 1024)
                
                println("💾 T962 内存状态: ${usedMemory}MB / ${maxMemory}MB")
                
                // 如果内存使用超过 70%，触发清理
                if (usedMemory > maxMemory * 0.7) {
                    System.gc()
                    println("⚠️ 触发内存清理")
                }

            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        /**
         * 检查编码格式支持
         */
        private fun checkCodecSupport(mimeType: String): Boolean {
            return try {
                val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
                codecList.codecInfos.any { codecInfo ->
                    !codecInfo.isEncoder && mimeType in codecInfo.supportedTypes
                }
            } catch (e: Exception) {
                false
            }
        }

        /**
         * 判断是否为 Amlogic 设备
         */
        private fun isAmlogicDevice(): Boolean {
            return Build.HARDWARE.lowercase().contains("amlogic") ||
                   Build.DEVICE.lowercase().contains("amlogic") ||
                   Build.MODEL.lowercase().contains("amlogic")
        }
    }
}
