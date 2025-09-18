# 关键文件清单 📋

欢迎来到 CV32E40P 验证环境的"文件导航中心"！这里汇总了所有关键文件的位置、作用和重要性，帮助你快速定位所需文件。

## 🗺️ 文件地图概览

### 📁 项目结构鸟瞰图
```
🏠 core-v-verif/ (顶层仓库)
├── 🎯 cv32e40p/ (CV32E40P 专用验证环境)
│   ├── 📊 sim/ (仿真环境)
│   ├── 🧪 tests/ (测试用例)
│   ├── 🎭 tb/ (测试平台)
│   ├── 🔧 env/ (UVM环境)
│   └── 📚 docs/ (文档)
├── ⚙️ mk/ (全局Makefile系统)
├── 📦 lib/ (共享库)
└── 🔗 tools/ (工具脚本)
```

## 🔧 构建系统文件 (Build System)

### 🎯 **顶层控制文件**
| 文件路径 | 重要性 | 描述 |
|---------|--------|------|
| `cv32e40p/sim/uvmt/Makefile` | ⭐⭐⭐⭐⭐ | **主入口** - 用户命令的起始点 |
| `mk/uvmt/uvmt.mk` | ⭐⭐⭐⭐⭐ | **核心引擎** - 验证任务的主要控制逻辑 |
| `mk/Common.mk` | ⭐⭐⭐⭐ | **公共库** - 共享的Makefile功能 |
| `cv32e40p/sim/ExternalRepos.mk` | ⭐⭐⭐⭐ | **依赖管理** - 外部仓库配置和版本控制 |

### 🔨 **仿真器适配文件**
| 文件路径 | 仿真器 | 描述 |
|---------|--------|------|
| `mk/uvmt/dsim.mk` | Metrics DSim | DSim 仿真器专用配置 |
| `mk/uvmt/xrun.mk` | Cadence Xcelium | Xrun 仿真器专用配置 |
| `mk/uvmt/vsim.mk` | Synopsys VCS | Vsim 仿真器专用配置 |
| `mk/uvmt/riviera.mk` | Aldec Riviera | Riviera 仿真器专用配置 |

## 🧪 测试相关文件 (Test Files)

### 🎯 **Hello World 测试示例**
| 文件路径 | 类型 | 描述 |
|---------|------|------|
| `cv32e40p/tests/programs/custom/hello-world/hello-world.c` | C源码 | **测试程序** - 简单的CSR验证代码 |
| `cv32e40p/tests/programs/custom/hello-world/test.yaml` | 配置 | **测试配置** - 测试参数和UVM测试类指定 |
| `cv32e40p/tests/programs/custom/hello-world/link.ld` | 链接脚本 | **内存布局** - 程序内存映射定义 |

### 🔍 **测试程序类别**
```
📂 cv32e40p/tests/
├── 🎯 programs/custom/ (自定义测试程序)
│   ├── hello-world/ (基础验证)
│   ├── debug-test/ (调试功能测试)
│   └── interrupt-test/ (中断测试)
├── 📊 uvmt/compliance-tests/ (合规性测试)
│   └── riscv-compliance/ (RISC-V官方测试套件)
└── 🎲 uvmt/directed-tests/ (定向测试)
    └── uvmt_cv32e40p_*_test.sv (各类UVM测试)
```

## 🎭 UVM环境文件 (UVM Environment)

### 🏛️ **核心UVM组件**
| 文件路径 | 组件类型 | 描述 |
|---------|----------|------|
| `cv32e40p/tb/uvmt/uvmt_cv32e40p_tb.sv` | **Testbench** | 🎪 **测试舞台** - 顶层测试平台 |
| `cv32e40p/tb/uvmt/uvmt_cv32e40p_dut_wrap.sv` | **DUT包装器** | 🔌 **硬件接口** - RTL与UVM环境的桥梁 |
| `cv32e40p/env/uvme/uvme_cv32e40p_env.sv` | **UVM环境** | 🎬 **环境管理器** - UVM验证环境的核心 |

### 🎬 **UVM测试类**
| 文件路径 | 测试类型 | 描述 |
|---------|----------|------|
| `cv32e40p/tests/uvmt/compliance-tests/uvmt_cv32e40p_firmware_test.sv` | 固件测试 | **程序执行** - 运行编译好的C程序 |
| `cv32e40p/tests/uvmt/directed-tests/uvmt_cv32e40p_smoke_test.sv` | 冒烟测试 | **基础验证** - 快速功能检查 |
| `cv32e40p/tests/uvmt/directed-tests/uvmt_cv32e40p_interrupt_test.sv` | 中断测试 | **中断验证** - 中断响应和处理 |

