# 📺 TV 应用构建指南 (版本 10.0.0)

## 项目说明
该项目现已配置为**仅构建TV应用**，不再生成手机版本的APK。

---

## 📋 构建流程

### **自动构建（GitHub Actions）**

#### 1️⃣ **正式版本构建** (`publish_tv_app_release.yaml`)
**触发条件**：推送标签 `tv_v*`

```bash
# 创建标签并推送（自动触发GitHub Actions）
git tag tv_v10.0.0
git push origin tv_v10.0.0
```

- 运行环境：macOS Latest
- 输出物：三个APK文件
  - `app-armeabi-v7a-release.apk`（32位ARM）
  - `app-arm64-v8a-release.apk`（64位ARM）
  - `app-x86_64-release.apk`（x86 64位）
- 自动上传至GitHub Releases

#### 2️⃣ **开发版本构建** (`publish_tv_app_dev.yaml`)
**触发条件**：推送标签 `dev_tv_v*`

```bash
git tag dev_tv_v10.0.0
git push origin dev_tv_v10.0.0
```

---

### **本地构建**

```bash
cd simple_live_tv_app

# 构建Release APK
flutter build apk --release --split-per-abi

# 输出路径
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

---

## 🔐 GitHub Actions 所需 Secrets

在GitHub仓库设置中配置以下Secrets（用于APK签名）：

| Secret 名称 | 说明 |
|------------|------|
| `TV_KEYSTORE_BASE64` | Keystore文件的Base64编码 |
| `TV_STORE_PASSWORD` | Keystore存储密码 |
| `TV_KEY_PASSWORD` | 密钥密码 |
| `TV_KEY_ALIAS` | 密钥别名 |
| `TOKEN` | GitHub Personal Access Token（用于发布Release） |

**生成Base64编码的keystore：**
```bash
# Windows/Mac/Linux
openssl base64 < your_keystore.jks | tr -d '\n' | pbcopy

# 或使用Python
python -c "import base64; print(base64.b64encode(open('your_keystore.jks', 'rb').read()).decode())"
```

---

## ✅ Android 6.0 适配

该版本已完全适配Android 6.0（API 23）：
- ✅ `minSdk = 23`
- ✅ 运行时权限处理
- ✅ JavaScript引擎内存限制
- ✅ HTTP/HTTPS配置
- ✅ 文件权限处理

可直接在小米4A 70寸（Android 6.0）设备上安装运行。

---

## 📝 版本历史

| 版本 | 说明 |
|------|------|
| 10.0.0 | Android 6.0完整适配版本 |

---

## 🚀 发布流程

### **标准发布流程**

```bash
# 1. 在dev分支中进行开发和测试
git checkout dev
# ... 进行代码修改和测试 ...

# 2. 提交改动
git add .
git commit -m "feat: add new features for v10.0.1"

# 3. 合并到master分支
git checkout master
git merge dev

# 4. 创建标签并推送（自动触发GitHub Actions）
git tag tv_v10.0.1
git push origin tv_v10.0.1

# 5. 等待GitHub Actions完成构建和发布
# 完成后APK将出现在 GitHub Releases 中
```

---

## 📥 下载APK

### **从GitHub Releases下载**
访问：https://github.com/snifferlove/dart_simple_live/releases

### **选择合适的APK**
- **小米4A 70寸**：下载 `app-arm64-v8a-release.apk`（大多数现代设备推荐）
- 或尝试 `app-armeabi-v7a-release.apk`（兼容性最好）

---

## ❓ 常见问题

**Q: 为什么没有手机版APK？**
A: 该项目现已专注于TV应用开发，仅构建TV版本。

**Q: 如何测试本地构建？**
A: 使用 `flutter build apk --release --split-per-abi` 本地编译。

**Q: APK无法在Android 6.0上安装？**
A: 确保选择 `arm64-v8a` 版本，并检查设备存储空间。

---

*最后更新：2026年1月5日*
