#!/bin/bash

# 批量为 Dart 文件添加响应式适配
# 使用 sed 进行文本替换

set -e

echo "开始批量改造 Dart 文件为响应式..."

# 定义要处理的目录
DIRS=(
  "/workspace/lib/features/user"
  "/workspace/lib/features/messages"
  "/workspace/lib/features/events"
  "/workspace/lib/features/expenses"
  "/workspace/lib/features/settings"
  "/workspace/lib/features/auth"
)

# 计数器
total_files=0
processed_files=0

# 遍历每个目录
for dir in "${DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "目录不存在: $dir"
    continue
  fi
  
  # 查找所有 .dart 文件
  while IFS= read -r file; do
    total_files=$((total_files + 1))
    
    # 检查文件是否已经导入了 responsive_extensions
    if grep -q "responsive_extensions.dart" "$file"; then
      echo "跳过已适配: $file"
      continue
    fi
    
    # 检查文件是否包含需要适配的模式
    if ! grep -Eq "(const EdgeInsets\.|const SizedBox\(|fontSize:\s*[0-9]|BorderRadius\.circular\([0-9]|width:\s*[0-9]|height:\s*[0-9])" "$file"; then
      echo "跳过无需适配: $file"
      continue
    fi
    
    echo "处理文件: $file"
    
    # 创建备份
    cp "$file" "${file}.bak"
    
    # 1. 在 import 'package:flutter/material.dart'; 后添加响应式导入
    sed -i "/import 'package:flutter\/material.dart';/a import 'package:crew_app/shared/utils/responsive_extensions.dart';" "$file"
    
    # 2. 替换常见的硬编码模式
    # EdgeInsets
    sed -i 's/const EdgeInsets\.all(\([0-9]\+\))/EdgeInsets.all(\1.r)/g' "$file"
    sed -i 's/const EdgeInsets\.symmetric(horizontal: \([0-9]\+\))/EdgeInsets.symmetric(horizontal: \1.w)/g' "$file"
    sed -i 's/const EdgeInsets\.symmetric(vertical: \([0-9]\+\))/EdgeInsets.symmetric(vertical: \1.h)/g' "$file"
    sed -i 's/const EdgeInsets\.symmetric(horizontal: \([0-9]\+\), vertical: \([0-9]\+\))/EdgeInsets.symmetric(horizontal: \1.w, vertical: \2.h)/g' "$file"
    sed -i 's/const EdgeInsets\.fromLTRB(\([0-9]\+\), \([0-9]\+\), \([0-9]\+\), \([0-9]\+\))/EdgeInsets.fromLTRB(\1.w, \2.h, \3.w, \4.h)/g' "$file"
    
    # SizedBox
    sed -i 's/const SizedBox(width: \([0-9]\+\))/SizedBox(width: \1.w)/g' "$file"
    sed -i 's/const SizedBox(height: \([0-9]\+\))/SizedBox(height: \1.h)/g' "$file"
    sed -i 's/const SizedBox(width: \([0-9]\+\), height: \([0-9]\+\))/SizedBox(width: \1.w, height: \2.h)/g' "$file"
    
    # BorderRadius
    sed -i 's/BorderRadius\.circular(\([0-9]\+\))/BorderRadius.circular(\1.r)/g' "$file"
    
    # fontSize
    sed -i 's/fontSize: \([0-9]\+\),/fontSize: \1.sp,/g' "$file"
    
    # width 和 height (单独的属性)
    sed -i 's/width: \([0-9]\+\),/width: \1.w,/g' "$file"
    sed -i 's/height: \([0-9]\+\),/height: \1.h,/g' "$file"
    
    # size (图标等)
    sed -i 's/size: \([0-9]\+\),/size: \1.sp,/g' "$file"
    
    processed_files=$((processed_files + 1))
    echo "✓ 已处理: $file"
    
  done < <(find "$dir" -name "*.dart" -type f)
done

echo ""
echo "========================================="
echo "批量改造完成！"
echo "总文件数: $total_files"
echo "已处理: $processed_files"
echo "========================================="
echo ""
echo "请运行以下命令检查："
echo "  flutter analyze"
echo ""
echo "如果发现问题，可以使用 .bak 备份文件恢复"
