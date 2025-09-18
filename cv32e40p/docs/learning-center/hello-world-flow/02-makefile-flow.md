# Makefile 调用链详解 ⚙️

在验证环境的世界里，Makefile 系统就像一位经验丰富的指挥家，协调着整个"数字交响乐团"的演出。让我们深入幕后，看看这位指挥家是如何工作的！

## 🎼 指挥家的层级结构

想象一个大型交响乐团的指挥系统：

```
🎩 总指挥 (Chief Conductor)
   └── cv32e40p/sim/uvmt/Makefile
       │
       ├── 🎵 副指挥 (Assistant Conductor)
       │   └── mk/uvmt/uvmt.mk
       │       │
       │       ├── 🎶 专业指挥 (Specialist Conductors)
       │       │   ├── mk/uvmt/dsim.mk      (Metrics dsim)
       │       │   ├── mk/uvmt/xrun.mk      (Cadence Xcelium)
       │       │   ├── mk/uvmt/vsim.mk      (Mentor Questa)
       │       │   ├── mk/uvmt/vcs.mk       (Synopsys VCS)
       │       │   └── mk/uvmt/riviera.mk   (Aldec Riviera)
       │       │
       │       └── 🎪 舞台管理 (Stage Manager)
       │           └── mk/Common.mk
       │
       └── 🗂️ 剧目清单 (Repertoire List)
           └── cv32e40p/sim/ExternalRepos.mk
```

## 🚀 命令执行的奇幻旅程

当你输入 `make test TEST=hello-world` 时，一场精彩的"接力赛"就开始了：

### 第一棒：总指挥接收命令 🎩

**位置**: `cv32e40p/sim/uvmt/Makefile`

```makefile
# 🎯 这里是整个流程的起点
# 总指挥接收你的指令并进行基本准备

# 🏗️ 确定项目根目录和核心类型
MAKE_PATH := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
export CORE_V_VERIF = $(abspath $(MAKE_PATH)/../../..)
export CV_CORE ?= cv32e40p

# 📋 包含外部仓库配置（告诉系统去哪里找RTL代码）
include ../ExternalRepos.mk

# 🎼 调用主要的验证Makefile（传递指挥棒）
include $(CORE_V_VERIF)/mk/uvmt/uvmt.mk
```

**作用**：
- 📍 确定项目的根目录位置
- 🏷️ 设置核心类型为 `cv32e40p`
- 📋 包含外部依赖的配置信息
- 🎯 将控制权传递给专业的验证Makefile

### 第二棒：副指挥协调任务 🎵

**位置**: `mk/uvmt/uvmt.mk`

```makefile
# 🎭 副指挥开始工作，进行更详细的任务分配

# 🔍 检查必要的环境变量
ifndef CV_CORE
$(error Must set CV_CORE to a valid core)
endif

# 🎨 设置基本参数
CV_CORE_LC = $(shell echo $(CV_CORE) | tr A-Z a-z)  # cv32e40p
CV_CORE_UC = $(shell echo $(CV_CORE) | tr a-z A-Z)  # CV32E40P
SIMULATOR_UC = $(shell echo $(SIMULATOR) | tr a-z A-Z)

# 🎛️ 配置编译选项
SV_CMP_FLAGS ?= "+define+$(CV_CORE_UC)_ASSERT_ON"
TIMESCALE ?= -timescale 1ns/1ps

# 🎯 确定使用的仿真器
CV_SIMULATOR ?= unsim
SIMULATOR ?= $(CV_SIMULATOR)

# 📁 设置输出目录
SIM_RESULTS ?= $(MAKE_PATH)/$(SIMULATOR)_results
SIM_CFG_RESULTS = $(SIM_RESULTS)/$(CFG)
SIM_TEST_RESULTS = $(SIM_CFG_RESULTS)/$(TEST)
```

**关键职责**：
- ✅ 验证环境变量的完整性
- 🔧 设置编译和仿真参数
- 📁 确定输出文件的存放位置
- 🎯 选择合适的专业指挥（仿真器）

### 第三棒：专业指挥精确执行 🎶

根据你选择的仿真器，指挥棒会传递给对应的专业指挥。以 **dsim** 为例：

**位置**: `mk/uvmt/dsim.mk`

```makefile
# 🔬 dsim专业指挥开始工作

# 🧰 工具路径配置
DSIM_PATH = $(DSIM_HOME)/bin
DSIM = $(DSIM_PATH)/dsim

# 🎛️ 编译选项配置
DSIM_CMP_FLAGS += -suppress EnumMustBePositive
DSIM_CMP_FLAGS += -timescale $(TIMESCALE)
DSIM_CMP_FLAGS += +incdir+$(DUT_PATH)/bhv
DSIM_CMP_FLAGS += +incdir+$(RTL_PATH)/include

# 🏃 运行选项配置
DSIM_RUN_FLAGS += -licqueue
DSIM_RUN_FLAGS += +UVM_TESTNAME=$(UVMT_TEST)
DSIM_RUN_FLAGS += +elf_file=$(TEST_PROGRAM_PATH)/$(TEST_PROGRAM)

# 📊 波形配置（如果需要）
ifeq ($(WAVES), 1)
    DSIM_RUN_FLAGS += -waves waves.vcd
endif
```

**专业技能**：
- 🔧 配置特定仿真器的编译选项
- 🎯 设置UVM测试环境的参数
- 📊 处理波形生成和调试选项
- 🏃 准备最终的仿真执行命令

### 第四棒：舞台管理员统筹资源 🎪

**位置**: `mk/Common.mk`

