# SIM 目录 - 仿真环境指南

便于启动仿真的目录结构。默认情况下，所有生成的文件将写入 `core` 或 `uvmt` 目录的子目录中。
这可以通过环境变量进行控制，详细说明请参阅 `$CORE_V_VERIF/mk/uvmt/README.md`。

## 📁 目录结构概览

```
sim/
├── core/           # 核心测试平台仿真
├── uvmt/           # UVM 验证环境仿真
└── tools/          # 工具特定配置
```

## 🔄 RTL 代码克隆

Makefile 将自动克隆所需的 RTL 代码到 `$CORE_V_VERIF/core-v-cores/cv32e40p`。

`./ExternalRepos.mk` 中的变量控制克隆代码的 URL、分支和哈希值 - 请参阅注释头部的示例。这些变量的默认值将克隆 RTL 的最新稳定版本。请注意，这并不总是 master 分支的头部。

### 🔧 配置说明
- **URL 控制**：指定 RTL 仓库的来源
- **分支选择**：选择特定的开发分支
- **哈希锁定**：确保版本一致性和可重现构建
- **自动更新**：根据配置自动获取最新代码

## 📚 目录详细说明

### 🎯 core 目录
Makefile 将运行位于 `../tb/core` 的 SystemVerilog 测试平台及其来自 `../tests/core` 的相关测试。该测试平台和测试继承自 PULP-Platform 团队，仅进行了轻微修改。

**特点：**
- 继承自 PULP-Platform 的成熟测试框架
- 专注于核心功能验证
- 轻量级的测试环境
- 快速的基本功能验证

**使用场景：**
- 基础功能快速验证
- 回归测试
- 简单的调试场景

### 🧪 uvmt 目录
Makefile 将运行位于 `../tb/uvmt` 的 SystemVerilog/UVM 验证环境以及来自 `../tests/uvmt` 的相关测试。

**特点：**
- 完整的 UVM 验证环境
- 高级验证功能和覆盖率分析
- 复杂测试场景支持
- 随机化测试能力

**使用场景：**
- 全面的验证覆盖
- 复杂功能验证
- 覆盖率驱动验证
- 随机测试生成

### 🛠️ tools 目录
CV32E40P 中使用的某些工具的特定子目录。例如，用于波形查看支持的 Tcl 控制文件。

**包含内容：**
- 波形查看器配置
- 调试脚本
- 工具特定设置
- 自动化辅助脚本

## 🚀 快速开始指南

### 运行 Core 测试
```bash
cd core
make hello-world
```

### 运行 UVM 测试
```bash
cd uvmt
make hello-world
```

### 自定义测试
```bash
# 指定测试用例
make TEST=custom_test

# 指定仿真器
make SIMULATOR=vcs

# 启用覆盖率
make COV=1
```

## 🔗 相关文档

- **[Makefile 详细指南](../../mk/README_ZH.md)** - 完整的构建系统说明
- **[CV32E40P 主页](../README_ZH.md)** - 项目总体介绍
- **[测试平台说明](../tb/README_ZH.md)** - 测试平台架构详解
- **[学习中心](../docs/learning-center/README.md)** - 完整学习资源

## 💡 使用技巧

### 环境变量配置
查看 `$CORE_V_VERIF/mk/uvmt/README.md` 了解所有可用的环境变量配置选项。

### 文件输出管理
默认输出位置可以通过以下方式自定义：
- 设置 `SIMULATOR_DIR` 环境变量
- 修改 Makefile 中的路径配置
- 使用命令行参数覆盖默认设置

### 调试建议
1. 使用 `tools/` 目录中的配置文件
2. 启用详细日志输出
3. 利用波形查看器进行深度分析

---

*📝 本文档是 README.md 的中文翻译版本，提供了仿真环境的完整使用指南。*