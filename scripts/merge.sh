#!/bin/bash

export TZ=Asia/Shanghai  # 设置为北京时间

# 要合并的规则链接
urls=(
  "https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules.list"
  "https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Surge-RULE-SET.list"
  "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-surge.txt"
)

# 要排除的规则链接（白名单）
exclude_urls=(
  "https://raw.githubusercontent.com/githubacct001/adrules/refs/heads/main/white.list"
)

tmp_file=$(mktemp)
exclude_tmp=$(mktemp)
output_file="merged-ruleset.list"

> "$tmp_file"

echo "📥 下载并合并规则中..."

for url in "${urls[@]}"; do
  echo "  - 下载 $url"
  curl -s "$url" >> "$tmp_file"
done

echo "🔍 清理注释与空行..."
cleaned=$(grep -vE '^(#|//|$)' "$tmp_file" | sort -u)
echo "$cleaned" > "$tmp_file.processed"

# 下载排除规则（白名单）
echo "🚫 下载排除规则..."
> "$exclude_tmp"
for ex_url in "${exclude_urls[@]}"; do
  echo "  - 排除来源 $ex_url"
  curl -s "$ex_url" >> "$exclude_tmp"
done

# exclude_rules=$(grep -vE '^(#|//|$)' "$exclude_tmp" | sort -u)

exclude_rules=$(cat "$exclude_tmp" | \
  grep -vE '^(#|//|$)' | \              # 去除注释行和空行
  sed 's/^[ \t]*//;s/[ \t]*$//' | \     # 去除首尾空格
  tr -d '\r' | \                        # 去除 CR 字符（Windows CRLF 兼容）
  sort -u)

# 去除白名单规则
echo "🚮 执行白名单过滤..."
filtered=$(grep -vxFf <(echo "$exclude_rules") "$tmp_file.processed")

# 拆分出 DOMAIN-SUFFIX 与 DOMAIN
suffixes=$(echo "$filtered" | grep '^DOMAIN-SUFFIX,' | cut -d',' -f2)
domains=$(echo "$filtered" | grep '^DOMAIN,')

# 临时保存最终合并结果
> "$tmp_file.filtered"

# 其他类型保留
echo "$filtered" | grep -Ev '^(DOMAIN|DOMAIN-SUFFIX),' >> "$tmp_file.filtered"
# DOMAIN-SUFFIX 保留
echo "$filtered" | grep '^DOMAIN-SUFFIX,' >> "$tmp_file.filtered"

# 处理 DOMAIN（去除被 DOMAIN-SUFFIX 覆盖的）
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

# 排序去重
final=$(sort -u "$tmp_file.filtered")
rule_count=$(echo "$final" | wc -l)

# 写入最终文件
{
  echo "# Merged RuleSet for Surge"
  echo "# Generated on $(date '+%Y-%m-%d %H:%M:%S') (Asia/Shanghai)"
  echo "# Total Rules: $rule_count"
  echo "# Source URLs:"
  for url in "${urls[@]}"; do
    echo "#   $url"
  done
  echo "# Excluded URLs:"
  for url in "${exclude_urls[@]}"; do
    echo "#   $url"
  done
  echo ""
  echo "$final"
} > "$output_file"

# 清理临时文件
rm -f "$tmp_file" "$tmp_file.processed" "$tmp_file.filtered" "$exclude_tmp"

echo "✅ 规则合并完成：$output_file（共 $rule_count 条）"
