# 📦 Surge 广告规则合并器（Auto Merged RuleSet）

本项目自动合并多个开源广告屏蔽规则，去重清洗后生成一个适用于 Surge 的 `rule-set` 格式文件，并通过 GitHub Actions 自动每日更新。

---

## ✨ 项目特点

- ✅ 支持多个 rule-set URL 自动合并
- ✅ 自动去除注释、空行与重复项
- ✅ 添加注释头部：更新时间、来源说明
- ✅ 通过 GitHub Actions 自动定时更新
- ✅ 输出格式适用于 Surge 的 `rule-set`

---

## 🔧 使用方法（Surge 配置）

在你的 Surge 配置文件中添加以下规则：

```ini
[Rule]
RULE-SET,https://raw.githubusercontent.com/githubacct001/adrules/refs/heads/main/merged-ruleset.list,REJECT
```

---

## 🔁 自动更新说明

本项目使用 GitHub Actions 实现每日自动更新：

- 每天 `00:00 UTC` 定时合并并上传规则文件
- 也可以在 GitHub Actions 页面手动点击运行
- 合并逻辑在 `scripts/merge.sh` 文件中完成

你可以根据需要修改规则来源 URL 列表。

---

## 📜 源规则列表

当前合并的 rule-set 源地址如下：

```text
  https://raw.githubusercontent.com/Cats-Team/AdRules/main/adrules.list
  https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Surge-RULE-SET.list
  https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-surge.txt
```

你可以在 `scripts/merge.sh` 中修改或添加更多规则。

---

## 🛠 自定义合并逻辑

如需自定义去广告行为（如：保留某些域名、添加白名单），可修改脚本中的处理逻辑。

---

## 🧪 手动运行合并脚本（开发调试）

```bash
bash scripts/merge.sh
```

生成的文件为 `merged-ruleset.list`，可直接用于 Surge。

---

## 🤝 致谢

感谢以下规则作者与社区开源项目提供基础规则，合并仅用于学习与自用：

- [cats-team / AdRules](https://github.com/cats-team/AdRules)
- [秋风去广告](https://github.com/TG-Twilight/AWAvenue-Adblock-Rule)
- [anti-AD](https://github.com/privacy-protection-tools/anti-AD)
- Surge 用户社区

---

## 📄 License

本项目仅用于个人学习与自用，合并的规则版权归原作者所有。请勿用于商业用途。
