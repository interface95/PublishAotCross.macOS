#!/bin/bash
set -e

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "================================================================"
echo "  PublishAotCross.macOS - Windows 交叉编译环境安装"
echo "  macOS → Windows"
echo "================================================================"
echo

# 检查是否在 macOS 上运行
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}错误: 此脚本只能在 macOS 上运行${NC}"
    exit 1
fi

echo -e "${BLUE}[1/5]${NC} 检查 Homebrew..."
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}→ 安装 Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 根据架构添加 Homebrew 到 PATH
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    echo -e "${GREEN}✓ Homebrew 安装完成${NC}"
else
    echo -e "${GREEN}✓ Homebrew 已安装${NC}"
fi
echo

echo -e "${BLUE}[2/5]${NC} 安装 .NET SDK..."
if ! command -v dotnet &> /dev/null; then
    echo -e "${YELLOW}→ 安装 .NET SDK...${NC}"
    brew install --cask dotnet-sdk
    echo -e "${GREEN}✓ .NET SDK 安装完成${NC}"
else
    DOTNET_VERSION=$(dotnet --version)
    echo -e "${GREEN}✓ .NET SDK 已安装 (版本: $DOTNET_VERSION)${NC}"
fi
echo

echo -e "${BLUE}[3/5]${NC} 安装 LLVM (lld-link)..."
if ! command -v lld-link &> /dev/null; then
    echo -e "${YELLOW}→ 安装 LLVM...${NC}"
    brew install lld
    
    # 添加到 PATH
    LLD_PATH="$(brew --prefix lld)/bin"
    export PATH="$LLD_PATH:$PATH"
    
    # 添加到 shell 配置
    if [[ $SHELL == *"zsh"* ]]; then
        if ! grep -q "lld/bin" ~/.zshrc 2>/dev/null; then
            echo 'export PATH="$(brew --prefix lld)/bin:$PATH"' >> ~/.zshrc
        fi
    else
        if ! grep -q "lld/bin" ~/.bash_profile 2>/dev/null; then
            echo 'export PATH="$(brew --prefix lld)/bin:$PATH"' >> ~/.bash_profile
        fi
    fi
    
    echo -e "${GREEN}✓ lld-link 安装完成${NC}"
else
    echo -e "${GREEN}✓ lld-link 已安装${NC}"
fi
echo

echo -e "${BLUE}[4/5]${NC} 安装 Rust 和 xwin..."
if ! command -v cargo &> /dev/null; then
    echo -e "${YELLOW}→ 安装 Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}✓ Rust 安装完成${NC}"
else
    echo -e "${GREEN}✓ Rust 已安装${NC}"
    source $HOME/.cargo/env 2>/dev/null || true
fi

if ! command -v xwin &> /dev/null; then
    echo -e "${YELLOW}→ 安装 xwin...${NC}"
    cargo install --locked xwin
    echo -e "${GREEN}✓ xwin 安装完成${NC}"
else
    echo -e "${GREEN}✓ xwin 已安装${NC}"
fi
echo

echo -e "${BLUE}[5/5]${NC} 下载 Windows SDK..."
if [ ! -d "$HOME/.local/share/xwin-sdk/crt" ]; then
    echo -e "${YELLOW}→ 下载 Windows SDK (需要 5-10 分钟，请耐心等待)...${NC}"
    mkdir -p $HOME/.local/share/xwin-sdk
    xwin --accept-license splat --output $HOME/.local/share/xwin-sdk
    echo -e "${GREEN}✓ Windows SDK 下载完成${NC}"
    echo "SDK 大小: $(du -sh $HOME/.local/share/xwin-sdk | cut -f1)"
else
    echo -e "${GREEN}✓ Windows SDK 已存在${NC}"
    echo "SDK 大小: $(du -sh $HOME/.local/share/xwin-sdk | cut -f1)"
fi
echo

echo "================================================================"
echo -e "${GREEN}  ✓ Windows 交叉编译环境安装完成！${NC}"
echo "================================================================"
echo

# 显示版本信息
echo "=== 已安装工具 ==="
echo "✓ Homebrew: $(brew --version | head -1)"
echo "✓ .NET SDK: $(dotnet --version)"
echo "✓ lld-link: $(lld-link --version 2>&1 | head -1)"
echo "✓ Rust: $(rustc --version)"
echo "✓ xwin: $(xwin --version 2>&1 | head -1)"
echo

echo "=== 支持的交叉编译目标 ==="
echo "Windows: win-x64, win-arm64, win-x86"
echo

echo "=== 快速开始 ==="
echo "1. 在你的项目中添加 NuGet 包:"
echo "   dotnet add package PublishAotCross.macOS --version 1.0.2-preview"
echo
echo "2. 编译到 Windows x64:"
echo "   dotnet publish -r win-x64 -c Release"
echo
echo "3. 编译到 Windows ARM64:"
echo "   dotnet publish -r win-arm64 -c Release"
echo

echo "================================================================"
echo -e "${YELLOW}提示: 重新打开终端或运行以下命令使环境变量生效:${NC}"
if [[ $SHELL == *"zsh"* ]]; then
    echo "  source ~/.zshrc"
else
    echo "  source ~/.bash_profile"
fi
echo "================================================================"

