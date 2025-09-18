###############################################################################
#
# CV32E40P UVM 验证环境主控 Makefile
#
# 版权所有 2020 OpenHW Group
#
# 本文件采用 Solderpad Hardware Licence, Version 2.0 许可协议
# 你可以在以下地址获取许可证副本：
#     https://solderpad.org/licenses/
#
# 除非适用法律要求或书面同意，本软件按"原样"分发，
# 不提供任何明示或暗示的保证或条件。
# 详见许可证中关于权限和限制的具体条款。
#
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.0
#
###############################################################################
#
# 🎯 主要功能：CV32E40P "uvmt_cv32" 测试平台的主控 Makefile
# 📋 说明：本文件是从原始 RI5CY 测试平台的 Makefile 大幅修改而来
#
# 🔧 核心职责：
#   • 作为整个验证环境的入口点和总调度器
#   • 设置必要的环境变量和项目路径
#   • 包含外部仓库配置 (RTL代码、测试库等)
#   • 调用统一的验证环境 Makefile (uvmt.mk)
#   • 为用户提供简洁的命令行接口
#
# 🎭 工作模式：
#   本 Makefile 采用"轻量级代理"模式，即本身只做最基本的
#   环境设置，然后将实际的构建和测试任务委托给专门的
#   mk/uvmt/uvmt.mk 文件处理。
#
###############################################################################
#
# 原始版权信息：
# Copyright 2019 Claire Wolf
# Copyright 2019 Robert Balas
# Original Author: Robert Balas (balasr@iis.ee.ethz.ch)
#
###############################################################################

# 🔧 Makefile 常量和环境变量定义

# 📍 基础路径计算
MAKE                  = make  # Make 命令名称
MAKE_PATH            := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
# 🧭 当前 Makefile 所在目录的绝对路径
# 通过解析 MAKEFILE_LIST 中最后一个文件的真实路径获得

# 🏠 项目根目录路径导出
export CORE_V_VERIF   = $(abspath $(MAKE_PATH)/../../..)
# 📍 计算并导出 CORE-V-VERIF 项目根目录的绝对路径
# 从当前目录 (cv32e40p/sim/uvmt) 向上三级到达项目根目录

# 🎯 目标处理器核心类型
export CV_CORE       ?= cv32e40p
# 🔍 设置当前要验证的处理器核心类型
# 使用 ?= 运算符，如果环境变量已存在则不覆盖

# 🛠️ 可选工具和工具链配置
DPI_DASM_SPIKE_REPO  ?= https://github.com/riscv/riscv-isa-sim.git
# 📦 Spike RISC-V ISA 模拟器仓库 (用于 DPI 反汇编器)
# 仅在需要重新构建反汇编器时使用，通常使用预编译的共享库

CV_SW_TOOLCHAIN      ?= /opt/riscv
# 🔨 RISC-V 软件工具链安装路径默认值
# 用户可以通过环境变量覆盖此默认路径

CV_SW_PREFIX         ?= " "
# 🏷️ 工具链可执行文件前缀
# 如：riscv32-unknown-elf-gcc 中的 "riscv32-unknown-elf-"

# 📚 包含外部仓库配置文件
include ../ExternalRepos.mk
# 🔗 包含定义 RTL 仓库、测试库仓库等外部依赖的配置文件
# 此文件定义了各种外部 Git 仓库的 URL、分支和哈希值

# 🎭 包含主要的 UVM 验证环境 Makefile
include $(CORE_V_VERIF)/mk/uvmt/uvmt.mk
# 🚀 这是实际执行所有构建和测试任务的核心 Makefile
# 包含了所有目标定义、仿真器配置和构建规则
