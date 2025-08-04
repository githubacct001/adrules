#!/bin/bash

export TZ=Asia/Shanghai  # 设置为北京时间

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

cleaned=$(grep -vE '^(#|//|$)' "$tmp_file" | sort -u)
rule_count=$(echo "$cleaned" | wc -l)

{
  echo "# Merged RuleSet for Surge"
  echo "# Generated on $(date '+%Y-%m-%d %H:%M:%S') (Asia/Shanghai)"
  echo "# Total Rules: $rule_count"
  echo "# Source URLs:"
  for url in "${urls[@]}"; do
    echo "#   $url"
  done
  echo ""
  echo "$cleaned"
} > "$output_file"

rm "$tmp_file"

echo "✅ 合并完成！生成文件：$output_file，总规则数：$rule_count"
