# PR #853 - Android 6.0 支持改动已应用

本文档总结了PR #853的所有改动，这些改动用于支持Android 6.0（API级别23）并添加房间特定的音量管理功能。

## 概述
PR #853引入了Android 6.0（API 23）支持，并添加了存储和管理每个房间音量偏好的功能，改善了用户在切换不同直播间时的体验。

## 应用的改动

### 1. Android 6.0 支持（在前一个会话中完成）
- **simple_live_app/android/app/build.gradle.kts**：设置 `minSdk = 23`
- **simple_live_tv_app/android/app/build.gradle.kts**：设置 `minSdk = 23`
- JavaScript 引擎内存限制已在以下文件中验证：
  - `simple_live_core/lib/src/scripts/douyin_sign.dart`
  - `simple_live_core/lib/src/scripts/douyu_sign.dart`

### 2. 设置基础设施（已完成）
**文件：`simple_live_app/lib/app/controller/app_settings_controller.dart`**
- 添加了 `userName` 可观察字段用于同步功能
- 添加了 `syncUrl` 可观察字段用于远程同步服务器URL
- 添加了setter方法：`setUserName()` 和 `setSyncUrl()`

**文件：`simple_live_app/lib/services/local_storage_service.dart`**
- 添加了存储常数：
  - `static const String userName = "userName"`
  - `static const String syncUrl = "syncUrl"`

### 3. 房间特定音量管理（新增）
**文件：`simple_live_app/lib/services/db_service.dart`**
- 添加了 `volumeBox` 来存储房间特定的音量设置
- 添加了初始化：`volumeBox = await Hive.openBox("Volume")`
- 添加了方法：`Future addOrUpdateVolume(String id, double volume)`
- 添加了方法：`double? getVolume(String id)`

**文件：`simple_live_app/lib/modules/live_room/live_room_controller.dart`**
- 修改了音量滑块处理程序以保存房间特定的音量：
  ```dart
  DBService.instance.addOrUpdateVolume("${site.id}_$roomId", newValue.toDouble());
  ```
- 在 `loadData()` 方法中添加了房间特定的音量加载：
  ```dart
  double? roomVolume = DBService.instance.getVolume("${site.id}_$roomId");
  if (roomVolume != null && roomVolume > 0) {
    player.setVolume(roomVolume);
    AppSettingsController.instance.setPlayerVolume(roomVolume);
  }
  ```

### 4. HTTP 响应处理（已改进）
**文件：`simple_live_app/lib/requests/http_client.dart`**
- 增强了 `postJson()` 方法以处理空响应正文：
  ```dart
  var responseData = result.data;
  // 处理空响应体
  if (responseData == null || (responseData is String && responseData.isEmpty)) {
    return {};
  }
  return responseData;
  ```
- 这可以防止当同步API调用返回空响应时出现空引用异常

## 添加的功能

### 房间特定音量偏好
用户现在拥有跨会话持久化的房间特定音量设置。进入直播间时：
1. 系统检查该特定房间（由 `${site.id}_$roomId` 标识）是否存在音量偏好
2. 如果存在，音量会自动恢复到用户之前选择的级别
3. 当用户调整音量时，它会被保存为该房间的偏好
4. 这改进了观看体验，因为用户可以为不同内容维持首选音量级别

### 同步功能基础设施
同步功能的基础设施现已就位，包括：
- 用户名和同步服务器URL的存储
- 跨设备数据同步的基础（同步服务已存在于代码库中）

## 测试建议

1. **Android 6.0 安装**：在 Android 6.0 设备上测试 APK 安装
2. **房间音量持久化**：
   - 打开多个不同的直播间
   - 为每个房间设置不同的音量级别
   - 在房间之间切换并验证音量是否正确恢复
   - 关闭并重启应用，验证房间音量是否被保留
3. **HTTP 响应处理**：使用配置的同步服务器测试同步功能
4. **存储**：验证 Hive `volumeBox` 是否正确创建并持久化数据

## 实现注意事项

- 房间音量识别使用模式：`${site.id}_$roomId` 来唯一标识每个房间
- 音量值在 Hive 盒子中存储为 `double` 类型
- 当房间没有保存的音量偏好（首次访问）时，它默认为全局音量设置
- 在每次音量调整时，更改会自动保存到数据库
- 不需要用户操作 - 系统透明地工作

## 向后兼容性

所有改动都是向后兼容的：
- 设置中的新字段如果未找到，具有默认值
- 缺失的房间音量偏好回退到全局音量设置
- HTTP 响应处理更加健壮，处理旧和新的响应格式

## 修改的文件

1. `simple_live_app/lib/services/db_service.dart` - 添加了音量存储
2. `simple_live_app/lib/modules/live_room/live_room_controller.dart` - 添加了音量加载/保存
3. `simple_live_app/lib/requests/http_client.dart` - 增强了响应处理
4. `simple_live_app/lib/app/controller/app_settings_controller.dart` - 添加了同步字段（在前一个会话中）
5. `simple_live_app/lib/services/local_storage_service.dart` - 添加了存储常数（在前一个会话中）

## 构建信息

- **目标**：Android 6.0 及以上（minSdk = 23）
- **框架**：Flutter/Dart
- **状态管理**：GetX
- **数据库**：Hive（本地持久化）
- **HTTP 客户端**：Dio（带有自定义拦截器）

---

PR #853 的所有改动已成功集成到代码库中。
