###############################################################################
#
# Copyright 2020 OpenHW Group
#
# Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://solderpad.org/licenses/
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
#
###############################################################################
# 🎯 CV32E40P 验证环境核心 Makefile 文件
# ============================================================================
#
# 📋 功能概述：
# 这是 OpenHW 验证核心（特别是 CV32E40P）的 UVMT 测试平台的主要 Makefile
# 该文件定义了整个验证环境的构建规则、路径配置、工具选择和测试流程
#
# 🏗️ 架构特点：
# - 支持多种仿真器 (DSim, Xrun, Vsim, Riviera)
# - 集成 UVM 验证环境和多种代理 (Agents)
# - 支持随机测试生成 (RISC-V DV)
# - 集成合规性测试套件 (RISC-V Compliance)
# - 提供完整的覆盖率分析和调试功能
#
# 🔧 主要用途：
# - 编译和运行各种类型的验证测试
# - 管理外部依赖库和工具链
# - 配置仿真器和验证环境参数
# - 生成测试报告和覆盖率分析
#
# 📝 修改说明：
# 基于原始 RI5CY 测试平台 Makefile 进行了大幅修改和功能扩展
#
###############################################################################
#
# Copyright 2019 Claire Wolf
# Copyright 2019 Robert Balas
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# Original Author: Robert Balas (balasr@iis.ee.ethz.ch)
#
###############################################################################

# 🔍 变量检查和验证
# ================================================
# 确保必要的环境变量已正确设置
ifndef CV_CORE
$(error 错误：必须设置 CV_CORE 环境变量为有效的核心名称，如 CV32E40P)
endif

# 📊 系统常量和环境变量定义
# ================================================
DATE           = $(shell date +%F)                    # 📅 当前日期，用于日志和报告命名
CV_CORE_LC     = $(shell echo $(CV_CORE) | tr A-Z a-z)  # 🔠 核心名称小写版本 (如 cv32e40p)
CV_CORE_UC     = $(shell echo $(CV_CORE) | tr a-z A-Z)  # 🔠 核心名称大写版本 (如 CV32E40P)
SIMULATOR_UC   = $(shell echo $(SIMULATOR) | tr a-z A-Z)  # 🔠 仿真器名称大写版本
export CV_CORE_LC                                     # 🌐 导出给子进程使用
export CV_CORE_UC                                     # 🌐 导出给子进程使用
.DEFAULT_GOAL := no_rule                              # 🎯 默认目标：防止意外执行

# 🛠️ 实用命令定义
# ================================================
MKDIR_P = mkdir -p                                     # 📁 创建目录命令（支持父目录）

# ⚙️ 仿真器编译标志配置
# ================================================
# ⚠️ 注意：这些标志影响所有仿真器，修改时请谨慎！
WAVES        ?= 0                                      # 🌊 波形生成开关 (0=关闭, 1=开启)
SV_CMP_FLAGS ?= "+define+$(CV_CORE_UC)_ASSERT_ON"     # 🔧 SystemVerilog 编译标志：启用断言检查
TIMESCALE    ?= -timescale 1ns/1ps                     # ⏰ 仿真时间尺度：1纳秒精度，1皮秒分辨率
UVM_PLUSARGS ?=                                        # 🎭 UVM 附加参数（用户可自定义）

# 🖥️ SystemVerilog 仿真器选择配置
# ================================================
CV_SIMULATOR ?= unsim                                  # 🔧 默认仿真器设置（unsim = 未指定）
SIMULATOR    ?= $(CV_SIMULATOR)                        # 🎯 实际使用的仿真器名称

# 🧮 指令集仿真器 (ISS) 配置
# ================================================
# 📝 说明：ISS 用于指令级对比验证，提供参考模型功能
USE_ISS      ?= YES                                    # ✅ 是否使用 ISS（强烈建议保持开启）
ISS          ?= IMPERAS                                # 🎯 ISS 类型：IMPERAS OVPsim 参考模型

# 📊 通用配置变量
# ================================================
CFG             ?= default                             # 🎛️ 配置名称（用于区分不同的测试配置）

# 🎲 测试生成变量
# ================================================
GEN_START_INDEX ?= 0                                   # 🔢 生成测试的起始索引
GEN_NUM_TESTS   ?= 1                                   # 📊 生成测试的数量
export RUN_INDEX       ?= 0                           # 🏃 当前运行的测试索引

