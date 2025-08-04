#!/bin/bash

# 可配置 rule-set 源
urls=(
  "https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules.list"
  "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Surge-RULE-SET.list"
)

tmp_file=$(mktemp)
output_file="merged-ruleset.list"

> "$tmp_file"

echo "开始下载并合并规则..."

for url in "${urls[@]}"; do
  echo "下载 $url"
  curl -s "$url" >> "$tmp_file"
done

echo "处理规则，去注释、去重..."

{
  echo "# Merged RuleSet for Surge"
  echo "# Generated on $(date '+%Y-%m-%d %H:%M:%S')"
  echo "# Source URLs:"
  for url in "${urls[@]}"; do
    echo "#   $url"
  done
  echo ""
  grep -vE '^(#|//|$)' "$tmp_file" | sort -u
} > "$output_file"

rm "$tmp_file"

echo "✅ 合并完成：$output_file"