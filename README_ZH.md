<!--

 Copyright 2020, 2021 OpenHW Group

 Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     https://solderpad.org/licenses/

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0

-->

# core-v-verif 中文文档
CORE-V 系列 RISC-V 处理器核心的功能验证项目。

<!--
## 新闻更新：
**2021-07-15**: [cv32e40s](https://github.com/openhwgroup/cv32e40s) 的验证环境已启动并运行。
<br>
**2021-03-23**: [cv32e40x](https://github.com/openhwgroup/cv32e40x) 的验证环境已启动并运行。
<br>
**2020-12-16**: core-v-verif 的 [cv32e40p_v1.0.0](https://github.com/openhwgroup/core-v-verif/releases/tag/22dc5fc) 版本已发布。
此标签克隆了 CV32E40P CORE-V 核心的 v1.0.0 版本，允许您重现 `RTL 冻结` 时存在的验证环境。
<br>
更多新闻请查看 [归档](https://github.com/openhwgroup/core-v-verif/blob/master/NEWS_ARCHIVE.md)。
-->

## 🚀 快速开始

首先，请访问 [OpenHW Group 官网](https://www.openhwgroup.org) 了解更多关于我们的组织和工作内容。
<br>
对于 CORE-V-VERIF 的首次使用者，[CORE-V-VERIF 验证策略](https://docs.openhwgroup.org/projects/core-v-verif/en/latest/quick_start.html) 中的 **快速开始指南** 是最佳起点。

> 📚 **中文学习资源**：我们还为中文用户提供了专门的学习中心，位于 [`cv32e40p/docs/learning-center/`](cv32e40p/docs/learning-center/README.md)，包含详细的中文教程和指南。

<!--
### CV32E4* 核心入门
如果您想运行仿真，有两个选项：
1. 要运行 CV32E40P 的 CORE 测试平台，请转到 `cv32e40p/sim/core` 并阅读 README。
2. 要运行任何 CV32E4* UVM 环境，请转到 `mk/uvmt` 并阅读 README。
-->

<!--
#### CV32E40P 覆盖率数据
CV32E40P 最新发布的覆盖率报告可在 [此处](https://openhwgroup.github.io/core-v-verif/) 找到。
-->

<!--
### CVA6 入门
要运行 CVA6 测试平台，请转到 [cva6](cva6) 目录并阅读 README。
-->

## 📁 仓库目录结构

### 🔧 bin
用于运行测试和在 core-v-verif 仓库中执行各种验证相关活动的实用工具。

### 💎 core-v-cores
空的子目录，用于克隆来自一个或多个 [CORE-V-CORES](https://github.com/openhwgroup/core-v-cores) 仓库的 RTL 代码。

### 🧬 cv32e40p, cv32e40x, cv32e40s, cva6
核心特定的验证代码。每个目录包含对应处理器核心的完整验证环境。

### 📚 docs
验证策略文档、DV 计划、编码风格指南和可用覆盖率报告的源文件。

### ⚙️ mk
支持所有 CORE-V 核心测试平台的通用仿真 Makefile。这是验证环境的构建系统核心。

### 📦 lib
所有 CORE-V 验证环境的通用组件。包含共享的 UVM 库和实用工具。

### 🔌 vendor_lib
第三方支持的验证组件。包含外部工具和库的集成代码。

## 🤝 贡献

我们非常感谢社区贡献。您可以通过查看与此仓库关联的 GitHub [项目](https://github.com/openhwgroup/core-v-verif/projects) 来了解我们当前的需求。项目内的具体工作项被定义为带有 `task` 标签的 [issues](https://github.com/openhwgroup/core-v-verif/issues)。

为了方便我们审查您的贡献，请：

* 查看 [贡献指南](https://github.com/openhwgroup/core-v-verif/blob/master/CONTRIBUTING.md) 和我们的 [SV/UVM 编码风格指南](https://github.com/openhwgroup/core-v-verif/blob/master/docs/CodingStyleGuidelines.md)。
* 将大型贡献拆分为较小的提交，分别处理单个更改或错误修复。不要在同一个提交中混合不相关的更改！
* 写有意义的提交信息。
* 如果被要求修改您的更改，请修复您的提交并重新基于您的分支以保持干净的历史记录。

## 🎯 针对中文用户的特别说明

### 📖 中文学习资源
- **[CV32E40P 学习中心](cv32e40p/docs/learning-center/README.md)** - 完整的中文学习指南
- **[5分钟快速开始](cv32e40p/docs/learning-center/quick-start-5min.md)** - 快速上手指南
- **[常用命令参考](cv32e40p/docs/learning-center/commands-reference.md)** - 命令速查表
- **[环境检查脚本](cv32e40p/docs/learning-center/check-environment.sh)** - 自动环境检查工具

### 🔗 重要文档中文版本
- **[Makefile 使用指南](mk/README_ZH.md)** - 验证环境核心使用手册（中文版）
- **[CV32E40P 介绍](cv32e40p/README_ZH.md)** - CV32E40P 验证环境说明（中文版）
- **[仿真环境指南](cv32e40p/sim/README_ZH.md)** - 仿真设置和运行指南（中文版）

### 🚀 推荐学习路径
1. **新手用户**：从 [学习中心](cv32e40p/docs/learning-center/README.md) 开始
2. **有经验用户**：直接查看 [Makefile 指南](mk/README_ZH.md)
3. **问题排查**：使用 [环境检查脚本](cv32e40p/docs/learning-center/check-environment.sh)

## 🏆 致谢

查看 [致谢文档](ACKNOWLEDGEMENTS.md)。

---

*📝 本文档是 README.md 的中文翻译版本，旨在为中文用户提供更好的理解和使用体验。如发现翻译问题或需要更新，请提交 issue 或 pull request。*