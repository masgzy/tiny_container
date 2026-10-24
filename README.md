<div align="center">

**简体中文** | [English](README_EN.md)

# 小小容器 · Tiny Container

安装小小容器，立刻获得一台 Linux 电脑 —— 在你的手机/平板上直接使用 PC 软件！

> [!NOTE]
> Linux 很强大。Linux 也可以易于使用。

[![Release](https://img.shields.io/github/v/release/Cateners/tiny_container?style=flat&logo=github&label=Release)](https://github.com/Cateners/tiny_container/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/Cateners/tiny_container/total?style=flat&logo=github&label=APK%20Downloads)](https://github.com/Cateners/tiny_container/releases)
[![License](https://img.shields.io/github/license/Cateners/tiny_container?style=flat&logo=gnu&label=License)](COPYING)

[![Stars](https://img.shields.io/github/stars/Cateners/tiny_container?style=flat&logo=github&label=Stars&color=yellow)](https://github.com/Cateners/tiny_container/stargazers)
[![Forks](https://img.shields.io/github/forks/Cateners/tiny_container?style=flat&logo=github&label=Forks)](https://github.com/Cateners/tiny_container/network/members)
[![Issues](https://img.shields.io/github/issues/Cateners/tiny_container?style=flat&logo=github&label=Issues)](https://github.com/Cateners/tiny_container/issues)
[![Discussions](https://img.shields.io/github/discussions/Cateners/tiny_container?style=flat&logo=github&label=Discussions)](https://github.com/Cateners/tiny_container/discussions)

[![Platform](https://img.shields.io/badge/Platform-Android%209%2B-3DDC84?style=flat&logo=android&logoColor=white)](#系统要求)
[![Arch](https://img.shields.io/badge/Arch-arm64--v8a-0091BD?style=flat&logo=arm&logoColor=white)](#系统要求)
[![Code](https://img.shields.io/badge/Code-Kotlin-7F52FF?style=flat&logo=kotlin&logoColor=white)](https://kotlinlang.org/)
[![Powered by](https://img.shields.io/badge/Powered%20by-Termux-000000?style=flat&logo=linux&logoColor=white)](https://github.com/termux/termux-packages)

![预览图](doc/tc4.png)

</div>

## 简介

小小容器（Tiny Container）是一款 Android 应用，基于 Termux 社区成熟的 proot 容器方案，让你无需任何 Linux 基础，即可在手机或平板上一键运行带有完整桌面环境（Xfce）的 Debian 13 系统。安装应用、点击图标，五分钟后你就会坐在一台"Linux 电脑"面前 —— 流畅运行 LibreOffice、GIMP、Firefox 等真正的 PC 软件。

这个项目的目标是让普通用户尽可能轻松地享受 Linux 的乐趣。
众所周知，Termux 对开发者来说简直就是一座宝库，它极大地提升了设备的可玩性。
而开发者之外，鲜有人能意识到自己的设备有如此潜能，所以我希望此项目能降低门槛。

> [!CAUTION]
> 这个项目大量使用 AI。考虑到这个完成度，不使用是不可能的吧...？对吧？
> 包括代码逻辑，布局，翻译等等。可能有些地方有意想不到的 bug。请注意。

## 特性

### 为普通用户设计。你不需要懂 Linux......

1. 安装软件并打开，你不需要进行任何操作*，5 分钟的初始化后立刻进入电脑界面。
2. 常用软件的安装命令已为你准备好。点击，然后软件为你完成剩下的工作。
3. 软件的界面尽可能友好地设计了，而不是"有个界面就行"。让 AI 加上了许多语言的翻译。甚至支持 rtl 布局！
    - （虽然，因为我并不使用 rtl，也看不懂 AI 的翻译，不知道准不准确！但是有总比没有好吧？）

### 同时也是给极客的玩具，内置终端、拥有丰富的容器配置选项！

4. 容器和配置可以随意分享！
5. 取自 Termux 社区的前沿功能已准备就绪！你不需要学习如何安装容器、启动图形界面、配置音频等等繁琐工作。以下功能是即开即用的：
    - 安装容器通过导入按钮，图形界面的启动已包含在内（如果容器支持）；
    - 软件内置 AVNC 和 Termux:X11 前端，你不需要额外安装软件；
    - 音频和麦克风转发；
    - virglrenderer 和 turnip+zink 图形加速...
6. 单软件才方便做到的功能！
    - 音频和 VNC 通过 unix socket 传输，不经过网络栈；
    - 通过 saf 文件管理器浏览容器文件；
    - 可以将 .desktop 文件，甚至一般命令作为快捷方式放置到安卓启动器！
7. 不会和 Termux 冲突！

## 系统要求

| 项目 | 要求 |
| --- | --- |
| 系统版本 | Android 9（API 28）及以上 |
| 设备架构 | arm64-v8a（64 位 ARM） |
| 存储空间 | 需要足够的可用空间用于下载和安装 Debian 容器 |

## 下载安装

APK 安装包见 [Releases](https://github.com/Cateners/tiny_container/releases) 页面。

下载安装后打开应用即可，容器会在首次启动时自动安装，无需手动配置。

## 快速上手

### 首次启动

耐心等待约 5 分钟，系统会自动安装完成并进入图形界面。

你可以点击右上角的按钮为软件授予一些权限：

- 文件访问权限用于允许容器访问安卓存储空间；
- 取消电池优化以减少软件被系统清理的概率。

即使不授予权限，小小容器也能正常使用。

### 图形界面操作（默认触摸板模式）

- 单指滑动控制鼠标；
- 长按触发鼠标右键；
- 双指单击弹出键盘；
- **长按并滑动可以拖拽**。

从图形界面返回，就可以回到小小容器的主界面。在主界面可以进行配置，或者安装更多软件。

### 使用技巧

- 如果屏幕显示太大或太小，可以在功能 -> AVNC 那里调整屏幕缩放比。
- 安卓存储空间默认在 `/mnt/sdcard`。别忘了授予存储访问权限。
- 如果 Linux 应用识别不到麦克风，检查是否选择了麦克风（Tiny Microphone Input），或者尝试重启此 Linux 应用。

## 从源码构建

克隆仓库后，在 Release 页下载预编译库 jniLibs.zip 并解压到 `app/src/main/jniLibs/arm64-v8a`，然后就可以正常在 Android Studio 打开项目编译了。
如果要做到启动时自动安装容器的效果，可把容器重命名为 rootfs.tar.zst 并放到 `app/src/main/assets`。
容器的信息，包括如何制作容器以及一些已经制作好的容器，见 [images 仓库](https://github.com/tiny-computer/images)。

jniLibs.zip 预编译库来自上游作者 fork 的 [termux-packages](https://github.com/tiny-computer/termux-packages) 仓库。
主要修改了：

- `scripts/generate-bootstraps.sh`，以便直接生成需要的包。手动重命名了需要的文件到 so 并将它们打包。你应该能很容易看出这些 so 文件对应 bootstraps 中的哪些文件。
- `packages/proot/build.sh`，为了使用 fork 的 [proot](https://github.com/tiny-computer/proot-termux)（里面的修改有点脏，没什么好看的）。

其他文件可能也有少量修改，但那通常是为了能顺利编译，或者去除一些 termux 路径硬编码。

## 我不会做的事

- 支持 chroot 容器。项目前三年时不时有人让我支持它，理由通常是"性能更好"。
  虽然理论如此，但从来没有人拿出实际对比数据，以及在什么场景下 proot 的慢会成为性能瓶颈。鉴于我没有开发使用 root 的应用的经验（而且感觉管理 root 会非常麻烦），所以我不会支持 chroot。
  总之，如果确实需要，请使用 Termux！如果需要自动的安装配置，可以尝试 Kali Nethunter 等等。
- 支持 mali gpu 加速；支持 wayland；支持 docker, systemd；支持 gnome；支持某某发行版；支持摄像头，串口，......(^-^*)
  不要许愿！如果社区有了解决方案我可能会添加进来。
  关于其他发行版，其实你可以参考 [images 仓库](https://github.com/tiny-computer/images)的说明自行尝试一下。

## 之前的代码呢？

小小电脑（Tiny Computer）的代码保留在 `v1_tiny_computer` 分支。
小小容器是对小小电脑的完全重写，后续应该也不会维护小小电脑了。所以，使用小小容器吧！

## 参与贡献

欢迎参与本项目！

- 遇到 Bug 或有功能建议，请提交 [Issue](https://github.com/Cateners/tiny_container/issues)；
- 使用问题与经验交流，请前往 [Discussions](https://github.com/Cateners/tiny_container/discussions)；
- 欢迎提交 Pull Request，建议先通过 Issue 或 Discussion 讨论方案；
- 容器镜像相关的贡献，请前往 [images 仓库](https://github.com/tiny-computer/images)。

## 致谢

感谢 [termux](https://github.com/termux) 社区移植这么多优秀的程序到安卓，以及提供了相当多的配置容器的各种情况的解决方案。
感谢 [tmoe](https://github.com/2moe/tmoe) 项目让容器配置变得更轻松。虽然这次在小小容器中没有直接用到 tmoe，但有些脚本还是有 tmoe 的影子。tmoe 是我的 linux 启蒙。
感谢 [avnc](https://github.com/gujjwal00/avnc) 项目和 [termux-x11](https://github.com/termux/termux-x11) 项目，这是小小容器使用的 linux 图形界面。
感谢 vinceliuice 的 [Fluent](https://github.com/vinceliuice/Fluent-gtk-theme) 项目，这是 xfce 容器使用的默认主题。
感谢 lxgw 的 [小赖字体](https://github.com/lxgw/kose-font) 项目，这是容器使用的缺省字体。
感谢 [debian](https://www.debian.org/) 项目，以及所有构成容器基础的开源软件维护者！目前项目使用的所有容器都基于 debian。
感谢所有小小电脑（和小小容器）的贡献者，使用者，以及所有相信此项目的你。

## 许可证

本项目基于 [GPL-3.0](COPYING) 协议开源。你可以在遵循该协议的前提下自由地使用、修改和分发本项目。
