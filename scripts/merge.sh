#!/bin/bash

export TZ=Asia/Shanghai  # 设置为北京时间

urls=(
  "https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules.list"
  "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Surge-RULE-SET.list"
  "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-surge.txt"
)

tmp_file=$(mktemp)
output_file="merged-ruleset.list"

> "$tmp_file"

echo "开始下载并合并规则..."

for url in "${urls[@]}"; do
  echo "下载 $url"
  curl -s "$url" >> "$tmp_file"
done

echo "初步处理规则..."

# 去除注释和空行，初步去重
cleaned=$(grep -vE '^(#|//|$)' "$tmp_file" | sort -u)
echo "$cleaned" > "$tmp_file.processed"

# 提取 DOMAIN-SUFFIX 和 DOMAIN
suffixes=$(grep '^DOMAIN-SUFFIX,' "$tmp_file.processed" | cut -d',' -f2)
domains=$(grep '^DOMAIN,' "$tmp_file.processed")

# 准备保存最终规则
> "$tmp_file.filtered"

# 先保留非 DOMAIN/DOMAIN-SUFFIX 的规则
grep -Ev '^(DOMAIN|DOMAIN-SUFFIX),' "$tmp_file.processed" >> "$tmp_file.filtered"

# 保留所有 DOMAIN-SUFFIX
grep '^DOMAIN-SUFFIX,' "$tmp_file.processed" >> "$tmp_file.filtered"

# 保留未被 DOMAIN-SUFFIX 覆盖的 DOMAIN
while IFS= read -r domain_rule; do
  domain_name=$(echo "$domain_rule" | cut -d',' -f2)
  keep=true
  for suffix in $suffixes; do
    if [[ "$domain_name" == *.$suffix ]]; then
      keep=false
      break
    fi
  done
  $keep && echo "$domain_rule" >> "$tmp_file.filtered"
done <<< "$domains"

# 去重并输出到变量
cleaned=$(sort -u "$tmp_file.filtered")
rule_count=$(echo "$cleaned" | wc -l)

# 写入最终文件
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

# 清理临时文件
rm "$tmp_file" "$tmp_file.processed" "$tmp_file.filtered"

echo "✅ 合并完成！生成文件：$output_file，总规则数：$rule_count"
