# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是 CORE-V 家族 RISC-V 核心的功能验证项目。支持多个 CORE-V 核心的验证环境，包括 CV32E40P、CV32E40X、CV32E40S 等。

## 必需的环境变量

运行任何测试前需要设置以下环境变量：

```bash
export CV_SIMULATOR=<simulator>     # 模拟器：dsim, xrun, vsim, vcs, riviera
export CV_CORE=<core>              # 核心类型：cv32e40p, cv32e40x, cv32e40s
export CV_SW_TOOLCHAIN=<path>      # 工具链路径，如 /opt/riscv 或 /opt/corev
export CV_SW_PREFIX=<prefix>       # 工具链前缀，如 riscv32-unknown-elf-
```

## 常用命令

### 基本仿真命令

运行仿真的基本格式（从 `<core>/sim/uvmt` 目录）：
```bash
# 运行 sanity 测试
make sanity

# 运行指定测试程序
make test TEST=<test-program>

# 例子
make test TEST=hello-world
make test TEST=dhrystone
```

### 带选项的仿真
```bash
# 生成波形
make test TEST=hello-world WAVES=1

# 启用覆盖率
make test TEST=hello-world COV=1

# 交互式仿真
make test TEST=hello-world GUI=1

# 不使用 ISS 参考模型
make test TEST=hello-world USE_ISS=NO

# 传递运行时参数
make test TEST=hello-world USER_RUN_FLAGS="+UVM_VERBOSITY=UVM_DEBUG"
```

### COREV-DV 生成测试
```bash
# 编译 corev-dv
make corev-dv

# 生成并运行随机测试
make gen_corev-dv test TEST=corev_rand_jump_stress_test
```

### RISC-V 合规测试
```bash
# 运行单个合规测试
make compliance RISCV_ISA=rv32i COMPLIANCE_PROG=I-ADD-01

# 运行合规回归测试
make compliance_regression RISCV_ISA=rv32imc
```

### 覆盖率命令
```bash
# 生成覆盖率报告
make cov TEST=hello-world

# 查看覆盖率 GUI
make cov TEST=hello-world GUI=1

# 合并所有测试的覆盖率
make cov MERGE=1
```

### 波形调试
```bash
# 查看波形
make waves TEST=hello-world

# 使用高级调试工具
make waves TEST=hello-world ADV_DEBUG=1
```

### 清理命令
```bash
# 清理仿真结果
make clean

# 清理所有内容（包括克隆的 RTL）
make clean_all
```

### CI 检查
```bash
# 运行 CI 回归测试
./ci/ci_check --core cv32e40p -s xrun
```

## 项目架构

### 目录结构
- `cv32e40p/`, `cv32e40x/`, `cv32e40s/` - 核心特定的验证代码
- `mk/` - 公共仿真 Makefile 和模拟器特定配置
- `lib/` - 所有 CORE-V 验证环境的公共组件
- `vendor_lib/` - 第三方验证组件
- `core-v-cores/` - RTL 代码克隆目录
- `bin/` - 运行测试和验证活动的实用程序
- `docs/` - 验证策略文档和 DV 计划

### Makefile 层次结构
```
CORE-V-VERIF/mk/
├── Common.mk                    # 公共变量和目标
└── uvmt/
    ├── uvmt.mk                 # 主仿真 makefile
    ├── dsim.mk, xrun.mk, etc.  # 模拟器特定配置
    └── dvt.mk                  # DVT Eclipse IDE 支持

CV_CORE/sim/
├── ExternalRepos.mk            # 外部仓库 URL 和哈希
└── uvmt/
    └── Makefile               # 根 Makefile
```

### UVM 测试结构
- **testcase**: 从 uvm_test 扩展的 SystemVerilog 类，控制 UVM 环境
- **test-program**: 由核心 RTL 模型执行的 C 或汇编程序

测试用例位于：`<CV_CORE>/tests/uvmt`
测试程序位于：`<CV_CORE>/tests/programs`

## 配置管理

### 构建配置
配置文件位于 `<CV_CORE>/tests/cfg/<cfg>.yaml`，支持：
- `compile_flags` - 传递给模拟器的编译标志
- `ovpsim` - OVPSim ISS 的 IC 文件标志

使用方法：
```bash
make test TEST=my_test CFG=my_config
```

### 测试程序定义
每个测试程序都有 `test.yaml` 配置文件，控制：
- 软件工具链参数
- SystemVerilog 模拟器参数
- 运行时 plusargs

## 支持的模拟器

| 模拟器 | 标识 | 标准调试工具 | 高级调试工具 |
|--------|------|-------------|-------------|
| Metrics dsim | dsim | gtkwave | N/A |
| Cadence Xcelium | xrun | SimVision | Indago |
| Mentor Questa | vsim | Questa Tk GUI | Visualizer |
| Synopsys VCS | vcs | DVE | Verdi |
| Aldec Riviera-PRO | riviera | Riviera-PRO | Riviera-PRO |

## 工具链支持

### 推荐工具链
- **CORE-V 工具链**（推荐）：来自 Embecosm 的专用 CORE-V 工具链
- **RISC-V 工具链**：标准 RISC-V 工具链
- **LLVM 工具链**：支持 LLVM/Clang
- **PULP 工具链**：用于 PULP 指令扩展（已过时）

### 工具链配置示例
```bash
# CORE-V 工具链
export CV_SW_TOOLCHAIN="/opt/corev"
export CV_SW_PREFIX="riscv32-corev-elf-"

# RISC-V 工具链
export CV_SW_TOOLCHAIN="/opt/riscv"
export CV_SW_PREFIX="riscv32-unknown-elf-"
```

## 参考模型

使用 Imperas 参考模型进行指令级比较。支持：
- **OVPsim ISS**（旧版本）
- **ImperasDV**（当前推荐）

无参考模型运行：
```bash
make test TEST=hello-world USE_ISS=NO
```

## 重要提示

1. 大多数测试程序不是自检的，没有参考模型时通过的仿真是无效的
2. 需要 UVM-1.2 库（UVM-1.1 不行）
3. 推荐从各核心的 `sim/uvmt` 目录运行测试
4. 仿真结果存储在 `<simulator>_results` 目录下