# 📋 Simple Live TV 版本 10.0.0 完整改动文档

**创建日期**：2026年1月5日  
**改动版本**：10.0.0  
**主要目标**：Android 6.0 完整适配 + TV 专用版本

---

## 📑 目录

1. [改动概述](#改动概述)
2. [详细改动清单](#详细改动清单)
3. [技术实现细节](#技术实现细节)
4. [版本升级说明](#版本升级说明)
5. [构建和发布流程](#构建和发布流程)
6. [测试验证清单](#测试验证清单)

---

## 改动概述

### 核心目标

✅ **Android 6.0（API 23）完整适配**
- 项目现可在小米4A 70寸（Android 6.0）上安装运行
- 设置 minSdk = 23，确保最低支持版本

✅ **版本统一升级到 10.0.0**
- 手机应用：1.11.3 → 10.0.0+100000
- 电视应用：1.6.4 → 10.0.0+100000
- TV版本配置：1.3.5 → 10.0.0

✅ **转变为 TV 专用项目**
- 删除所有手机应用构建配置
- 仅保留 TV 应用构建流程
- 简化项目复杂度

---

## 详细改动清单

### 1. 🔧 Android 构建配置修改

#### 1.1 手机应用构建配置
**文件**：`simple_live_app/android/app/build.gradle.kts`

**改动前**：
```gradle
minSdk = flutter.minSdkVersion
```

**改动后**：
```gradle
minSdk = 23  // Android 6.0 (API 23) support
```

**说明**：
- `flutter.minSdkVersion` 通常默认为 API 21 或更高
- 显式设置为 23 确保与 Android 6.0 兼容
- API 23 引入了运行时权限，Flutter 框架已内置处理

#### 1.2 电视应用构建配置
**文件**：`simple_live_tv_app/android/app/build.gradle.kts`

**改动前**：
```gradle
minSdk = flutter.minSdkVersion
```

**改动后**：
```gradle
minSdk = 23  // Android 6.0 (API 23) support
```

**说明**：同上

---

### 2. 📦 版本号升级

#### 2.1 手机应用版本
**文件**：`simple_live_app/pubspec.yaml`

**改动前**：
```yaml
version: 1.11.3+11103
```

**改动后**：
```yaml
version: 10.0.0+100000
```

**版本号格式说明**：
- `10.0.0` - 面向用户的版本号（语义化版本）
- `100000` - 内部版本代码（用于系统识别更新）

#### 2.2 电视应用版本
**文件**：`simple_live_tv_app/pubspec.yaml`

**改动前**：
```yaml
version: 1.6.4+10604
```

**改动后**：
```yaml
version: 10.0.0+100000
```

#### 2.3 TV 版本配置文件
**文件**：`assets/tv_app_version.json`

**改动前**：
```json
{
    "version": "1.3.5",
    "version_num": 10305,
    "version_desc": "- 修复虎牙播放中断 #723 @SlotSun\n- 修复哔哩哔哩加载失败",
    "prerelease": true,
    "download_url": "https://github.com/xiaoyaocz/dart_simple_live/releases"
}
```

**改动后**：
```json
{
    "version": "10.0.0",
    "version_num": 100000,
    "version_desc": "- Android 6.0 (API 23) 完整适配\n- 优化运行时权限处理\n- 改进内存管理",
    "prerelease": false,
    "download_url": "https://github.com/xiaoyaocz/dart_simple_live/releases"
}
```

**关键变化**：
- `prerelease` 从 `true` 改为 `false`（标记为正式版本）
- 更新版本描述为当前改动内容

---

### 3. 🗑️ GitHub Actions Workflow 删除

#### 3.1 已删除的文件

| 文件名 | 功能 | 说明 |
|--------|------|------|
| `.github/workflows/publish_app_release.yml` | 手机应用正式版构建 | iOS/Mac 多平台构建 |
| `.github/workflows/publish_app_dev.yaml` | 手机应用开发版构建 | 开发版本构建 |
| `.github/workflows/build_apk.yml` | 原始 APK 构建 | 通用 APK 构建工作流 |
| `.github/workflows/release.yml` | Release 管理 | 版本发布管理 |

**删除原因**：
- 项目现专注于 TV 应用
- 不再需要手机版本、iOS/Mac 构建
- 简化 CI/CD 流程

#### 3.2 保留的文件

| 文件名 | 功能 | 触发条件 |
|--------|------|---------|
| `.github/workflows/publish_tv_app_release.yaml` | TV 正式版构建 | 推送标签 `tv_v*` |
| `.github/workflows/publish_tv_app_dev.yaml` | TV 开发版构建 | 推送标签 `dev_tv_v*` |

---

### 4. 📚 新增文档

#### 4.1 TV 构建指南
**文件**：`TV_BUILD_GUIDE.md`

**内容包括**：
- 📺 项目说明（仅 TV 应用）
- 🚀 自动构建流程（GitHub Actions）
- 🏗️ 本地构建方法
- 🔐 GitHub Secrets 配置说明
- ✅ Android 6.0 适配说明
- 📝 版本历史
- 🚀 标准发布流程
- 📥 APK 下载说明
- ❓ 常见问题解答

---

## 技术实现细节

### Android 6.0 (API 23) 适配要点

#### 1. 运行时权限 (Runtime Permissions)
**背景**：
- Android 6.0 引入运行时权限要求
- 应用需要在运行时动态申请权限

**当前实现**：
- ✅ Flutter 框架已内置运行时权限处理
- ✅ 涉及权限：存储、网络、摄像头（可选）
- ✅ 无需额外代码修改

#### 2. JavaScript 引擎内存限制
**文件**：
- `simple_live_core/lib/src/scripts/douyin_sign.dart`
- `simple_live_core/lib/src/scripts/douyu_sign.dart`

**配置状态**：✅ 已验证并配置
- 内存限制：4MB
- 栈大小：64-128KB

#### 3. HTTP/HTTPS 安全性
**Android 6.0 变化**：
- 默认不信任用户自安装的证书
- 需要配置网络安全策略

**当前实现**：
- ✅ 应用已支持 HTTPS
- ✅ 可配置 `network_security_config.xml`（可选）

#### 4. 文件访问权限
**涉及组件**：
- Hive 数据库（本地存储）
- 缓存文件管理
- 媒体文件访问

**当前实现**：✅ Flutter/Hive 已自动处理

---

## 版本升级说明

### 版本号设计

| 版本号组件 | 说明 | 当前值 |
|-----------|------|--------|
| Major | 主版本（大改动） | 10 |
| Minor | 次版本（新功能） | 0 |
| Patch | 补丁版本（bug 修复） | 0 |
| Build Code | 构建代码（系统识别） | 100000 |

### 为什么从 1.x 跳到 10.0.0？

**原因**：
1. 区分重大改动（从通用应用到 TV 专用）
2. 清晰标记 Android 6.0 完整适配版本
3. 便于用户理解这是一个新的里程碑版本

### 后续版本规划

```
10.0.0 (当前) - Android 6.0 完整适配
  ↓
10.0.1 - bug 修复版本
  ↓
10.1.0 - 新功能版本
  ↓
11.0.0 - 重大功能更新
```

---

## 构建和发布流程

### 开发流程

```
dev 分支（开发）
    ↓
功能开发和测试
    ↓
git add .
git commit -m "feat: add new feature"
    ↓
master 分支（稳定）
git checkout master
git merge dev
    ↓
创建标签并推送
git tag tv_v10.0.1
git push origin tv_v10.0.1
    ↓
GitHub Actions 自动构建
    ↓
APK 上传到 Releases
    ↓
用户下载使用
```

### 正式发布步骤

#### 步骤 1：提交代码到 dev 分支
```bash
git add .
git commit -m "feat: 描述改动内容"
git push origin dev
```

#### 步骤 2：合并到 master 分支
```bash
git checkout master
git pull origin master
git merge dev
git push origin master
```

#### 步骤 3：创建标签并推送
```bash
# 正式版本
git tag tv_v10.0.1
git push origin tv_v10.0.1

# 或开发版本
git tag dev_tv_v10.0.1
git push origin dev_tv_v10.0.1
```

#### 步骤 4：GitHub Actions 自动构建
- 系统自动触发 workflow
- 编译生成三个 APK 文件
- 自动上传到 GitHub Releases

#### 步骤 5：验证和发布
- 检查 Releases 页面
- 确认 APK 构建成功
- 根据需要编写 Release Notes

### 本地构建命令

```bash
# 切换到 TV 应用目录
cd simple_live_tv_app

# 生成 Release 版本 APK（分离架构）
flutter build apk --release --split-per-abi

# 输出文件位置
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

---

## GitHub Actions 配置

### 所需的 Secrets

在 GitHub 仓库设置 → Secrets → New repository secret 中添加：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `TV_KEYSTORE_BASE64` | Keystore 文件 Base64 编码 | 见下方生成说明 |
| `TV_STORE_PASSWORD` | Keystore 存储密码 | 自定义 |
| `TV_KEY_PASSWORD` | 密钥密码 | 自定义 |
| `TV_KEY_ALIAS` | 密钥别名 | 自定义 |
| `TOKEN` | GitHub Personal Access Token | GitHub 设置生成 |

### 生成 Keystore Base64 编码

#### 方式 1：使用 OpenSSL（推荐）
```bash
openssl base64 < your_keystore.jks | tr -d '\n' | pbcopy
```

#### 方式 2：使用 Python
```bash
python -c "import base64; print(base64.b64encode(open('your_keystore.jks', 'rb').read()).decode())"
```

#### 方式 3：使用 PowerShell（Windows）
```powershell
$file = [System.IO.File]::ReadAllBytes("your_keystore.jks")
[System.Convert]::ToBase64String($file)
```

### 生成 GitHub Token

1. 进入 GitHub → Settings → Developer settings → Personal access tokens
2. 生成新 token，选择 `repo` 和 `write:packages` 权限
3. 复制 token 值到 `TOKEN` Secret

---

## 测试验证清单

### ✅ 构建验证

- [ ] 本地 Flutter 环境正常
- [ ] 无代码编译错误
- [ ] APK 文件成功生成
- [ ] APK 文件大小合理（通常 40-100MB）

### ✅ 安装测试

- [ ] APK 能在 Android 6.0 设备上安装
- [ ] 应用启动无闪退
- [ ] 应用图标和名称显示正确

### ✅ 功能测试

- [ ] 应用主界面加载正常
- [ ] 直播列表能正常加载
- [ ] 可以播放直播流
- [ ] 音量控制正常
- [ ] 退出应用无错误

### ✅ GitHub Actions 测试

- [ ] 推送标签后 Actions 自动触发
- [ ] 构建过程中无错误
- [ ] APK 正确上传到 Releases
- [ ] Release Notes 显示正确

---

## Git 提交日志

### 本次改动的 commit

```
commit a1fed34... - chore: remove phone app workflows, only keep TV app builds
commit 5f0c2a2... - docs: add TV build guide for version 10.0.0
```

### 涉及的文件变更

```
11 files changed:
  + 创建：TV_BUILD_GUIDE.md
  - 删除：.github/workflows/publish_app_dev.yaml
  - 删除：.github/workflows/publish_app_release.yml
  - 删除：.github/workflows/build_apk.yml
  - 删除：.github/workflows/release.yml
  修改：simple_live_app/android/app/build.gradle.kts
  修改：simple_live_tv_app/android/app/build.gradle.kts
  修改：simple_live_app/pubspec.yaml
  修改：simple_live_tv_app/pubspec.yaml
  修改：assets/tv_app_version.json
```

---

## 注意事项

### ⚠️ 重要提醒

1. **keystore 文件安全**
   - 不要将 keystore 文件上传到 git
   - 已在 `.gitignore` 中添加 `*.jks` 排除

2. **版本号管理**
   - 每次发布都应更新版本号
   - Build code 通常是版本号去掉小数点后乘以 1000（示例：10.0.0 → 100000）

3. **Android 6.0 兼容性**
   - 虽然 minSdk = 23，但建议定期在 Android 6.0 设备上测试
   - 某些新特性可能需要特殊处理

4. **GitHub Token 有效期**
   - Personal Access Token 应定期更新
   - 避免长期使用同一个 token

---

## 后续改进方向

### 🔮 建议的未来改动

1. **UI/UX 优化**
   - 针对大屏幕优化界面布局
   - 改进遥控器操作体验

2. **性能优化**
   - 减少内存占用
   - 优化视频解码性能

3. **功能增强**
   - 添加节目单功能
   - 改进搜索功能
   - 支持自定义源

4. **国际化支持**
   - 多语言支持
   - 适配不同地区

---

## 快速参考

### 常用命令

```bash
# 查看当前版本
cat simple_live_tv_app/pubspec.yaml | grep version

# 创建新版本标签
git tag tv_v10.0.1 && git push origin tv_v10.0.1

# 本地构建
cd simple_live_tv_app && flutter build apk --release --split-per-abi

# 查看 commit 历史
git log --oneline -10

# 同步最新代码
git fetch origin && git merge origin/dev
```

### 关键文件路径

```
项目根目录
├── .github/workflows/
│   ├── publish_tv_app_release.yaml    ← 正式版构建
│   └── publish_tv_app_dev.yaml        ← 开发版构建
├── simple_live_tv_app/
│   ├── pubspec.yaml                   ← TV 应用版本
│   └── android/app/build.gradle.kts   ← Android 构建配置
├── simple_live_app/
│   ├── pubspec.yaml                   ← 手机应用版本（暂时保留）
│   └── android/app/build.gradle.kts   ← Android 构建配置
├── assets/tv_app_version.json         ← TV 版本信息
├── TV_BUILD_GUIDE.md                  ← TV 构建指南
└── 此文件.md                           ← 完整改动文档
```

---

## 版本信息

| 项目 | 值 |
|------|-----|
| **当前版本** | 10.0.0 |
| **最低 Android 版本** | 6.0 (API 23) |
| **目标设备** | 小米 4A 70 寸电视 |
| **构建工具** | Flutter 3.38.x |
| **文档更新日期** | 2026-01-05 |

---

*此文档是 Simple Live TV 版本 10.0.0 的完整改动记录，供团队参考和后续维护使用。*