# 📁 通用输出目录结构
# ================================================
# 🎯 这些目录用于组织仿真结果、日志文件和生成的报告
SIM_RESULTS             ?= $(if $(CV_RESULTS),$(abspath $(CV_RESULTS))/$(SIMULATOR)_results,$(MAKE_PATH)/$(SIMULATOR)_results)  # 📊 仿真结果根目录
SIM_CFG_RESULTS          = $(SIM_RESULTS)/$(CFG)                    # 📂 特定配置的结果目录
SIM_COREVDV_RESULTS      = $(SIM_CFG_RESULTS)/corev-dv             # 🎲 Core-V DV 随机测试结果
SIM_LDGEN_RESULTS        = $(SIM_CFG_RESULTS)/$(LDGEN)             # 🔗 链接器生成的结果
SIM_TEST_RESULTS         = $(SIM_CFG_RESULTS)/$(TEST)              # 🧪 特定测试的结果目录
SIM_RUN_RESULTS          = $(SIM_TEST_RESULTS)/$(RUN_INDEX)        # 🏃 特定运行的结果目录
SIM_TEST_PROGRAM_RESULTS = $(SIM_RUN_RESULTS)/test_program         # 💻 测试程序相关结果
SIM_BSP_RESULTS          = $(SIM_TEST_PROGRAM_RESULTS)/bsp         # 🔧 板级支持包结果

# 📊 EMBench 基准测试选项
# ================================================
# ⚡ EMBench 是专为嵌入式和 IoT 设备设计的性能基准测试套件
EMB_TYPE           ?= speed                            # 🏃 基准测试类型：speed（速度）或 size（大小）
EMB_TARGET         ?= 0                                # 🎯 目标设备编号
EMB_CPU_MHZ        ?= 1                                # ⏱️ CPU 频率（MHz）
EMB_TIMEOUT        ?= 3600                             # ⏰ 测试超时时间（秒）
EMB_PARALLEL_ARG    = $(if $(filter $(YES_VALS),$(EMB_PARALLEL)),YES,NO)    # 🔄 并行运行选项
EMB_BUILD_ONLY_ARG  = $(if $(filter $(YES_VALS),$(EMB_BUILD_ONLY)),YES,NO)  # 🔨 仅构建选项
EMB_DEBUG_ARG       = $(if $(filter $(YES_VALS),$(EMB_DEBUG)),YES,NO)       # 🐛 调试模式选项

# 🎭 UVM 验证环境路径配置
# ================================================
# 🎯 这个部分定义了整个 UVM 验证环境中所有组件的路径
# 📁 包括测试平台、环境、代理 (Agents) 和实用库的位置

# 🏛️ 核心验证环境组件
export DV_UVMT_PATH             = $(CORE_V_VERIF)/$(CV_CORE_LC)/tb/uvmt     # 🎪 UVMT 测试平台：顶层测试环境
export DV_UVME_PATH             = $(CORE_V_VERIF)/$(CV_CORE_LC)/env/uvme    # 🎬 UVME 验证环境：UVM 环境管理器

# 📚 UVM 实用库路径
export DV_UVML_HRTBT_PATH       = $(CORE_V_VERIF)/lib/uvm_libs/uvml_hrtbt   # 💓 心跳监控库：检测仿真是否卡死
export DV_UVML_TRN_PATH         = $(CORE_V_VERIF)/lib/uvm_libs/uvml_trn     # 🔄 事务处理库：UVM 事务基础类
export DV_UVML_LOGS_PATH        = $(CORE_V_VERIF)/lib/uvm_libs/uvml_logs    # 📝 日志管理库：增强的日志功能
export DV_UVML_SB_PATH          = $(CORE_V_VERIF)/lib/uvm_libs/uvml_sb      # 📊 记分板库：结果对比和检查
export DV_UVML_MEM_PATH         = $(CORE_V_VERIF)/lib/uvm_libs/uvml_mem     # 🧠 内存管理库：内存模型和操作

