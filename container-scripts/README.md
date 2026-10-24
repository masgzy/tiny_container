# container-scripts — 容器侧脚本审查与加固

本目录存放对上游镜像仓库 [tiny-computer/images](https://github.com/tiny-computer/images) 中
`opt/tiny/extra/` 脚本的**审查结论与加固版本**。这些脚本运行在容器内部（不是 App 构建的一部分），
原样保留镜像内路径 `opt/tiny/extra/` 以便对照或向上游提交 PR。

## 审查对象

| 文件 | 用途 |
|------|------|
| `install-hangover.sh` | 安装 Hangover 最新版（Wine + DXVK），对应镜像功能"运行 Windows 软件 → 安装 Hangover 最新版" |
| `install-hangover-stable.sh` | 安装固定版本 Hangover 11.9 |
| `install-hangover-en.sh` | 英文提示的变体 |

## 发现的问题

### 1.（严重）`chn_fonts.reg` 缺失，"修复字体"步骤静默失败

三个脚本均引用 `/opt/tiny/extra/chn_fonts.reg`：

```bash
regedit "Z:\\opt\\tiny\\extra\\chn_fonts.reg" && wine reg delete "HKEY_LOCAL_MACHINE\\...\\FontSubstitutes" /va /f
```

但整个上游镜像仓库（共 21 个文件）**不存在任何 `.reg` 文件**。脚本无错误处理，regedit 失败后
`&&` 链中断，脚本继续打印"安装完成"——字体替换从未生效，且用户无从得知。
（已通过 GitHub API 全树检索确认：`git/trees?recursive=1` 中无 `.reg`、无 font 相关文件。）

**修复**：`chn_fonts.reg` 存在时保持原行为；缺失时自动生成等价配置——检测系统已安装的 CJK 字体
（Noto Sans CJK SC → WenQuanYi Zen Hei → Droid Sans Fallback），将常见 Windows 界面字体
（MS Shell Dlg、Tahoma、SimSun 等）替换到该字体并导入。

### 2.（高）镜像站返回垃圾内容时不切换下一个镜像

`wget` 对返回 HTTP 200 + HTML 错误页的镜像站判定为"成功"即 `break`，坏文件留到
`tar xvf` / `apt install` 阶段才失败，脚本直接退出（其实后续镜像可能可用）。

**修复**：每轮下载后校验"文件非空 + tar 头可解析"，不通过则继续尝试下一个镜像；
全部失败才退出并清理。

### 3.（中）wget 无超时/重试；死镜像未清理

- 原脚本 `wget` 无 `-T`/`-t`，网络半死时会长时间挂起；
- `mirror.ghproxy.com` 域名已失效（实测超时），白白多等一轮。

**修复**：`wget -T 30 -t 2`（版本号请求 `-T 20`）；移除死镜像，保留实测可用的
gh-proxy.org / cdn.gh-proxy.org / edgeone.gh-proxy.org / gh.llkk.cc / github.moeyy.xyz，直连兜底。

### 4.（中）GitHub API 获取版本号单点依赖

`api.github.com` 在部分网络不可达时脚本直接失败。

**修复**：API 失败后，回退到经镜像站抓取 `releases/latest` 页面解析 tag。

### 5.（低）多处失败路径静默继续

- `sudo apt update` / `apt upgrade` 失败不提示，后续 dpkg 半配置状态会让安装步骤报出难懂的错；
- `wineboot --init` 失败后，DXVK 的 `mv` 目标目录不存在，又是静默失败；
- DXVK 解压失败不中止。

**修复**：各步骤失败时输出明确警告；DXVK 解压失败即中止（exit 1）；
`mv` 前检查 `$HOME/.wine/drive_c/windows/{syswow64,system32}` 存在。

### 6.（低）硬编码 `/home/tiny/.wine`

容器 boot_command 以 uid 1000（tiny）运行，`$HOME` 即 `/home/tiny`，行为等价；
改为 `$HOME/.wine` 后不再假设用户名。

### 7.（低）`exit` 未显式给码、`cd` 无防护

下载失败分支 `exit` 继承 wget 退出码（恰好非零，但意图不明）；`cd /tmp/hangover` 无失败防护。
已统一为显式 `exit 0/1` 与 `cd ... || exit 1`。

## 已核实无误的部分

- 版本提取正则 `'"tag_name": "\Khangover-\K([^"]+)'` 虽然写了两个 `\K`，实测（GNU grep 2.39+）
  输出的正是纯版本号（如 `11.16`），URL 拼接正确；
- hangover release tar 内部为顶层 4 个 `.deb` + `dxvk-v*.tar.gz`，`./hangover*.deb`、
  `dxvk-v*/x32`、`dxvk-v*/arm64ec` 的解压/安装路径均与实际资产结构一致（hangover-11.16 实测）；
- 容器以 `HOME=/home/tiny USER=tiny`（uid 1000）运行，脚本内 `sudo` 可用，无提权问题。

## 使用方式

这些脚本属于**容器镜像内容**（`/opt/tiny/extra/`），不参与 App 构建。可：
1. 手动拷入容器对应路径替换原脚本；
2. 或以此为基础向 tiny-computer/images 提交 PR。
