#!/bin/bash
# Skills 安装脚本 - 通过 junction 链接 skill 目录到各 CLI 工具
# 一次运行，后续源文件更新自动同步，无需再复制

# ===== 目标配置 =====
# 取消注释对应行即可启用；注释掉即跳过
TARGETS=(
    "$HOME/.claude/skills"       # Claude Code
    # "$HOME/.codex/skills"      # Codex（安装后取消注释并修改路径）
)

# 排除的目录
EXCLUDE=(".git" ".claude" ".github" "bmad")

# 获取脚本所在目录（源目录）
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Skills source: $SOURCE_DIR"
echo ""

for target in "${TARGETS[@]}"; do
    echo "=== Target: $target ==="

    if [ ! -d "$target" ]; then
        mkdir -p "$target"
        echo "  Created: $target"
    fi

    for skill_dir in "$SOURCE_DIR"/*/; do
        skill_name=$(basename "$skill_dir")

        # 跳过排除目录
        skip=false
        for ex in "${EXCLUDE[@]}"; do
            if [ "$skill_name" = "$ex" ]; then skip=true; break; fi
        done
        if $skip; then continue; fi

        link_path="$target/$skill_name"

        # 已存在则跳过
        if [ -e "$link_path" ] || [ -L "$link_path" ]; then
            echo "  SKIP $skill_name (already exists)"
            continue
        fi

        # Windows (Git Bash): 用 mklink /J 创建 junction
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
            # 转换为 Windows 路径
            win_source=$(cygpath -w "$skill_dir")
            win_target=$(cygpath -w "$link_path")
            cmd //c "mklink /J \"$win_target\" \"${win_source%\\\\}\"" > /dev/null 2>&1
        else
            # macOS / Linux: 用 symlink
            ln -s "$skill_dir" "$link_path"
        fi

        if [ -e "$link_path" ]; then
            echo "  OK   $skill_name"
        else
            echo "  FAIL $skill_name"
        fi
    done

    echo ""
done

echo "Done. Skill updates will sync automatically."