### 👥 **UVM代理组件**
```
📂 cv32e40p/env/uvma/
├── 🕐 uvma_clknrst/ (时钟复位代理)
│   ├── uvma_clknrst_if.sv (接口)
│   └── uvma_clknrst_agent.sv (代理)
├── 🧠 uvma_obi/ (OBI内存代理)
│   ├── uvma_obi_memory_if.sv (内存接口)
│   └── uvma_obi_memory_agent.sv (内存代理)
└── ⚡ uvma_interrupt/ (中断代理)
    ├── uvma_interrupt_if.sv (中断接口)
    └── uvma_interrupt_agent.sv (中断代理)
```

## 💎 RTL硬件文件 (RTL Hardware)

### 🧬 **处理器核心** (通过外部仓库获取)
| 文件路径 | 描述 |
|---------|------|
| `cv32e40p/core/cv32e40p_core.sv` | **处理器核心** - CV32E40P主要逻辑 |
| `cv32e40p/core/cv32e40p_if_stage.sv` | **取指阶段** - 指令获取流水线 |
| `cv32e40p/core/cv32e40p_id_stage.sv` | **译码阶段** - 指令解码流水线 |
| `cv32e40p/core/cv32e40p_ex_stage.sv` | **执行阶段** - 指令执行流水线 |

> 📝 **注意**: RTL文件通过 `make clone_all` 从外部仓库克隆，位置在 `cv32e40p/core/` 目录

### 🔌 **接口和包装器**
| 文件路径 | 描述 |
|---------|------|
| `cv32e40p/tb/uvmt/uvmt_cv32e40p_dut_wrap.sv` | **DUT包装器** - 连接RTL和验证环境 |
| `cv32e40p/env/uvme/uvme_cv32e40p_cov_model.sv` | **覆盖率模型** - 功能覆盖率收集 |

## 📊 配置和参数文件 (Configuration)

### ⚙️ **全局配置**
| 文件路径 | 用途 | 描述 |
|---------|------|------|
| `cv32e40p/sim/ExternalRepos.mk` | **版本控制** | 外部仓库的分支和哈希值 |
| `cv32e40p/sim/Makefile.mk` | **环境设置** | 路径和环境变量配置 |
| `CLAUDE.md` | **AI助手** | Claude Code 的使用指南 |

### 🎯 **测试配置**
| 文件模式 | 描述 | 示例 |
|----------|------|------|
| `*/test.yaml` | **单个测试配置** | 指定UVM测试类和描述 |
| `*/Makefile.include` | **测试构建规则** | 特殊编译选项和链接设置 |

## 🔧 工具和脚本文件 (Tools & Scripts)

### 🛠️ **构建工具**
| 文件路径 | 功能 | 描述 |
|---------|------|------|
| `tools/gen_corev-dv` | **随机测试生成** | 基于RISC-V DV的测试生成器 |
| `tools/compliance` | **合规性测试** | RISC-V合规性测试运行器 |
| `tools/xpulp` | **PULP扩展** | XPULP指令集扩展支持 |

### 📋 **实用脚本**
| 文件路径 | 功能 | 描述 |
|---------|------|------|
| `bin/ci_check` | **持续集成** | 自动化测试检查脚本 |
| `bin/make_test` | **测试助手** | 简化的测试运行脚本 |

## 📚 文档和指南 (Documentation)

### 📖 **学习材料**
| 文件路径 | 类型 | 描述 |
|---------|------|------|
| `cv32e40p/docs/learning-center/README.md` | **学习中心** | 📚 文档导航和学习路径 |
| `cv32e40p/docs/learning-center/hello-world-flow/` | **流程教程** | 🎯 详细的执行流程分析 |
| `cv32e40p/docs/learning-center/file-reference/` | **文件参考** | 📋 文件清单和依赖关系 |

### 📝 **技术文档**
| 文件路径 | 内容 | 描述 |
|---------|------|------|
| `README.md` | **项目介绍** | 项目概述和快速开始 |
| `TOOLCHAIN.md` | **工具链指南** | RISC-V工具链安装和配置 |
| `CONTRIBUTING.md` | **贡献指南** | 如何为项目贡献代码 |

