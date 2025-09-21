# CV32E40P: CV32E40P CORE-V 处理器核心的验证环境

CV32E40P 专用的 SystemVerilog 源代码，以及用于 CV32E40P 验证环境的 C 和汇编测试程序源代码。
此验证环境中使用的非 CV32E40P 专用验证组件位于 `../lib` 和 `../vendor_lib` 目录中。

## 📁 目录结构：

- **bsp**：用于 CV32E40P 编译/汇编/链接测试程序的"板级支持包"（Board Support Package）。此 BSP 被 `core` 测试平台和 `uvmt_cv32` UVM 验证环境共同使用。

- **env**：UVM 环境类及其相关基础设施。包含验证环境的核心组件和配置。

- **sim**：运行仿真的目录。这是您执行各种测试和仿真的工作区域。

- **tb**：实例化处理器核心的测试平台模块。包含顶层测试平台和 DUT 包装器。

- **tests**：所有测试用例的存放位置。包含各种类型的验证测试。

每个目录中都有 README 文件，提供额外的详细信息。

## 🚀 快速开始

查看 [CORE-V-VERIF 验证策略](https://core-v-docs-verif-strat.readthedocs.io/en/latest/) 中的快速开始指南。

## 📚 中文学习资源

> **💡 提示**：我们为中文用户提供了完整的学习中心，包含详细的教程和指南：
>
> **[👉 CV32E40P 学习中心](docs/learning-center/README.md)**
>
> 学习中心包含：
> - **[5分钟快速开始](docs/learning-center/quick-start-5min.md)** - 最快上手方式
> - **[Hello World 完整流程](docs/learning-center/hello-world-flow/README.md)** - 深度理解验证流程
> - **[文件结构参考](docs/learning-center/file-reference/key-files-overview.md)** - 重要文件说明
> - **[常用命令参考](docs/learning-center/commands-reference.md)** - 命令速查表
> - **[环境检查工具](docs/learning-center/check-environment.sh)** - 自动环境验证

## 🔗 相关中文文档

- **[项目主页中文版](../README_ZH.md)** - 项目总体介绍
- **[Makefile 使用指南](../mk/README_ZH.md)** - 验证环境核心使用手册
- **[仿真环境指南](sim/README_ZH.md)** - 仿真设置和运行指南
- **[测试平台说明](tb/README_ZH.md)** - 测试平台架构详解
- **[BSP 使用指南](bsp/README_ZH.md)** - 板级支持包详解

## 🎯 针对不同用户的建议

### 🔰 新手用户
1. 从 [学习中心](docs/learning-center/README.md) 开始
2. 运行 [环境检查脚本](docs/learning-center/check-environment.sh)
3. 尝试 [5分钟快速开始](docs/learning-center/quick-start-5min.md)

### 🛠️ 有经验的用户
1. 直接查看 [Makefile 指南](../mk/README_ZH.md)
2. 参考 [常用命令](docs/learning-center/commands-reference.md)
3. 查看 [文件结构参考](docs/learning-center/file-reference/key-files-overview.md)

### 🔍 调试和问题排查
1. 使用 [调试技巧指南](docs/learning-center/hello-world-flow/07-debug-tips.md)
2. 参考 [常见问题解决方案](docs/learning-center/quick-start-5min.md#-常见问题解决)

---

*📝 本文档是 README.md 的中文翻译版本，旨在为中文用户提供更好的理解和使用体验。*