# 👥 UVM 验证代理 (Agents) 路径
# ================================================
# 🎯 代理负责驱动和监控特定的接口信号
export DV_UVMA_CORE_CNTRL_PATH  = $(CORE_V_VERIF)/lib/uvm_agents/uvma_core_cntrl   # 🎛️ 核心控制代理：处理器控制信号
export DV_UVMA_CLKNRST_PATH     = $(CORE_V_VERIF)/lib/uvm_agents/uvma_clknrst      # 🕐 时钟复位代理：时钟和复位管理
export DV_UVMA_INTERRUPT_PATH   = $(CORE_V_VERIF)/lib/uvm_agents/uvma_interrupt    # ⚡ 中断代理：中断信号驱动和监控
export DV_UVMA_DEBUG_PATH       = $(CORE_V_VERIF)/lib/uvm_agents/uvma_debug        # 🔍 调试代理：调试接口管理
export DV_UVMA_OBI_MEMORY_PATH  = $(CORE_V_VERIF)/lib/uvm_agents/uvma_obi_memory   # 🧠 OBI 内存代理：内存总线接口
export DV_UVMA_PMA_PATH         = $(CORE_V_VERIF)/lib/uvm_agents/uvma_pma          # 🗺️ 物理内存属性代理
export DV_UVMA_FENCEI_PATH      = $(CORE_V_VERIF)/lib/uvm_agents/uvma_fencei       # 🚧 指令缓存同步代理

# 🔍 专业验证代理
export DV_UVMA_ISACOV_PATH      = $(CORE_V_VERIF)/lib/uvm_agents/uvma_isacov       # 📊 指令集覆盖率代理：ISA 覆盖率收集
export DV_UVMA_RVFI_PATH        = $(CORE_V_VERIF)/lib/uvm_agents/uvma_rvfi         # 🔬 RISC-V 形式化接口代理
export DV_UVMA_RVVI_PATH        = $(CORE_V_VERIF)/lib/uvm_agents/uvma_rvvi         # ✅ RISC-V 验证接口代理
export DV_UVMA_RVVI_OVPSIM_PATH = $(CORE_V_VERIF)/lib/uvm_agents/uvma_rvvi_ovpsim  # 🧮 OVPsim 参考模型代理

# 🔬 UVM 验证组件路径
export DV_UVMC_RVFI_SCOREBOARD_PATH      = $(CORE_V_VERIF)/lib/uvm_components/uvmc_rvfi_scoreboard/      # 📊 RVFI 记分板组件
export DV_UVMC_RVFI_REFERENCE_MODEL_PATH = $(CORE_V_VERIF)/lib/uvm_components/uvmc_rvfi_reference_model/  # 🧮 RVFI 参考模型组件

# 🧮 Imperas OVPsim 参考模型路径配置
# ================================================
# 🎯 OVPsim 提供处理器的指令级精确参考模型，用于对比验证
export DV_OVPM_HOME             = $(CORE_V_VERIF)/vendor_lib/imperas         # 🏠 Imperas 模型主目录
export DV_OVPM_MODEL            = $(DV_OVPM_HOME)/imperas_DV_COREV          # 🧠 Core-V 专用 Imperas 模型
export DV_OVPM_DESIGN           = $(DV_OVPM_HOME)/design                    # 🎨 设计文件目录

# 📚 第三方库路径
export DV_SVLIB_PATH            = $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/verilab  # 🛠️ Verilab SVLIB 实用库

