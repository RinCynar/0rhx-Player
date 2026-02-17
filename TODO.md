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

- [x] **UI 完善 (设计还原)**
    - [x] 完善 LibraryPage UI（按照 Design/Desktop/library.png）
    - [x] 完善 HomePage UI（按照 Design/Desktop/home.png）

- [x] **播放功能实现**
    - [x] 实现点击歌曲时加载到播放器并播放
    - [x] 更新 MiniPlayer 显示当前播放歌曲信息

- [x] **搜索功能实现**
    - [x] 完善 SearchPage UI（按照 Design/Desktop/search.png）
    - [x] 实现搜索歌曲功能

- [x] **播放列表页面**
    - [x] 完善 PlaylistPage UI（按照 Design/Desktop/playlist.png）
    - [x] 实现播放列表功能

- [ ] **音乐元数据提取**
    - [ ] 集成元数据库（如 metadata_god 或 audio_metadata_reader）获取真实的曲名、艺术家、时长
    - [ ] 更新扫描时的文件元数据提取逻辑

## 🔮 Future Tasks (Backlog)

### Phase 2: Linux
- [ ] 测试主流发行版兼容性
- [ ] 实现 MPRIS 控制接口

### Phase 3: Android
- [ ] 响应式布局适配 (Mobile 视图)
- [ ] Android 权限请求逻辑
- [ ] 后台播放服务 (AudioService)

## 📝 Technical Notes & Decisions
* *2026-02-17*: PlaylistPage UI 完成还原。重写为 StatefulWidget with TabController，包含当前播放歌曲的大卡片（显示占位符、标题、艺术家，渐变背景）。两个标签页：Played（显示库中所有歌曲）和 Nexts（显示下一首待播放的歌曲）。每个列表项显示歌曲信息、5 颗星评分和收藏按钮。使用 ConsumerWidget 获取 PlayerProvider 和 LibraryProvider 数据。
* *2026-02-17*: SearchPage UI 完成还原。重写为 StatefulWidget，包含搜索输入框（带提示文本和搜索/菜单图标）。当搜索为空时显示 Featured 部分（前 3 首歌）。用户输入时实时显示搜索结果，使用 LibraryProvider.searchSongs() 进行搜索。搜索结果分两种展示：网格布局（横向滚动卡片）和列表布局（详细项目）。点击任何歌曲卡片直接播放。无搜索结果时显示提示文本。
* *2026-02-17*: 播放功能实现完成。在 HomePage 和 LibraryPage 中添加 `_playSong()` 方法，点击歌曲卡片时调用 PlayerProvider.loadTrack() 加载歌曲文件并传入标题和艺术家，然后调用 PlayerProvider.play() 播放。MiniPlayer 已正确绑定 PlayerProvider，自动显示当前播放歌曲的 title 和 artist 信息。播放/暂停按钮已集成到 MiniPlayer。
* *2026-02-17*: HomePage UI 完成还原。重写为 StatelessWidget，包含 AppBar（标题、菜单、设置）和主内容区。主内容分为两部分：Daily Mix（横向滚动小卡片，显示歌曲占位符和标题）和 Section title（2 列网格的大卡片，显示艺术家/歌曲信息和播放按钮）。使用 Consumer<LibraryProvider> 获取歌曲数据，支持库为空时的空状态显示。
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