```makefile
# 🎪 舞台管理员处理公共资源和通用功能

# 🧬 外部仓库克隆管理
clone_core_v_cores:
    @echo "正在克隆CV32E40P RTL代码..."
    git clone $(CV_CORE_REPO) --branch $(CV_CORE_BRANCH) core-v-cores/$(CV_CORE)

# 🔨 测试程序编译规则
$(TEST_PROGRAM_PATH)/$(TEST_PROGRAM): $(TEST_PROGRAM_PATH)/$(TEST_PROGRAM).c
    @echo "正在编译测试程序: $(TEST_PROGRAM)"
    $(CV_SW_TOOLCHAIN)/bin/$(CV_SW_PREFIX)gcc \
        -march=$(CV_SW_MARCH) \
        -o $@ $<

# 🧹 清理规则
clean:
    @echo "正在清理仿真结果..."
    rm -rf $(SIM_RESULTS)

clean_all: clean
    @echo "正在清理所有内容，包括克隆的RTL..."
    rm -rf core-v-cores
```

**管家职责**：
- 🏗️ 管理外部代码仓库的克隆
- 🔨 处理测试程序的编译
- 🧹 提供清理和维护功能
- 📋 定义通用的构建规则

## 🎯 关键目标（Target）的执行路径

让我们跟踪 `make test TEST=hello-world` 的完整执行路径：

### 1️⃣ 目标解析阶段
```bash
make test TEST=hello-world
# ↓ 解析为内部目标
make $(SIM_CFG_RESULTS)/$(TEST).log
# ↓ 实际路径
make dsim_results/default/hello-world.log
```

### 2️⃣ 依赖检查阶段
```makefile
# 🔍 系统检查以下依赖是否存在：
$(TEST).log: $(TEST_PROGRAM) $(RTL_FILES) $(UVM_FILES)
    │
    ├── 📝 测试程序: hello-world.hex
    ├── 💎 RTL文件: CV32E40P核心代码
    └── 🎭 UVM文件: 验证环境代码
```

### 3️⃣ 构建执行阶段
```bash
# 如果依赖不存在，系统会自动构建：

# 📥 第一步：克隆RTL代码（如果需要）
git clone https://github.com/openhwgroup/cv32e40p core-v-cores/cv32e40p

# 🔨 第二步：编译测试程序（如果需要）
riscv32-unknown-elf-gcc -march=rv32imc \
    -o hello-world.hex hello-world.c

# 🎬 第三步：启动仿真
dsim -timescale 1ns/1ps \
     +UVM_TESTNAME=uvmt_cv32e40p_firmware_test_c \
     +elf_file=hello-world.hex \
     -waves waves.vcd \
     uvmt_cv32e40p_tb
```

## 🔍 深入探索：Makefile 变量传递

理解变量是如何在不同层级间传递的：

### 🌊 变量流动图
```
用户输入
   ↓
TEST=hello-world ──────────────────────────────────┐
CV_SIMULATOR=dsim ────────────────────────────────┐│
   ↓                                             ││
总指挥 (cv32e40p/sim/uvmt/Makefile)                ││
   ↓                                             ││
export CV_CORE=cv32e40p ──────────────────────────┤│
export CORE_V_VERIF=/path/to/core-v-verif ───────┤│
   ↓                                             ││
副指挥 (mk/uvmt/uvmt.mk)                          ││
   ↓                                             ││
CV_CORE_LC=cv32e40p ─────────────────────────────┤│
SIMULATOR=dsim ──────────────────────────────────┘│
SIM_TEST_RESULTS=dsim_results/default/hello-world ─┤
   ↓                                              │
专业指挥 (mk/uvmt/dsim.mk)                          │
   ↓                                              │
DSIM_RUN_FLAGS+=+UVM_TESTNAME=uvmt_cv32e40p_firmware_test_c
DSIM_RUN_FLAGS+=+elf_file=hello-world.hex ────────┘
```

### 🎛️ 重要变量说明

| 变量名 | 来源 | 用途 | 示例值 |
|--------|------|------|--------|
| `TEST` | 用户输入 | 指定要运行的测试程序 | `hello-world` |
| `CV_SIMULATOR` | 环境变量/用户输入 | 选择仿真器 | `dsim` |
| `CV_CORE` | Makefile设置 | 指定处理器核心 | `cv32e40p` |
| `UVMT_TEST` | 自动推导 | UVM测试类名 | `uvmt_cv32e40p_firmware_test_c` |
| `SIM_TEST_RESULTS` | 计算得出 | 测试结果目录 | `dsim_results/default/hello-world` |

## 🐛 调试 Makefile 的技巧

### 🔍 查看变量值
```bash
# 查看特定变量的值
make -n test TEST=hello-world | grep "DSIM_RUN_FLAGS"

# 打印所有相关变量
make print-vars TEST=hello-world
```

### 📋 干运行模式
```bash
# 只显示会执行的命令，不实际执行
make -n test TEST=hello-world
```

### 🔊 详细输出模式
```bash
# 显示详细的执行过程
make -d test TEST=hello-world
```

## 🚀 下一站：测试程序编译

现在你已经理解了 Makefile 系统是如何协调整个验证流程的，接下来我们将深入了解测试程序是如何从 C 代码转换为处理器能理解的机器码的！

👉 **[继续学习：测试程序编译流程](03-test-compilation.md)**

---

*💡 小贴士：理解 Makefile 系统是掌握验证环境的关键。如果你对某个步骤感到困惑，可以使用 `make -n` 来查看实际会执行的命令，这是学习的最佳方式！*