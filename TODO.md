# Project Progress & Tasks

> **致 Agent**: 请在每次代码迭代后更新此文件。使用 `[x]` 标记已完成，`[ ]` 标记未完成。所有技术决策和临时笔记请记录在底部的 "Notes" 区域。

## 🚀 Current Focus (Phase 1: Windows MVP)

- [ ] **项目初始化**
    - [ ] 创建 Flutter 项目 (支持 Windows, Linux, Android)
    - [ ] 配置 `pubspec.yaml` (添加 `provider`, `isar`, `window_manager`, `media_kit` 等依赖)
    - [ ] **配置 App Icon**
        - [ ] 添加 `flutter_launcher_icons` 到 `dev_dependencies`
        - [ ] 在 `pubspec.yaml` 中配置图标路径 (`assets/icon/app_icon.png`)
        - [ ] 运行生成命令 (`flutter pub run flutter_launcher_icons`) 以覆盖默认 Flutter 图标
    - [ ] 设置 Material 3 主题 (从 Design/Desktop 中提取配色)

- [ ] **UI 框架搭建 (Windows)**
    - [ ] 实现自定义无边框窗口 (使用 `bitsdojo_window` 或 `window_manager`)
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
* *Date: YYYY-MM-DD*: 决定使用 Isar 作为数据库，因为它的查询速度比 SQLite 快，且对 Flutter 支持更好。
* *Date: YYYY-MM-DD*: 设计图位于 `Design/Desktop/v1.png`，主色调需提取 #XXXXXX。