# 🎪 测试平台源文件收集
DV_UVMT_SRCS                  = $(wildcard $(DV_UVMT_PATH)/*.sv))            # 📂 自动收集所有 UVMT SystemVerilog 文件

# 🎭 默认 UVM 测试用例配置
# ================================================
# ⚠️ 注意：必须使用测试用例的类名（不是文件名）
# 📁 测试用例位置：../../tests/uvmt
UVM_TESTNAME ?= uvmt_$(CV_CORE_LC)_firmware_test_c                           # 🎯 默认测试：固件测试类

# 🎲 随机指令生成器路径配置
# ================================================
# 🔧 Google RISC-V DV：生成随机指令序列进行验证
RISCVDV_PKG         := $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/google/riscv-dv    # 📦 Google RISC-V DV 包
COREVDV_PKG         := $(CORE_V_VERIF)/lib/corev-dv                                # 📦 Core-V DV 扩展包
CV_CORE_COREVDV_PKG := $(CORE_V_VERIF)/$(CV_CORE_LC)/env/corev-dv                 # 📦 核心特定的 Core-V DV 配置
export RISCV_DV_ROOT         = $(RISCVDV_PKG)                               # 🌐 导出 RISC-V DV 根路径
export COREV_DV_ROOT         = $(COREVDV_PKG)                               # 🌐 导出 Core-V DV 根路径
export CV_CORE_COREV_DV_ROOT = $(CV_CORE_COREVDV_PKG)                       # 🌐 导出核心特定根路径

# RISC-V Foundation's RISC-V Compliance Test-suite
COMPLIANCE_PKG   := $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/riscv/riscv-compliance

# EMBench benchmarking suite
EMBENCH_PKG	:= $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/embench
EMBENCH_TESTS	:= $(CORE_V_VERIF)/$(CV_CORE_LC)/tests/programs/embench

# Disassembler
DPI_DASM_PKG       := $(CORE_V_VERIF)/lib/dpi_dasm
DPI_DASM_SPIKE_PKG := $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/dpi_dasm_spike
export DPI_DASM_ROOT       = $(DPI_DASM_PKG)
export DPI_DASM_SPIKE_ROOT = $(DPI_DASM_SPIKE_PKG)

# TB source files for the CV32E core
TBSRC_TOP   := $(TBSRC_HOME)/uvmt/uvmt_$(CV_CORE_LC)_tb.sv
TBSRC_HOME  := $(CORE_V_VERIF)/$(CV_CORE_LC)/tb
export TBSRC_HOME = $(CORE_V_VERIF)/$(CV_CORE_LC)/tb

SIM_LIBS    := $(CORE_V_VERIF)/lib/sim_libs

RTLSRC_VLOG_TB_TOP	:= $(basename $(notdir $(TBSRC_TOP)))
RTLSRC_VOPT_TB_TOP	:= $(addsuffix _vopt, $(RTLSRC_VLOG_TB_TOP))

# RTL source files for the CV32E core
# DESIGN_RTL_DIR is used by CV32E40P_MANIFEST file
CV_CORE_PKG          := $(CORE_V_VERIF)/core-v-cores/$(CV_CORE_LC)
CV_CORE_MANIFEST     := $(CV_CORE_PKG)/$(CV_CORE_LC)_manifest.flist
export DESIGN_RTL_DIR = $(CV_CORE_PKG)/rtl

RTLSRC_HOME   := $(CV_CORE_PKG)/rtl
RTLSRC_INCDIR := $(RTLSRC_HOME)/include

# SVLIB
SVLIB_PKG            := $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/verilab/svlib

###############################################################################
# Seed management for constrained-random sims
SEED    ?= 1
RNDSEED ?=

ifeq ($(SEED),random)
RNDSEED = $(shell date +%N)
else
ifeq ($(SEED),)
# Empty SEED variable selects 1
RNDSEED = 1
else
RNDSEED = $(SEED)
endif
endif

###############################################################################
# Common Makefile:
#    - Core Firmware and the RISCV GCC Toolchain (SDK)
#    - Variables for RTL dependencies
include $(CORE_V_VERIF)/mk/Common.mk
###############################################################################
# Clone core RTL and DV dependencies
clone_cv_core_rtl: $(CV_CORE_PKG)

clone_riscv-dv: $(RISCVDV_PKG)

clone_embench: $(EMBENCH_PKG)

clone_compliance: $(COMPLIANCE_PKG)

clone_dpi_dasm_spike:
	$(CLONE_DPI_DASM_SPIKE_CMD)

clone_svlib: $(SVLIB_PKG)

$(CV_CORE_PKG):
	$(CLONE_CV_CORE_CMD)

$(RISCVDV_PKG):
	$(CLONE_RISCVDV_CMD)

$(COMPLIANCE_PKG):
	$(CLONE_COMPLIANCE_CMD)

$(EMBENCH_PKG):
	$(CLONE_EMBENCH_CMD)

$(DPI_DASM_SPIKE_PKG):
	$(CLONE_DPI_DASM_SPIKE_CMD)

$(SVLIB_PKG):
	$(CLONE_SVLIB_CMD)

###############################################################################
# RISC-V Compliance Test-suite
#     As much as possible, the test suite is used "out-of-the-box".  The
#     "build_compliance" target below uses the Makefile supplied by the suite
#     to compile all the individual test-programs in the suite to generate the
#     elf and hex files used in simulation.  Each <sim>.mk is assumed to have a
#     target to run the compiled test-program.

# RISCV_ISA='rv32i|rv32im|rv32imc|rv32Zicsr|rv32Zifencei'
RISCV_ISA    ?= rv32i
RISCV_TARGET ?= OpenHW
RISCV_DEVICE ?= $(CV_CORE_LC)

clone_compliance:
	$(CLONE_COMPLIANCE_CMD)

clr_compliance:
	make clean -C $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/riscv/riscv-compliance

build_compliance: $(COMPLIANCE_PKG)
	make simulate -i -C $(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/riscv/riscv-compliance \
		RISCV_TARGET=${RISCV_TARGET} \
		RISCV_DEVICE=${RISCV_DEVICE} \
		PATH=$(RISCV)/bin:$(PATH) \
		RISCV_PREFIX=$(RISCV_PREFIX) \
		NOTRAPS=1 \
		RISCV_ISA=$(RISCV_ISA)
#		VERBOSE=1

all_compliance: $(COMPLIANCE_PKG)
	make build_compliance RISCV_ISA=rv32i        && \
	make build_compliance RISCV_ISA=rv32im       && \
	make build_compliance RISCV_ISA=rv32imc      && \
	make build_compliance RISCV_ISA=rv32Zicsr    && \
	make build_compliance RISCV_ISA=rv32Zifencei

# "compliance" is a simulator-specific target defined in <sim>.mk
COMPLIANCE_RESULTS = $(SIM_RESULTS)

compliance_check_sig: compliance
	@echo "Checking Compliance Signature for $(RISCV_ISA)/$(COMPLIANCE_PROG)"
	@echo "Reference: $(REF)"
	@echo "Signature: $(SIG)"
	@export SUITEDIR=$(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/riscv/riscv-compliance/riscv-test-suite/$(RISCV_ISA) && \
	export REF=$(REF) && export SIG=$(SIG) && export COMPL_PROG=$(COMPLIANCE_PROG) && \
	export RISCV_TARGET=${RISCV_TARGET} && export RISCV_DEVICE=${RISCV_DEVICE} && \
	export RISCV_ISA=${RISCV_ISA} export SIG_ROOT=${SIG_ROOT} && \
	$(CORE_V_VERIF)/bin/diff_signatures.sh | tee $(COMPLIANCE_RESULTS)/$(CFG)/$(RISCV_ISA)/$(COMPLIANCE_PROG)/$(RUN_INDEX)/diff_signatures.log

compliance_check_all_sigs:
	@$(MKDIR_P) $(COMPLIANCE_RESULTS)/$(CFG)/$(RISCV_ISA)
	@echo "Checking Compliance Signature for all tests in $(CFG)/$(RISCV_ISA)"
	@export SUITEDIR=$(CORE_V_VERIF)/$(CV_CORE_LC)/vendor_lib/riscv/riscv-compliance/riscv-test-suite/$(RISCV_ISA) && \
	export RISCV_TARGET=${RISCV_TARGET} && export RISCV_DEVICE=${RISCV_DEVICE} && \
	export RISCV_ISA=${RISCV_ISA} export SIG_ROOT=${SIG_ROOT} && \
	$(CORE_V_VERIF)/bin/diff_signatures.sh $(RISCV_ISA) | tee $(COMPLIANCE_RESULTS)/$(CFG)/$(RISCV_ISA)/diff_signatures.log

compliance_regression:
	make build_compliance RISCV_ISA=$(RISCV_ISA)
	@export SIM_DIR=$(CORE_V_VERIF)/$(CV_CORE_LC)/sim/uvmt && \
	$(CORE_V_VERIF)/bin/run_compliance.sh $(RISCV_ISA)
	make compliance_check_all_sigs RISCV_ISA=$(RISCV_ISA)

dah:
	@export SIM_DIR=$(CORE_V_VERIF)/cv32/sim/uvmt && \
	$(CORE_V_VERIF)/bin/run_compliance.sh $(RISCV_ISA)

###############################################################################
# EMBench benchmark
# 	target to check out and run the EMBench suite for code size and speed
#

embench: $(EMBENCH_PKG)
	$(CORE_V_VERIF)/bin/run_embench.py \
		-c $(CV_CORE) \
		-cc $(RISCV_EXE_PREFIX)$(RISCV_CC) \
		-sim $(SIMULATOR) \
		-t $(EMB_TYPE) \
		--timeout $(EMB_TIMEOUT) \
		--parallel $(EMB_PARALLEL_ARG) \
		-b $(EMB_BUILD_ONLY_ARG) \
		-tgt $(EMB_TARGET) \
		-f $(EMB_CPU_MHZ) \
		-d $(EMB_DEBUG_ARG)

###############################################################################
# ISACOV (ISA coverage)
#   Compare the log against the tracer log.
#   This checks that sampling went correctly without false positives/negatives.

ISACOV_LOGDIR = $(SIM_CFG_RESULTS)/$(TEST)/$(RUN_INDEX)
ISACOV_RVFILOG = $(ISACOV_LOGDIR)/uvm_test_top.env.rvfi_agent.trn.log
ISACOV_COVERAGELOG = $(ISACOV_LOGDIR)/uvm_test_top.env.isacov_agent.trn.log

isacov_logdiff:
	@echo isacov_logdiff:
	@echo checking that env/dirs/files are as expected...
		@printenv TEST > /dev/null || (echo specify TEST; false)
		@ls $(ISACOV_LOGDIR) > /dev/null
		@ls $(ISACOV_RVFILOG) > /dev/null
		@ls $(ISACOV_COVERAGELOG) > /dev/null
	@echo extracting assembly code from logs...
		@cat $(ISACOV_RVFILOG)                                                      \
			| awk -F ' - ' '{print $$2}' `#discard everything but the assembly` \
			| sed 's/ *#.*//'            `#discard comments`                    \
			| sed 's/ *<.*//'            `#discard symbol information`          \
			| sed 's/,/, /g'             `#add space after commas`              \
			| tail -n +4 > trace.tmp     `#don't include banner`
		@cat $(ISACOV_COVERAGELOG)                       \
			| awk -F '\t' '{print $$3}' `#discard everything but the assembly` \
			| sed 's/_/./'              `#convert "c_addi" to "c.addi" etc`    \
			| tail -n +2 > agent.tmp    `#don't include banner`
	@echo diffing the instruction sequences...
		@echo saving to $(ISACOV_LOGDIR)/isacov_logdiff
		@rm -rf $(ISACOV_LOGDIR)/isacov_logdiff
		@diff trace.tmp agent.tmp > $(ISACOV_LOGDIR)/isacov_logdiff; true
		@rm -rf trace.tmp agent.tmp
		@(test ! -s $(ISACOV_LOGDIR)/isacov_logdiff && echo OK) || (echo FAIL; false)

###############################################################################
# Include the targets/rules for the selected SystemVerilog simulator
#ifeq ($(SIMULATOR), unsim)
#include unsim.mk
#else
ifeq ($(SIMULATOR), dsim)
include $(CORE_V_VERIF)/mk/uvmt/dsim.mk
else
ifeq ($(SIMULATOR), xrun)
include $(CORE_V_VERIF)/mk/uvmt/xrun.mk
else
ifeq ($(SIMULATOR), vsim)
include $(CORE_V_VERIF)/mk/uvmt/vsim.mk
else
ifeq ($(SIMULATOR), vcs)
include $(CORE_V_VERIF)/mk/uvmt/vcs.mk
else
ifeq ($(SIMULATOR), riviera)
include $(CORE_V_VERIF)/mk/uvmt/riviera.mk
else
include $(CORE_V_VERIF)/mk/uvmt/unsim.mk
endif
endif
endif
endif
endif
#endif

################################################################################
# Open a DVT Eclipse IDE instance with the project imported automatically
ifeq ($(MAKECMDGOALS), open_in_dvt_ide)
include $(CORE_V_VERIF)/mk/uvmt/dvt.mk
else
ifeq ($(MAKECMDGOALS), create_dvt_build_file)
include $(CORE_V_VERIF)/mk/uvmt/dvt.mk
else
ifeq ($(MAKECMDGOALS), dvt_dump_env_vars)
include $(CORE_V_VERIF)/mk/uvmt/dvt.mk
endif
endif
endif

###############################################################################
# Clean up your mess!
#   1. Clean all generated files of the C and assembler tests
#   2. Simulator-specific clean targets are in ./<simulator>.mk
#   3. clean_bsp target is specified in ../Common.mk
clean_hex:
	rm -rf $(SIM_TEST_PROGRAM_RESULTS)

clean_test_programs: clean_bsp
	if [ -d "$(SIM_RESULTS)" ]; then \
		find $(SIM_RESULTS) -depth -type d -name test_program | xargs rm -rf; \
	fi

clean_riscv-dv:
	rm -rf $(RISCVDV_PKG)
	rm -rf $(COREVDV_PKG)/out_*

clean_compliance:
	rm -rf $(COMPLIANCE_PKG)

clean_embench:
	rm -rf $(EMBENCH_PKG)
	cd $(EMBENCH_TESTS) && \
		find . ! -path . ! -path ./README.md -delete
	if [ -d "$(SIM_RESULTS)" ]; then \
		cd $(SIM_RESULTS) && find . -depth -type d -name "emb_*" | xargs rm -rf; \
	fi

clean_dpi_dasm_spike:
	rm -rf $(DPI_DASM_SPIKE_PKG)

clean_svlib:
	rm -rf $(SVLIB_PKG)
