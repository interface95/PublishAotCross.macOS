#!/bin/bash

# 修复 xwin SDK 缺失的 x64 库文件
# Fix missing x64 library files in xwin SDK
#
# 使用方法 / Usage:
#   chmod +x fix-xwin-libs.sh
#   ./fix-xwin-libs.sh

set -e  # 遇到错误立即退出

echo "================================================"
echo "修复 xwin SDK x64 库文件"
echo "Fixing xwin SDK x64 library files"
echo "================================================"
echo ""

# 检查 xwin SDK 目录是否存在
XWIN_DIR="$HOME/.local/share/xwin-sdk"
if [ ! -d "$XWIN_DIR/splat" ]; then
    echo "❌ 错误: 未找到 xwin SDK"
    echo "   Error: xwin SDK not found at $XWIN_DIR/splat"
    echo ""
    echo "请先下载 Windows SDK："
    echo "Please download Windows SDK first:"
    echo ""
    echo "  xwin --accept-license \\"
    echo "    --cache-dir $XWIN_DIR \\"
    echo "    --arch x86_64,aarch64 \\"
    echo "    splat --preserve-ms-arch-notation"
    echo ""
    exit 1
fi

# 创建 x64 目录（如果不存在）
mkdir -p "$XWIN_DIR/splat/crt/lib/x64"

echo "从 arm64 复制缺失的库文件到 x64..."
echo "Copying missing libraries from arm64 to x64..."
echo ""

# 复制库文件
LIBS=("libcmt" "oldnames" "libcpmt")
for lib in "${LIBS[@]}"; do
    src="$XWIN_DIR/splat/crt/lib/arm64/${lib}.lib"
    dst="$XWIN_DIR/splat/crt/lib/x64/${lib}.lib"
    
    if [ -f "$src" ]; then
        echo "  ✓ 复制 ${lib}.lib"
        cp "$src" "$dst"
        
        # 创建大写版本的符号链接
        upper_lib=$(echo "$lib" | tr '[:lower:]' '[:upper:]')
        ln -sf "${lib}.lib" "$XWIN_DIR/splat/crt/lib/x64/${upper_lib}.lib"
    else
        echo "  ⚠ 警告: $src 不存在，跳过"
    fi
done

echo ""
echo "================================================"
echo "✅ 修复完成！检查结果："
echo "✅ Fix completed! Checking results:"
echo "================================================"
echo ""

cd "$XWIN_DIR/splat/crt/lib/x64/"
ls -lh | grep -i "libcmt\|oldnames\|libcpmt" || echo "未找到文件 / No files found"

echo ""
echo "现在可以编译了："
echo "Now you can build:"
echo ""
echo "  cd your-project"
echo "  dotnet publish -r win-x64 -c Release"
echo ""

