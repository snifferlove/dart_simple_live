# GitHub Actions 自动构建APK指南

## 📋 配置说明

已为项目配置了两个GitHub Actions工作流：

### 1. **build_apk.yml** - 持续集成构建
- **触发条件**：
  - Push到 `master`, `main`, `dev` 分支
  - Pull Request到 `master`, `main` 分支
  - 手动触发（Workflow Dispatch）

- **功能**：
  - 自动构建APK
  - 生成构建产物（保留30天）
  - **不会自动发布Release**

### 2. **release.yml** - 版本发布构建
- **触发条件**：
  - 推送带有 `v` 前缀的标签（Tag），例如 `v1.0.0`
  - 手动触发（Workflow Dispatch）

- **功能**：
  - 自动构建APK
  - 自动创建GitHub Release
  - 自动上传APK到Release
  - 生成构建产物（保留90天）

## 🚀 使用方法

### 方法1：自动发布版本（推荐）

1. **本地创建标签**：
```bash
# 创建标签
git tag v1.0.0

# 推送标签到GitHub（会触发release.yml）
git push origin v1.0.0
```

2. **或在GitHub网页界面创建Release**：
   - 点击 "Releases" → "Draft a new release"
   - 输入标签名（如 `v1.0.0`）
   - 自动触发构建并创建Release

### 方法2：手动触发构建

1. 访问GitHub仓库
2. 点击 "Actions" 标签
3. 选择要运行的工作流（`Build APK` 或 `Build and Release APK`）
4. 点击 "Run workflow"

### 方法3：自动构建（每次Push）

- Push代码到 `master` 或 `main` 分支
- 自动触发 `build_apk.yml` 
- 在 "Actions" 标签查看进度

## 📥 下载APK

### 从Artifacts下载（临时存储）
1. 访问 Actions 页面
2. 点击对应的工作流运行记录
3. 点击 "Artifacts" 下载 `apk-builds`

### 从Release下载（正式发布）
1. 访问 "Releases" 页面
2. 点击对应版本
3. 在 "Assets" 下载APK文件

## ⚙️ 环境说明

工作流运行环境：
- **系统**：Ubuntu Latest
- **Java**：17（Temurin）
- **Flutter**：Latest Stable
- **构建工具**：自动安装和缓存

## 📝 构建产物

构建成功后生成：
- `simple_live_app-release.apk` - 手机应用
- `simple_live_tv_app-release.apk` - 电视应用

## 🔍 查看构建日志

1. 访问GitHub仓库
2. 点击 "Actions" 标签
3. 选择工作流运行记录
4. 查看详细日志

## 💡 常见问题

### Q: 为什么构建失败？
A: 检查：
- 是否有必要的依赖安装失败
- 代码是否有语法错误
- 查看详细日志找出错误

### Q: 如何跳过自动构建？
A: 在commit信息中添加 `[skip ci]`：
```bash
git commit -m "更新文档 [skip ci]"
```

### Q: APK保留多久？
A: 
- build_apk.yml：30天
- release.yml：90天

### Q: 如何修改构建配置？
A: 编辑 `.github/workflows/` 目录下的yml文件

## 🔐 安全说明

- GITHUB_TOKEN 由GitHub自动管理，无需配置
- 如需签名密钥，参考下方"高级配置"

## 🎯 高级配置（可选）

### 配置APK签名（生产环境）

如需对APK进行签名，在 GitHub 仓库设置中添加 Secrets：

1. Settings → Secrets and variables → Actions
2. 创建以下Secret：
   - `KEYSTORE_BASE64`：签名密钥的Base64编码
   - `KEYSTORE_PASSWORD`：密钥库密码
   - `KEY_ALIAS`：密钥别名
   - `KEY_PASSWORD`：密钥密码

然后修改workflow文件中的构建命令：
```bash
flutter build apk --release \
  --keystore=/path/to/keystore.jks \
  --keystore-password=${{ secrets.KEYSTORE_PASSWORD }} \
  --key-alias=${{ secrets.KEY_ALIAS }} \
  --key-password=${{ secrets.KEY_PASSWORD }}
```

## 📚 更多资源

- [Flutter官方文档](https://flutter.dev/docs/deployment/android)
- [GitHub Actions文档](https://docs.github.com/en/actions)
- [Subosito Flutter Action](https://github.com/subosito/flutter-action)
