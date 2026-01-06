import 'package:logger/logger.dart';

/// Mali-450MP 缓冲策略优化器
/// 针对小米 4A 的网络缓冲和播放缓冲调整
class BufferStrategy {
  static final Logger _logger = Logger();

  /// Mali-450MP 专用缓冲配置
  static const Map<String, int> mali450BufferConfig = {
    // 最小缓冲时间 (ms)
    // 过小：易卡顿; 过大：内存溢出
    'minBufferMs': 1200,

    // 再次缓冲最小时间 (ms)
    // 播放中断后快速恢复
    'minPlaybackResumeBufferMs': 1000,

    // 最大缓冲时间 (ms)
    // Mali-450MP 受限，不能过大
    'maxBufferMs': 5000,

    // 缓冲准备完毕所需时间 (ms)
    'bufferForPlaybackMs': 1800,

    // 再次缓冲准备完毕所需时间 (ms)
    'bufferForPlaybackAfterRebufferMs': 3500,

    // 目标缓冲字节数 (bytes)
    // 限制内存占用：32MB
    'targetBufferBytes': 32 * 1024 * 1024,

    // 缓冲增长字节数 (bytes)
    'bufferForPlaybackByteSize': 4 * 1024 * 1024,

    // 再次缓冲增长字节数 (bytes)
    'bufferForPlaybackAfterRebufferByteSize': 6 * 1024 * 1024,
  };

  /// 获取网络条件自适应配置
  static Map<String, int> getAdaptiveConfig(NetworkQuality quality) {
    final config = Map<String, int>.from(mali450BufferConfig);

    switch (quality) {
      case NetworkQuality.poor:
        // 网络差：增加缓冲时间
        config['minBufferMs'] = 2000;
        config['maxBufferMs'] = 8000;
        config['targetBufferBytes'] = 48 * 1024 * 1024;
        _logger.w('⚠️ 网络质量差，增加缓冲');
        break;

      case NetworkQuality.fair:
        // 网络一般：标准配置
        _logger.i('📊 网络质量一般，使用标准配置');
        break;

      case NetworkQuality.good:
        // 网络好：减少缓冲延迟
        config['minBufferMs'] = 800;
        config['maxBufferMs'] = 3000;
        config['targetBufferBytes'] = 20 * 1024 * 1024;
        _logger.i('✅ 网络质量好，减少缓冲延迟');
        break;

      case NetworkQuality.excellent:
        // 网络极好：最小缓冲
        config['minBufferMs'] = 500;
        config['maxBufferMs'] = 2000;
        config['targetBufferBytes'] = 16 * 1024 * 1024;
        _logger.i('🚀 网络质量优秀，最小化缓冲');
        break;
    }

    return config;
  }

  /// 打印缓冲配置
  static void printBufferConfig(Map<String, int> config) {
    _logger.i('📋 缓冲配置:');
    _logger.i('  最小缓冲: ${config['minBufferMs']}ms');
    _logger.i('  最大缓冲: ${config['maxBufferMs']}ms');
    _logger.i('  播放缓冲: ${config['bufferForPlaybackMs']}ms');
    _logger.i('  再缓冲: ${config['bufferForPlaybackAfterRebufferMs']}ms');
    _logger.i('  目标大小: ${config['targetBufferBytes']! / (1024 * 1024).toStringAsFixed(1)}MB');
  }

  /// 获取建议的帧丢弃阈值
  static int getFrameDropThreshold(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.poor:
        return 8;  // 网络差时允许更多掉帧
      case NetworkQuality.fair:
        return 5;
      case NetworkQuality.good:
        return 3;
      case NetworkQuality.excellent:
        return 1;  // 网络好时尽量不掉帧
    }
  }
}

/// 网络质量枚举
enum NetworkQuality { poor, fair, good, excellent }
