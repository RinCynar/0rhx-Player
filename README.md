# 0rhx Player

![Project Status](https://img.shields.io/badge/Status-Active_Development-brightgreen)
![Tech Stack](https://img.shields.io/badge/Tech-Flutter_%7C_Dart-blue)
![Design](https://img.shields.io/badge/Design-Material_You-purple)
![AI-Powered](https://img.shields.io/badge/Dev-AI_VibeCoding-orange)

**0rhx Player** 是一个开源、跨平台、基于 Material You 设计语言的本地音乐播放器。

本项目采用 **VibeCoding** 模式开发：由人类负责产品愿景与 UI 设计（Figma），由 AI Agent（Google Antigravity）负责全栈代码实现。

## 🎯 项目愿景 (Project Vision)

打造一个在桌面端和移动端都具备原生级美感与流畅体验的本地播放器。不追求在线流媒体功能，只专注于本地音乐管理的极致体验。

### 支持平台 (Platform Support)
1.  **Windows**: x64 & ARM64 (优先开发)
2.  **Linux**: 主流发行版 (Ubuntu/Debian/Arch 等)
3.  **Android**: Android 11+ (API Level 30+)

---

## 🤖 致 AI Agent (Developer Protocol)

**IMPORTANT:** 如果你是一个接手此项目的 AI Agent，请**严格**阅读并遵守以下协议。你的所有行为必须符合以下规范，以确保在多轮对话和上下文切换中的一致性。

### 1. 开发角色与职责
* **你的角色**: 高级 Flutter 工程师 & UI/UX 专家。
* **你的任务**: 根据 `Design/` 目录下的设计图截图，还原 UI 并实现业务逻辑。
* **设计语言**: 必须严格遵循 **Material You (Material 3)** 规范。使用 `flutter_animate` 增加交互动效。

### 2. 核心工作流 (Workflow)
1.  **读取状态**: 开始工作前，**必须**先读取 `TODO.md` 了解当前进度和待办事项。
2.  **视觉参考**: 实现 UI 时，**必须**检查 `Design/` 目录下的对应文件夹（Desktop/Mobile）。
    * *Design/Desktop*: 用于 Windows/Linux 开发参考。
    * *Design/Mobile*: 用于 Android 开发参考。
3.  **文档管理 (Zero-Doc Policy)**:
    * ❌ **禁止**创建任何新的文档文件（如 `docs/`, `arch.txt` 等）。
    * ✅ **所有** 进度记录、技术决策、未完成事项、Bug 追踪，**必须且只能** 写入 `TODO.md`。
    * 每次代码修改后，请自动更新 `TODO.md` 中的对应条目状态。

### 3. 技术栈规范 (Tech Constraints)
* **State Management**: 使用 `Provider` 或 `Riverpod` (保持轻量且高效)。
* **Audio Engine**: 推荐使用 `media_kit` (也就是 video_player_media_kit) 或 `just_audio`，确保跨平台兼容性。
* **Database**: 使用 `Isar` 或 `Drift` 进行本地音乐元数据存储。
* **Architecture**: 采用 Clean Architecture 分层思想 (Presentation -> Domain -> Data)，便于后续跨平台维护。

---

## 📅 开发路线图 (Roadmap)

项目开发将严格按照以下顺序进行。当前阶段请参考 `TODO.md`。

### Phase 1: Windows Core (当前焦点)
* 搭建基础 Flutter Desktop 架构。
* 实现 Material 3 窗口框架（无边框、自定义标题栏）。
* 本地文件扫描与数据库索引。
* 基础播放功能（播放/暂停/上一曲/下一曲）。

### Phase 2: Linux Adaptation
* 适配 Linux 窗口管理器。
* DBus 集成 (MPRIS 支持)。

### Phase 3: Android Mobile
* 适配触摸交互与移动端布局。
* 后台播放服务 (Foreground Service)。
* Android 13+ 媒体通知适配。

## 🎨 资产与资源 (Assets & Resources)

* **App Icon**: 源文件位于 `assets/icon/app_icon.png`。
    * 请使用 `flutter_launcher_icons` 包自动生成所有平台（Windows, Android, Linux）所需的图标文件。
    * 注意：Windows 端需要生成 `.ico` 文件，Android 端需要处理自适应图标（Adaptive Icons）。

---

## 📂 目录结构说明

```text
0rhx_player/
├── android/            # Android 原生宿主
├── assets/             # 静态资源 (字体, 图标)
├── Design/             # [核心] UI设计参考图
│   ├── Desktop/        # Windows/Linux UI 截图
│   ├── Mobile/         # Android UI 截图
│   └── Wear/           # WearOS UI 截图
├── lib/                # Flutter 源码
│   ├── core/           # 通用工具、主题
│   ├── features/       # 功能模块 (播放器, 库, 设置)
│   └── main.dart
├── linux/              # Linux 原生宿主
├── windows/            # Windows 原生宿主
├── pubspec.yaml        # 依赖管理
├── README.md           # 项目说明
└── TODO.md             # [核心] 唯一的进度与任务管理文件