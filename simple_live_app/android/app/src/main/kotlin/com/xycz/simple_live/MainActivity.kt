package com.xycz.simple_live

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 初始化 Amlogic T962 优化
        AmlogicT962Handler.setupAmlogicChannel(this, flutterEngine)
    }
}
