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

- [x] **UI 框架搭建 (Windows)**
    - [x] 实现自定义无边框窗口 (使用 `window_manager` 及 DWM)
    - [x] 实现侧边导航栏 (NavigationRail)
    - [x] 实现顶部标题栏与窗口控制按钮

- [x] **核心播放器逻辑**
    - [x] 封装 Audio Service
    - [x] 实现播放、暂停、进度控制

- [x] **文件系统与数据库**
    - [x] 实现文件夹选择器
    - [x] 扫描本地音频文件 (.mp3, .flac, .wav)
    - [x] 设计 Isar 数据库模型 (Song, Album, Artist)
    - [x] 集成 DatabaseService 到 LibraryProvider

- [ ] **UI 完善 (设计还原)**
    - [x] 完善 LibraryPage UI（按照 Design/Desktop/library.png）
    - [ ] 完善 HomePage UI（按照 Design/Desktop/home.png）

## 🔮 Future Tasks (Backlog)

### Phase 2: Linux
- [ ] 测试主流发行版兼容性
- [ ] 实现 MPRIS 控制接口

### Phase 3: Android
- [ ] 响应式布局适配 (Mobile 视图)
- [ ] Android 权限请求逻辑
- [ ] 后台播放服务 (AudioService)

## 📝 Technical Notes & Decisions
* *2026-02-17*: LibraryPage UI 完成还原。重写为 StatefulWidget with TabController，支持 4 个标签页（Titles、Artists、Albums、Folders）。Titles 标签页显示网格布局的歌曲卡片（5 列），每个卡片显示占位符图标、标题、更新时间。Folders 标签页显示已添加文件夹列表。Artists 和 Albums 标签页预留待实现。支持点击卡片播放歌曲、删除文件夹等交互。
* *2026-02-17*: DatabaseService 集成到 LibraryProvider 完成。LibraryProvider 现在在初始化时调用 DatabaseService.initialize() 加载已保存歌曲，扫描新文件时创建 Song 对象并批量保存到数据库。AppShell 改为 StatefulWidget，在 initState 中初始化库。提供 songs 属性和 searchSongs() 方法供 UI 直接使用，兼容旧的 audioFiles API。
* *2026-02-17*: Isar 数据库模型设计完成。创建三个 @collection 类：Song（包含 title, filePath, artist, album, genre, duration, durationMs, isFavorite, playCount, lastPlayedAt, dateAdded, dateModified）、Album（name, artist, releaseYear, songCount, coverPath, dateAdded）、Artist（name, songCount, albumCount, dateAdded）。DatabaseService 提供单例模式访问 Isar 实例，包含 CRUD 操作和查询方法。添加 path_provider 依赖用于数据库目录管理。
* *2026-02-16*: 完成项目骨架初始化。使用 `just_audio` 替代 `media_kit`（版本兼容性更好）。使用 `provider` 做状态管理，`isar` 做数据库，`window_manager` 做桌面窗口管理。
* *2026-02-16*: App Icon 已通过 `flutter_launcher_icons` 生成，覆盖 Windows/Android/Linux 图标。
* *2026-02-16*: 设计图位于 `Design/Desktop/`，有 5 个主要页面设计（home, library, playlist, search, settings）。
* *2026-02-16*: Material 3 主题配置完成。主色 #9C7FD4 (淡紫)，背景 #FAF8FF，表面 #F5F1FF，遵循设计稿配色。
* *2026-02-16*: Windows 无边框窗口实现完成。使用 WS_POPUP style + DwmExtendFrameIntoClientArea() 实现 DWM 无边框效果。Flutter 层通过 window_manager + WindowConfig 初始化。
* *2026-02-16*: NavigationRail 实现完成。创建 NavItem 数据模型、NavigationProvider (ChangeNotifier)，支持 Home/Library/Search/Playlist 4 个导航项。AppShell 包含 NavigationRail + Expanded 内容区域。
* *2026-02-16*: 自定义标题栏 (CustomTitleBar) 实现完成。包含应用名称、最小化/最大化/关闭按钮（Windows 平台）、悬停效果。关闭按钮变红，最大化按钮动态切换状态。
* *2026-02-16*: Audio Service 封装完成。创建 AudioService (基于 just_audio)、PlayerState 数据模型、PlayerProvider (ChangeNotifier)。支持加载、播放、暂停、停止、音量控制、进度条拖动、流式状态更新。
* *2026-02-16*: 播放控制 UI 实现完成。创建 MiniPlayer（底部迷你播放器，显示曲名/艺术家、播放/暂停按钮）、PlayerControlBar（完整控制栏）。集成到 AppShell，支持 Slider 拖动进度条、时长显示、Play/Pause 切换。
* *2026-02-16*: 文件夹选择器实现完成。创建 FileScannerService（递归扫描目录支持 .mp3/.flac/.wav/.aac/.m4a）、FolderPickerDialog（UI 对话框支持导航和文件夹选择）、LibraryProvider（管理音乐目录和文件列表）。
* *2026-02-16*: 本地音频文件扫描与展示完成。更新 LibraryPage 支持添加文件夹、显示扫描的音频文件列表、删除文件夹。集成 LibraryProvider 进行状态管理，支持显示加载状态和空状态。