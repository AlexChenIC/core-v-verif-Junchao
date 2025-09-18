# CV32E40P 常用命令速查表 ⚡

这是 CV32E40P 验证环境的常用命令快速参考指南。按功能分类，方便快速查找所需命令。

## 🚀 快速开始命令

### 基础测试运行
```bash
# 运行 Hello World 测试（最基本）
make test TEST=hello-world

# 运行测试并显示详细输出
make test TEST=hello-world VERBOSE=1

# 使用指定仿真器运行
make test TEST=hello-world SIMULATOR=dsim
make test TEST=hello-world SIMULATOR=xrun
make test TEST=hello-world SIMULATOR=vsim
```

### 环境设置
```bash
# 进入仿真目录
cd cv32e40p/sim/uvmt/

# 检查环境配置
make help

# 克隆外部依赖（首次使用）
make clone_all
```

## 🧪 测试运行命令

### 单个测试
```bash
# 基础语法
make test TEST=<test_name>

# 常用测试示例
make test TEST=hello-world          # Hello World 基础测试
make test TEST=debug-test           # 调试功能测试
make test TEST=interrupt-test       # 中断测试
make test TEST=csr-test            # CSR 寄存器测试
```

### 测试选项
```bash
# 生成波形文件
make test TEST=hello-world WAVES=1

# 使用图形界面
make test TEST=hello-world GUI=1

# 设置超时时间（周期数）
make test TEST=hello-world TIMEOUT=50000000

# 设置随机种子
make test TEST=hello-world SEED=12345
make test TEST=hello-world SEED=random

# 启用覆盖率收集
make test TEST=hello-world COVERAGE=1
```

### UVM 相关选项
```bash
# 设置 UVM 详细级别
make test TEST=hello-world UVM_VERBOSITY=UVM_LOW
make test TEST=hello-world UVM_VERBOSITY=UVM_MEDIUM
make test TEST=hello-world UVM_VERBOSITY=UVM_HIGH
make test TEST=hello-world UVM_VERBOSITY=UVM_DEBUG

# 指定 UVM 测试类
make test TEST=hello-world UVM_TESTNAME=uvmt_cv32e40p_firmware_test_c
```

## 🔨 构建和编译命令

### 程序编译
```bash
# 编译单个测试程序
make comp TEST=hello-world

# 强制重新编译
make comp TEST=hello-world FORCE=1

# 使用调试信息编译
make comp TEST=hello-world DEBUG=1

# 编译时显示详细输出
make comp TEST=hello-world COMP_VERBOSE=1
```

### UVM 环境编译
```bash
# 编译 UVM 环境
make comp_uvm

# 编译特定仿真器的环境
make comp_uvm SIMULATOR=dsim
make comp_uvm SIMULATOR=xrun

# 强制重新编译 UVM 环境
make comp_uvm FORCE=1
```

## 🧹 清理命令

### 基础清理
```bash
# 清理当前测试的构建文件
make clean

# 清理所有构建文件
make clean_all

# 清理特定测试
make clean TEST=hello-world

# 清理 UVM 编译文件
make clean_uvm
```

### 深度清理
```bash
# 清理所有临时文件和日志
make distclean

# 清理外部依赖（需要重新克隆）
make clean_deps

# 清理并重置环境
make clean_all && make clone_all
```

## 📊 分析和调试命令

### 波形分析
```bash
# 生成波形并在后台运行仿真器 GUI
make waves TEST=hello-world

# 生成 VCD 波形文件
make test TEST=hello-world WAVES=1

# 使用 GTKWave 查看波形（如果可用）
gtkwave hello-world.vcd &
```

### 日志分析
```bash
# 查看测试日志
less hello-world.log

# 搜索错误信息
grep -i "error\|fail\|fatal" hello-world.log

# 查看 UVM 报告
cat uvm_report.txt

# 查看编译日志
less compile.log
```

### 覆盖率分析
```bash
# 运行测试并生成覆盖率
make test TEST=hello-world COVERAGE=1

# 查看覆盖率报告
firefox cov/index.html  # 或其他浏览器

# 合并多个测试的覆盖率
make merge_cov
```

## 🎲 随机测试命令

### RISC-V DV 随机测试
```bash
# 生成随机指令测试
make gen_corev-dv

# 运行随机测试
make test_corev-dv

# 生成并运行随机测试
make all_corev-dv

# 指定随机测试数量
make gen_corev-dv GEN_NUM_TESTS=10
```

### 定制随机参数
```bash
# 设置随机种子范围
make gen_corev-dv GEN_START_INDEX=100 GEN_NUM_TESTS=50

# 使用特定配置生成测试
make gen_corev-dv CFG=custom_config
```

## ✅ 合规性测试命令

### RISC-V 合规性测试
```bash
# 运行所有合规性测试
make test_compliance

# 运行特定的合规性测试套件
make test_compliance COMPLIANCE_SUITE=rv32i

# 查看合规性测试结果
make compliance_report
```