## 🔍 日志和输出文件 (Logs & Output)

### 📊 **仿真输出** (运行时生成)
| 文件路径 | 内容 | 何时查看 |
|---------|------|----------|
| `cv32e40p/sim/uvmt/*.log` | **仿真日志** | 🐛 调试测试失败时 |
| `cv32e40p/sim/uvmt/transcript` | **仿真转录** | 🔍 查看详细执行过程 |
| `cv32e40p/sim/uvmt/*.vcd` | **波形文件** | 🌊 进行信号级调试时 |
| `cv32e40p/sim/uvmt/cov/*.html` | **覆盖率报告** | 📈 分析测试覆盖率时 |

### 🏗️ **构建产物** (编译时生成)
| 文件路径 | 内容 | 用途 |
|---------|------|------|
| `cv32e40p/tests/programs/*//*.elf` | **可执行文件** | 🎯 处理器要执行的程序 |
| `cv32e40p/tests/programs/*//*.hex` | **十六进制文件** | 📝 内存初始化数据 |
| `cv32e40p/tests/programs/*//*.map` | **内存映射** | 🗺️ 符号地址参考 |

## ⚡ 快速定位指南

### 🎯 **按功能分类快速查找**

#### 想了解构建系统？
👉 重点关注: `cv32e40p/sim/uvmt/Makefile` → `mk/uvmt/uvmt.mk`

#### 想修改测试用例？
👉 重点关注: `cv32e40p/tests/programs/custom/hello-world/`

#### 想了解UVM环境？
👉 重点关注: `cv32e40p/tb/uvmt/` → `cv32e40p/env/uvme/`

#### 想调试仿真问题？
👉 重点关注: `cv32e40p/sim/uvmt/*.log` → 波形文件

#### 想了解处理器接口？
👉 重点关注: `cv32e40p/tb/uvmt/uvmt_cv32e40p_dut_wrap.sv`

### 🏃 **按任务分类快速导航**

| 任务 | 主要文件 | 次要文件 |
|------|----------|----------|
| **运行测试** | `cv32e40p/sim/uvmt/Makefile` | `mk/uvmt/uvmt.mk` |
| **修改程序** | `cv32e40p/tests/programs/custom/hello-world/hello-world.c` | `test.yaml` |
| **调试UVM** | `cv32e40p/tests/uvmt/compliance-tests/uvmt_cv32e40p_firmware_test.sv` | 环境文件 |
| **分析波形** | `cv32e40p/sim/uvmt/*.vcd` | `uvmt_cv32e40p_dut_wrap.sv` |
| **查看覆盖率** | `cv32e40p/sim/uvmt/cov/*.html` | 覆盖率配置文件 |

## 🎯 重要性评级说明

| 评级 | 图标 | 描述 | 适用人群 |
|------|------|------|----------|
| ⭐⭐⭐⭐⭐ | 🔥 | **必须掌握** | 所有用户 |
| ⭐⭐⭐⭐ | 🎯 | **重要文件** | 进阶用户 |
| ⭐⭐⭐ | 💡 | **有用文件** | 高级用户 |
| ⭐⭐ | 🔧 | **专业文件** | 专家用户 |
| ⭐ | 📝 | **参考文件** | 特定场景 |

## 📈 学习建议

### 🎯 **新手建议学习顺序**
1. 📚 先读学习中心文档 (`docs/learning-center/`)
2. 🔍 理解关键配置文件 (`ExternalRepos.mk`, `test.yaml`)
3. 🎭 分析UVM测试结构 (`uvmt_cv32e40p_firmware_test.sv`)
4. 🔧 掌握构建系统 (`Makefile`, `uvmt.mk`)
5. 💎 了解RTL接口 (`uvmt_cv32e40p_dut_wrap.sv`)

### 🚀 **进阶用户重点**
- UVM环境的深度定制
- 新测试用例的开发
- 覆盖率分析和优化
- 性能调优和调试技巧

---

*💡 提示：这个文件清单会随着项目发展而更新。建议收藏此页面，作为快速查找文件的参考手册！*

## 📚 相关文档

- **[下一步：文件依赖关系](file-dependencies.md)** - 了解文件之间的调用和依赖关系
- **[返回：学习中心首页](../README.md)** - 探索更多学习资源
- **[参考：调试技巧](../hello-world-flow/07-debug-tips.md)** - 当文件出现问题时的调试方法