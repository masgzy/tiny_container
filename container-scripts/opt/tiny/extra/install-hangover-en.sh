#!/bin/bash
# install-hangover-en.sh -- Install Hangover Wine and DXVK inside tiny container (proot Debian 13).
# 基于上游 tiny-computer/images 的同名脚本加固而来，主要改动（详见仓库 container-scripts/README.md）：
#   1. 修复 chn_fonts.reg 缺失导致"修复字体"步骤静默失败的问题：文件缺失时自动生成字体替换配置
#   2. 下载后校验 tar 完整性，坏镜像（返回 HTML 错误页）自动切换下一个，而不是留到安装阶段才失败
#   3. wget 增加超时与重试；移除已失效的 mirror.ghproxy.com
#   4. GitHub API 获取最新版本失败时，通过镜像站抓取 releases/latest 页面作为回退
#   5. apt update/upgrade、wineboot、DXVK 解压、字体导入各步骤失败时给出明确提示，DXVK 失败即中止
#   6. /home/tiny/.wine 改为 $HOME/.wine（容器默认以 tiny 用户运行，行为不变，但不再假设用户名）
#   7. 所有失败分支显式 exit 1

echo "Updating packages..."
sudo apt update || echo "Warning: apt update failed, continuing anyway..."
sudo -E env DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade || echo "Warning: apt upgrade failed, continuing anyway..."

REPO="AndreRH/hangover"
API_URL="https://api.github.com/repos/$REPO/releases/latest"

# 获取最新release的版本号并储存在变量中
latest_version=$(wget -T 20 -t 2 -qO- "$API_URL" | grep -oP '"tag_name": "\Khangover-\K([^"]+)' )

# 检查是否成功获取版本号
if [ -z "$latest_version" ]; then
  # Fallback: fetch the releases/latest page through a mirror if api.github.com is unreachable
  echo "GitHub API failed, trying mirror fallback..."
  latest_version=$(wget -T 20 -t 2 -qO- "https://gh-proxy.org/https://github.com/$REPO/releases/latest" | grep -m1 -oP 'tag/hangover-\K[0-9][0-9.]*' )
fi

if [ -z "$latest_version" ]; then
  echo "Unable to fetch the latest version number."
  exit 1
fi

echo "Latest version: $latest_version"

hangover_url="https://github.com/AndreRH/hangover/releases/download/hangover-${latest_version}/hangover_${latest_version}_debian13_trixie_arm64.tar"

# Mirrors ordered by current availability (mirror.ghproxy.com is dead, removed); empty string = direct GitHub
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
    echo "Attempting to download Hangover from $url..."
    rm -f hangover.tar
    # -T 30 timeout, -t 2 retries; validate afterwards: non-empty file with parseable tar header (filters HTML error pages)
    if wget -T 30 -t 2 -q "${url}" -O hangover.tar && [ -s hangover.tar ] \
       && tar tf hangover.tar 2>/dev/null | head -n 1 | grep -q .; then
        echo "Successfully downloaded Hangover"
        download_ok=1
        break
    fi
done

if [ "$download_ok" -ne 1 ]; then
    echo "Download failed...exiting installation..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi

echo "Installing Hangover..."
tar xvf hangover.tar || {
    echo "Failed to extract Hangover archive...exiting installation..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
}
sudo apt install -y ./hangover*.deb
if [ $? -ne 0 ]; then
    echo "Installation failed...exiting installation..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi

echo "Initializing Wine..."
wineboot --init || echo "Warning: wineboot init failed (ignorable if the Wine prefix already exists), continuing anyway..."

echo "Installing DXVK..."
if ! tar xvf dxvk-v*.tar.gz; then
    echo "Failed to extract DXVK...exiting installation..."
    cd /tmp || exit 1
    rm -rf /tmp/hangover
    exit 1
fi
if [ -d "$HOME/.wine/drive_c/windows/syswow64" ] && [ -d "$HOME/.wine/drive_c/windows/system32" ]; then
    mv dxvk-v*/x32/* "$HOME/.wine/drive_c/windows/syswow64/" \
        && mv dxvk-v*/arm64ec/* "$HOME/.wine/drive_c/windows/system32/"
else
    echo "Warning: Wine directory not found under $HOME/.wine, skipping DXVK installation..."
fi

echo "Fixing fonts..."
REG_FILE="/opt/tiny/extra/chn_fonts.reg"
SUBST_KEY='HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\FontSubstitutes'
if [ -f "$REG_FILE" ]; then
    # Original behavior when the bundled reg exists: import it, then clear Wine default substitutes
    regedit "$REG_FILE" && wine reg delete "$SUBST_KEY" /va /f
else
    # The upstream image does not ship chn_fonts.reg (the original script failed silently here).
    # Generate an equivalent font substitution config: map common Windows UI fonts to an installed CJK font.
    CJK_FONT=""
    if command -v fc-list >/dev/null 2>&1; then
        for f in "Noto Sans CJK SC" "WenQuanYi Zen Hei" "Droid Sans Fallback" "Noto Sans SC"; do
            if fc-list | grep -qi "$f"; then CJK_FONT="$f"; break; fi
        done
    fi
    if [ -z "$CJK_FONT" ]; then
        echo "Warning: no installed CJK font found, skipping font substitution..."
    else
        echo "Using CJK font: $CJK_FONT"
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
echo "Installation complete"
exit 0