## 📊 基准测试命令

### EMBench 基准测试
```bash
# 运行 EMBench 性能测试
make test_embench

# 运行速度基准测试
make test_embench EMB_TYPE=speed

# 运行大小基准测试
make test_embench EMB_TYPE=size

# 指定测试目标
make test_embench EMB_TARGET=dhrystone
```

## 🔧 高级配置命令

### 仿真器特定选项
```bash
# DSim 特定选项
make test TEST=hello-world SIMULATOR=dsim DSIM_OPTS="+define+DEBUG"

# Xrun 特定选项
make test TEST=hello-world SIMULATOR=xrun XRUN_OPTS="-coverage all"

# VCS 特定选项
make test TEST=hello-world SIMULATOR=vsim VSIM_OPTS="-do run.do"
```

### 并行运行
```bash
# 并行编译（如果支持）
make test TEST=hello-world PARALLEL=1

# 运行多个测试实例
make test TEST=hello-world RUN_INDEX=0 &
make test TEST=hello-world RUN_INDEX=1 &
make test TEST=hello-world RUN_INDEX=2 &
```

## 🔍 信息查询命令

### 系统信息
```bash
# 查看 Makefile 帮助
make help

# 查看可用测试
ls ../../tests/programs/custom/

# 查看环境变量
make print-env

# 查看版本信息
make version
```

### 目标和依赖
```bash
# 查看所有可用的 make 目标
make -qp | grep -E '^[a-zA-Z0-9_-]+:' | head -20

# 查看特定目标的依赖
make -n test TEST=hello-world
```

## 💡 实用命令组合

### 开发调试流程
```bash
# 完整的开发测试流程
make clean TEST=hello-world          # 清理
make comp TEST=hello-world           # 编译
make test TEST=hello-world WAVES=1   # 运行并生成波形
less hello-world.log                 # 查看日志
```

### 问题排查流程
```bash
# 当测试失败时的排查流程
make clean_all                       # 深度清理
make clone_all                       # 重新克隆依赖
make test TEST=hello-world VERBOSE=1 # 详细输出运行
grep -i error hello-world.log        # 查找错误
```

### 性能测试流程
```bash
# 性能基准测试流程
make clean                           # 清理环境
make test_embench EMB_TYPE=speed     # 运行速度测试
make coverage_report                 # 生成性能报告
```

## 📋 命令速查卡片

### 🔥 最常用命令
| 命令 | 用途 |
|------|------|
| `make test TEST=hello-world` | 运行基础测试 |
| `make clean` | 清理构建文件 |
| `make help` | 查看帮助信息 |
| `make clone_all` | 克隆外部依赖 |

### 🧪 测试相关
| 参数 | 说明 | 示例 |
|------|------|------|
| `TEST=<name>` | 指定测试名称 | `TEST=hello-world` |
| `SIMULATOR=<sim>` | 指定仿真器 | `SIMULATOR=dsim` |
| `WAVES=1` | 生成波形 | `WAVES=1` |
| `VERBOSE=1` | 详细输出 | `VERBOSE=1` |

### 🔧 配置选项
| 环境变量 | 说明 | 示例值 |
|----------|------|--------|
| `CV_CORE` | 处理器核心 | `CV32E40P` |
| `CV_SIMULATOR` | 默认仿真器 | `dsim` |
| `RISCV` | 工具链路径 | `/opt/riscv` |

### 🚨 故障排除
| 问题 | 命令 |
|------|------|
| 编译错误 | `make clean && make comp TEST=<test>` |
| 环境问题 | `make clean_all && make clone_all` |
| 超时问题 | `make test TEST=<test> TIMEOUT=<cycles>` |
| 权限问题 | `rm -rf /tmp/*core-v-verif*` |

## 🎯 按场景分类的命令

### 🎬 新手入门场景
```bash
cd cv32e40p/sim/uvmt/           # 进入仿真目录
make clone_all                   # 克隆依赖（首次）
make test TEST=hello-world       # 运行第一个测试
```

### 🔬 日常开发场景
```bash
make comp TEST=my-test           # 编译新测试
make test TEST=my-test WAVES=1   # 运行并生成波形
make test TEST=my-test COVERAGE=1 # 运行覆盖率分析
```

### 🚀 回归测试场景
```bash
make clean_all                   # 完全清理
make test_compliance             # 运行合规性测试
make test_corev-dv              # 运行随机测试
make coverage_report            # 生成覆盖率报告
```

### 🔍 问题调试场景
```bash
make test TEST=failing-test UVM_VERBOSITY=UVM_DEBUG  # 详细 UVM 输出
make waves TEST=failing-test                         # 波形调试
grep -A10 -B10 "FAIL" failing-test.log              # 查找失败信息
```

---

*💡 提示：将此页面收藏为日常开发的快速参考。大多数命令支持组合使用，可以根据需要灵活调整参数。*

*🔄 建议定期运行 `make help` 查看最新的可用命令，因为 Makefile 可能会更新添加新功能。*