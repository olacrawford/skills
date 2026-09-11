#!/usr/bin/env bash
# 将本目录(唯一源)下的 10 个通用 Skill 同步到目标项目的 .agents/skills/。
#
# 用法:
#   ./sync-to-project.sh <项目路径> [更多项目路径...]
# 示例:
#   ./sync-to-project.sh ~/code/order-service ~/code/user-center
#
# 说明:
#   - 只同步本库的 10 个 Skill 目录,不影响项目 .agents/skills/ 里的其他 Skill;
#   - 每个 Skill 目录内部与源对齐(--delete),源里删掉的文件同步后也会删掉;
#   - 修改 Skill 只改本目录,改完执行本脚本分发,不直接改项目里的副本。

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS=(
  codebase-understanding
  code-writer
  bug-finder
  bug-fixer
  code-reviewer
  test-writer
  refactor
  performance
  security-reviewer
  architecture-reviewer
)

if [ $# -lt 1 ]; then
  echo "用法: $0 <项目路径> [更多项目路径...]"
  echo "示例: $0 ~/code/order-service"
  exit 1
fi

# 源完整性自检:10 个 Skill 必须都存在且含 SKILL.md
missing=0
for skill in "${SKILLS[@]}"; do
  if [ ! -f "$SOURCE_DIR/$skill/SKILL.md" ]; then
    echo "错误:源 Skill 缺失 $SOURCE_DIR/$skill/SKILL.md" >&2
    missing=1
  fi
done
[ "$missing" -eq 1 ] && exit 1

for project in "$@"; do
  if [ ! -d "$project" ]; then
    echo "跳过:项目不存在 $project"
    continue
  fi

  # 防呆:误建了单数 .agents/skill 时提示(ZCode 不会发现)
  if [ -d "$project/.agents/skill" ] && [ ! -d "$project/.agents/skills" ]; then
    echo "警告:$project/.agents/skill 目录名少了 s,ZCode 不会发现,请改名为 .agents/skills" >&2
  fi

  target="$project/.agents/skills"
  mkdir -p "$target"

  for skill in "${SKILLS[@]}"; do
    rsync -a --delete "$SOURCE_DIR/$skill/" "$target/$skill/"
  done

  echo "已同步 ${#SKILLS[@]} 个 Skill → $target"
done
