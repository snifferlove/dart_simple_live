import 'package:logger/logger.dart';
import 'buffer_strategy.dart';

/// Mali-450MP 播放器专项优化
class PlayerOptimizer {
  static final Logger _logger = Logger();

  /// Mali-450MP 专用播放器配置
  static Map<String, dynamic> getMali450OptimizedConfig({
    NetworkQuality quality = NetworkQuality.fair,
  }) {
    final bufferConfig = BufferStrategy.getAdaptiveConfig(quality);
    
    return {
      // ========== 视频配置 ==========
      'video': {
        // 编码格式：优先级 H.264 > HEVC > VP9
        'preferred_codecs': ['h264', 'hevc'],
        'fallback_codec': 'h264',

        // 帧率限制：30fps（不超过电视刷新率）
        'max_fps': 30,
        'adaptive_fps': true,
        'min_fps': 15,

        // 分辨率自适应
        'max_resolution': '1920x1080',  // 4K 但电视输出 1080p
        'min_resolution': '640x360',     // 最低 360p
        'adaptive_resolution': true,

        // H.264 特定优化
        'h264_profile': 'main',
        'h264_level': '4.1',

        // Mali-450MP 渲染优化
        'gpu_rendering': true,
        'render_scaling': 'fit',  // 适配屏幕
      },

      // ========== 音频配置 ==========
      'audio': {
        'codec': 'aac',
        'bitrate': 128,      // kbps
        'sample_rate': 48000, // Hz
        'channels': 2,        // 立体声
      },

      // ========== 缓冲配置 ==========
      'buffer': bufferConfig,

      // ========== 掉帧策略 ==========
      'frame_dropping': {
        'enabled': true,
        'max_drop_frames': BufferStrategy.getFrameDropThreshold(quality),
        'aggressive_mode': quality == NetworkQuality.poor,
      },

      // ========== 硬件加速 ==========
      'hardware': {
        'enable_mediacodec': true,      // MediaCodec 硬件解码
        'enable_mediacodec_async': true, // 异步解码
        'enable_hw_render': true,        // 硬件渲染
        'enable_frame_sync': true,       // 帧同步
      },

      // ========== 性能优化 ==========
      'performance': {
        'limit_concurrent_decoding': 1,  // 限制为 1 个并发解码
        'preload_next_segment': false,   // 不预加载（节省内存）
        'buffer_segments': 3,             // 缓冲 3 个分段
        'use_memory_cache': false,        // 不使用内存缓存
      },

      // ========== 同步优化 ==========
      'synchronization': {
        'enable_audio_video_sync': true,
        'max_av_diff_ms': 150,  // 最大音视频偏差 150ms
        'sync_tolerance_ms': 50, // 同步容差 50ms
      },

      // ========== 网络优化 ==========
      'network': {
        'connection_timeout_ms': 10000,
        'read_timeout_ms': 10000,
        'buffer_size_kb': 32,
        'enable_adaptive_bitrate': true,
        'bitrate_adaptation_mode': 'auto', // 自动码率自适应
      },

      // ========== Mali-450MP 特定优化 ==========
      'mali450_specific': {
        'gpu_frequency': 750,  // MHz
        'gpu_model': 'Mali-450MP',
        'limit_texture_cache': true,     // 限制纹理缓存
        'optimize_shader_compilation': true, // 优化着色器编译
        'reduce_gpu_memory_footprint': true, // 降低 GPU 内存占用
      },
    };
  }

  /// 针对特定网络环境的优化
  static Map<String, dynamic> optimizeForNetworkConditions(
    int bitrate,
    double packetLoss,
  ) {
    late NetworkQuality quality;

    if (bitrate < 1000) {
      // 码率 < 1Mbps
      quality = NetworkQuality.poor;
    } else if (bitrate < 3000) {
      // 码率 1-3Mbps
      quality = NetworkQuality.fair;
    } else if (bitrate < 8000) {
      // 码率 3-8Mbps
      quality = NetworkQuality.good;
    } else {
      // 码率 >= 8Mbps
      quality = NetworkQuality.excellent;
    }

    _logger.i('🌐 网络检测: 码率=${bitrate}kbps, 丢包=${(packetLoss * 100).toStringAsFixed(2)}%');
    return getMali450OptimizedConfig(quality: quality);
  }

  /// 打印播放器配置
  static void printConfig(Map<String, dynamic> config) {
    _logger.i('⚙️ 播放器配置:');
    _logger.i('  视频编码: ${config['video']['preferred_codecs']}');
    _logger.i('  最大帧率: ${config['video']['max_fps']}fps');
    _logger.i('  音频码率: ${config['audio']['bitrate']}kbps');
    _logger.i('  GPU 模型: ${config['mali450_specific']['gpu_model']}');
    _logger.i('  并发解码: ${config['performance']['limit_concurrent_decoding']}');
    BufferStrategy.printBufferConfig(config['buffer']);
  }

  /// 运行时调整配置
  static void adjustConfigForRuntime(
    Map<String, dynamic> config, {
    required bool isMemoryPressure,
    required bool isHighCpuUsage,
  }) {
    if (isMemoryPressure) {
      _logger.w('⚠️ 内存压力大，降低缓冲...');
      config['buffer']['maxBufferMs'] = 3000;
      config['buffer']['targetBufferBytes'] = 16 * 1024 * 1024;
    }

    if (isHighCpuUsage) {
      _logger.w('⚠️ CPU 使用率高，启用激进掉帧...');
      config['frame_dropping']['aggressive_mode'] = true;
      config['frame_dropping']['max_drop_frames'] = 10;
    }
  }
}
