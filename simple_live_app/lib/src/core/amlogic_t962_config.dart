import 'package:flutter/services.dart';

/// Amlogic T962 CPU 专项优化配置
/// 用于小米 4A 70 寸电视
class AmlogicT962Config {
  static const platform = MethodChannel('com.xycz.simple_live/amlogic');

  /// T962 支持的硬件解码格式
  static const supportedCodecs = {
    'h264': true,      // ✅ 完全支持
    'hevc': true,      // ✅ HEVC (H.265) 支持
    'vp9': false,      // ❌ 不支持
    'av1': false,      // ❌ 不支持
  };

  /// 初始化 Amlogic T962 解码器
  static Future<bool> initializeDecoder() async {
    try {
      final bool result = await platform.invokeMethod('initAmlogicDecoder');
      print('✅ Amlogic T962 解码器已初始化');
      return result;
    } catch (e) {
      print('❌ 初始化失败: $e');
      return false;
    }
  }

  /// 获取最优播放器配置
  static Map<String, dynamic> getOptimalPlayerConfig() {
    return {
      // 仅使用 T962 支持的编码格式
      'preferred_codecs': ['h264', 'hevc'],
      
      // 视频参数优化
      'video': {
        'codec': 'h264',  // 首选 H.264（T962 最优）
        'fps': 30,        // 限制 30fps
        'max_resolution': '1920x1080',  // 4K (小米 4A 实际输出 1080p)
        'profile': 'main',  // 主档案
        'level': '4.1',   // Level 4.1
      },

      // 音频参数
      'audio': {
        'codec': 'aac',   // AAC 编码
        'bitrate': 128,   // 128kbps
        'sample_rate': 48000,  // 48kHz
      },

      // 缓冲优化（T962 内存有限）
      'buffer': {
        'min_buffer_ms': 1500,      // 最小缓冲
        'max_buffer_ms': 6000,      // 最大缓冲（限制内存）
        'buffer_for_playback_ms': 2000,
        'buffer_for_rebuffer_ms': 4000,
      },

      // 掉帧策略
      'frame_drop': {
        'enabled': true,
        'max_drop_frames': 3,  // T962 掉帧阈值
      },

      // 硬件加速
      'hardware': {
        'enable_mediacodec': true,  // 启用 MediaCodec
        'enable_hw_render': true,   // 硬件渲染
      },

      // T962 特定优化
      't962_specific': {
        'limit_concurrent_decoding': 1,  // 只允许 1 个并发解码
        'enable_power_saving': true,     // 省电模式
        'adjust_clock_frequency': true,  // 动态调整 CPU 频率
      },
    };
  }

  /// 获取 T962 设备信息
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = 
          await platform.invokeMethod('getT962DeviceInfo');
      return {
        'cpu_model': result['cpu_model'] ?? 'Amlogic T962',
        'cpu_frequency': result['cpu_frequency'] ?? '2.0 GHz',
        'ram_available': result['ram_available'] ?? 'Unknown',
        'gpu_model': result['gpu_model'] ?? 'Mali-G31',
        'max_video_resolution': result['max_video_resolution'] ?? '4K',
        'hardware_decoder_available': result['hw_decoder'] ?? true,
      };
    } catch (e) {
      print('获取设备信息失败: $e');
      return {};
    }
  }

  /// 针对 T962 的内存优化
  static Future<void> optimizeMemoryForT962() async {
    try {
      await platform.invokeMethod('optimizeMemoryT962');
      print('✅ T962 内存优化已应用');
    } catch (e) {
      print('❌ 内存优化失败: $e');
    }
  }
}
