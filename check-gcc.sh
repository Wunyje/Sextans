#!/bin/bash
echo "=== 检查默认编译器 ==="
echo "gcc -> $(which gcc)"
gcc --version | head -n 1
echo "g++ -> $(which g++)"
g++ --version | head -n 1

echo
echo "=== 检查 Sextans 编译器信息 (.comment section) ==="
if [ -f build/sextans ]; then
  readelf -p .comment build/sextans | grep GCC || echo "未找到 GCC 编译信息"
else
  echo "未找到 build/sextans 可执行文件"
fi

echo
echo "=== 检查 Sextans 链接的 libstdc++ 版本 ==="
if [ -f build/sextans ]; then
  ldd build/sextans | grep libstdc++
else
  echo "未找到 build/sextans 可执行文件"
fi

echo
echo "=== 系统已安装的 libstdc++ 包 ==="
dpkg -l | grep libstdc++

echo
echo "=== 检查 libstdc++.so.6 符号链接和来源包 ==="
LIBSTDCPP=$(readlink -f /lib/x86_64-linux-gnu/libstdc++.so.6)
echo "libstdc++.so.6 -> $LIBSTDCPP"
dpkg -S $LIBSTDCPP 2>/dev/null || echo "dpkg 未找到对应包（可能是符号链接）"

echo
echo "=== 检查 libstdc++.so.6 支持的 GLIBCXX 符号版本 ==="
strings $LIBSTDCPP | grep GLIBCXX_ | sort -V | tail -n 10
