# Project Progress & Tasks

> **致 Agent**: 请在每次代码迭代后更新此文件。使用 `[x]` 标记已完成，`[ ]` 标记未完成。所有技术决策和临时笔记请记录在底部的 "Notes" 区域。

## 🚀 Current Focus (Phase 1: Windows MVP)

- [x] **项目初始化**
    - [x] 创建 Flutter 项目 (支持 Windows, Linux, Android)
    - [x] 配置 `pubspec.yaml` (添加 `provider`, `isar`, `window_manager`, `just_audio` 等依赖)
    - [x] **配置 App Icon**
        - [x] 添加 `flutter_launcher_icons` 到 `dev_dependencies`
        - [x] 在 `pubspec.yaml` 中配置图标路径 (`assets/icon/app_icon.png`)
        - [x] 运行生成命令 (`flutter pub run flutter_launcher_icons`) 以覆盖默认 Flutter 图标
    - [x] 设置 Material 3 主题 (从 Design/Desktop 中提取配色)

- [ ] **UI 框架搭建 (Windows)**
    - [x] 实现自定义无边框窗口 (使用 `window_manager` 及 DWM)
    - [ ] 实现侧边导航栏 (NavigationRail)
    - [ ] 实现顶部标题栏与窗口控制按钮

- [ ] **核心播放器逻辑**
    - [ ] 封装 Audio Service
    - [ ] 实现播放、暂停、进度控制

- [ ] **文件系统与数据库**
    - [ ] 实现文件夹选择器
    - [ ] 扫描本地音频文件 (.mp3, .flac, .wav)
    - [ ] 设计 Isar 数据库模型 (Song, Album, Artist)

## 🔮 Future Tasks (Backlog)

### Phase 2: Linux
- [ ] 测试主流发行版兼容性
- [ ] 实现 MPRIS 控制接口

### Phase 3: Android
- [ ] 响应式布局适配 (Mobile 视图)
- [ ] Android 权限请求逻辑
- [ ] 后台播放服务 (AudioService)

## 📝 Technical Notes & Decisions
* *2026-02-16*: 完成项目骨架初始化。使用 `just_audio` 替代 `media_kit`（版本兼容性更好）。使用 `provider` 做状态管理，`isar` 做数据库，`window_manager` 做桌面窗口管理。
* *2026-02-16*: App Icon 已通过 `flutter_launcher_icons` 生成，覆盖 Windows/Android/Linux 图标。
* *2026-02-16*: 设计图位于 `Design/Desktop/`，有 5 个主要页面设计（home, library, playlist, search, settings）。
* *2026-02-16*: Material 3 主题配置完成。主色 #9C7FD4 (淡紫)，背景 #FAF8FF，表面 #F5F1FF，遵循设计稿配色。
* *2026-02-16*: Windows 无边框窗口实现完成。使用 WS_POPUP style + DwmExtendFrameIntoClientArea() 实现 DWM 无边框效果。Flutter 层通过 window_manager + WindowConfig 初始化。