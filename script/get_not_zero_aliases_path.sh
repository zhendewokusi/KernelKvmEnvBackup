#!/bin/bash

# 遍历 /sys/kernel/slab/ 目录下的所有子目录
for dir in /sys/kernel/slab/*; do
    # 检查 aliases 文件是否存在
    if [ -f "$dir/aliases" ]; then
        # 读取 aliases 文件的内容
        alias_value=$(cat "$dir/aliases")
        # 如果内容不是 0，则输出该文件的完整路径
        if [ "$alias_value" -ne 0 ]; then
            echo "$dir/aliases"
        fi
    fi
done

