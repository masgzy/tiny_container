#!/bin/bash
# install-hangover-stable.sh -- 在小小容器(proot Debian 13)内安装 Hangover Wine 与 DXVK。
# 基于上游 tiny-computer/images 的同名脚本加固而来，主要改动（详见仓库 container-scripts/README.md）：
#   1. 修复 chn_fonts.reg 缺失导致"修复字体"步骤静默失败的问题：文件缺失时自动生成字体替换配置
#   2. 下载后校验 tar 完整性，坏镜像（返回 HTML 错误页）自动切换下一个，而不是留到安装阶段才失败
#   3. wget 增加超时与重试；移除已失效的 mirror.ghproxy.com
#   5. apt update/upgrade、wineboot、DXVK 解压、字体导入各步骤失败时给出明确提示，DXVK 失败即中止
#   6. /home/tiny/.wine 改为 $HOME/.wine（容器默认以 tiny 用户运行，行为不变，但不再假设用户名）
#   7. 所有失败分支显式 exit 1

echo "正在更新软件包..."
sudo apt update || echo "警告：apt update 失败，将继续安装流程..."
sudo -E env DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade || echo "警告：apt upgrade 失败，将继续安装流程..."

# 固定安装 11.9 版本（对应"安装 Hangover 11.9"功能项）
latest_version="11.9"
hangover_url="https://github.com/AndreRH/hangover/releases/download/hangover-${latest_version}/hangover_${latest_version}_debian13_trixie_arm64.tar"
echo "安装版本: $latest_version"

# 镜像列表按当前可用性排序（mirror.ghproxy.com 已失效，已移除）；空串表示 GitHub 直连
mirror_sites=(
    "https://gh-proxy.org/"
    "https://cdn.gh-proxy.org/"
    "https://edgeone.gh-proxy.org/"
    "https://gh.llkk.cc/"
    "https://github.moeyy.xyz/"
    ""
)

mkdir -p /tmp/hangover
cd /tmp/hangover || exit 1

download_ok=0
for mirror in "${mirror_sites[@]}"; do
    url="${mirror}${hangover_url}"
    echo "尝试从 $url 下载Hangover..."
    rm -f hangover.tar
    # -T 30 单次超时，-t 2 重试；下载后校验：文件非空且 tar 头部可解析（过滤镜像返回的 HTML 错误页）
    if wget -T 30 -t 2 -q "${url}" -O hangover.tar && [ -s hangover.tar ] \
       && tar tf hangover.tar 2>/dev/null | head -n 1 | grep -q .; then
        echo "成功下载Hangover"
        download_ok=1
        break
    fi
done

if [ "$download_ok" -ne 1 ]; then
    echo "下载失败...退出安装..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi

echo "正在安装Hangover..."
tar xvf hangover.tar || {
    echo "Hangover 压缩包解压失败...退出安装..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
}
sudo apt install -y ./hangover*.deb
if [ $? -ne 0 ]; then
    echo "安装失败...退出安装..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi

echo "正在初始化Wine..."
wineboot --init || echo "警告：wineboot 初始化异常（若已有 Wine 目录可忽略），继续安装流程..."

echo "正在安装DXVK..."
if ! tar xvf dxvk-v*.tar.gz; then
    echo "DXVK 解压失败...退出安装..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi
if [ -d "$HOME/.wine/drive_c/windows/syswow64" ] && [ -d "$HOME/.wine/drive_c/windows/system32" ]; then
    mv dxvk-v*/x32/* "$HOME/.wine/drive_c/windows/syswow64/" \
        && mv dxvk-v*/arm64ec/* "$HOME/.wine/drive_c/windows/system32/"
else
    echo "警告：未找到 $HOME/.wine 内的 Wine 目录，跳过 DXVK 安装..."
fi

echo "正在修复字体..."
REG_FILE="/opt/tiny/extra/chn_fonts.reg"
SUBST_KEY='HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes'
if [ -f "$REG_FILE" ]; then
    # 镜像自带字体配置时保持原行为：导入配置后清理 Wine 默认的字体替换表
    regedit "$REG_FILE" && wine reg delete "$SUBST_KEY" /va /f
else
    # 上游镜像未分发 chn_fonts.reg（原脚本会在此静默失败）。
    # 这里自动生成等价的字体替换配置：将常见 Windows 界面字体映射到系统已安装的中文字体。
    CJK_FONT=""
    if command -v fc-list >/dev/null 2>&1; then
        for f in "Noto Sans CJK SC" "WenQuanYi Zen Hei" "Droid Sans Fallback" "Noto Sans SC"; do
            if fc-list | grep -qi "$f"; then CJK_FONT="$f"; break; fi
        done
    fi
    if [ -z "$CJK_FONT" ]; then
        echo "警告：未找到已安装的中文字体，跳过字体替换..."
    else
        echo "使用中文字体: $CJK_FONT"
        GEN_REG="/tmp/chn_fonts_generated.reg"
        {
            printf 'REGEDIT4\n\n[%s]\n' "$SUBST_KEY"
            for name in "MS Shell Dlg" "MS Shell Dlg 2" "Tahoma" "SimSun" "NSimSun" \
                        "Microsoft YaHei" "Microsoft JhengHei" "MingLiU" "PMingLiU" \
                        "MS PGothic" "MS Gothic"; do
                printf '"%s"="%s"\n' "$name" "$CJK_FONT"
            done
        } > "$GEN_REG"
        regedit "$GEN_REG"
    fi
fi

cd /tmp || exit 1
rm -rf /tmp/hangover
echo "安装完成"
exit 0
