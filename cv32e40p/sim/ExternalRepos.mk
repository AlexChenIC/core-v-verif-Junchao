###############################################################################
# 🔗 外部仓库配置文件 - CV32E40P 验证环境依赖管理
# ============================================================================
#
# 📋 功能说明：
# 这个文件定义了 CV32E40P 验证环境依赖的所有外部仓库的版本信息
# 通过精确控制每个外部依赖的版本，确保验证环境的可重现性和稳定性
#
# 🔄 版本控制规则：
# 对于每个仓库，都有一组配置变量：
#      *_REPO:   仓库的 GitHub URL 地址
#      *_BRANCH: 要克隆的分支名称（如 'master'）
#      *_HASH:   要克隆的具体提交哈希值（精确版本控制）
#                设置为 'head' 表示拉取分支的最新提交
#
# 🎯 CV32E40P 仓库特殊说明：
# CV32E40P 仓库还有一个额外的标签变量：
#      *_TAG:    要克隆的特定标签值
#                如果设置了标签且不为 "none"，会覆盖 HASH 设置
#
# ⚠️ 重要提醒：
# - 修改这些版本可能影响整个验证环境的兼容性
# - 建议在修改前充分测试并备份当前配置
# - 使用 "make clone_all" 命令重新下载所有外部依赖
#

export SHELL = /bin/bash

# 💎 CV32E40P 处理器核心仓库配置
# ================================================
# 🧬 这是最重要的依赖：包含 CV32E40P RISC-V 处理器的 RTL 源码
# 📍 官方仓库：OpenHW Group 维护的开源 RISC-V 处理器实现
CV_CORE_REPO   ?= https://github.com/openhwgroup/cv32e40p
CV_CORE_BRANCH ?= master                    # 🌿 主分支：包含最新稳定版本
CV_CORE_HASH   ?= fcd5968                   # 🔒 精确提交：确保版本一致性
CV_CORE_TAG    ?= none                      # 🏷️ 标签控制：设置为 "none" 使用 HASH

# 📝 版本说明：
# 上述 CV_CORE_HASH (fcd5968) 指向比 v1.0.0 RTL 冻结版本更新的提交
# 在逻辑上与 v1.0.0 版本等价，但包含了一些实现和测试平台的更新
#
# 🎯 如要使用 RTL 冻结时的确切版本，可取消下面一行的注释：
#CV_CORE_TAG    ?= cv32e40p_v1.0.0          # 🏷️ 官方 v1.0.0 标签版本

# 🎲 RISC-V DV 随机测试生成器仓库配置
# ================================================
# 🧮 Google 开发的 RISC-V 指令级随机测试生成框架
# 🎯 用于生成大量随机指令序列，提高验证覆盖率
RISCVDV_REPO    ?= https://github.com/google/riscv-dv
RISCVDV_BRANCH  ?= master                           # 🌿 主分支：Google 官方维护
RISCVDV_HASH    ?= 0b625258549e733082c12e5dc749f05aefb07d5a  # 🔒 测试过的稳定版本

# 📊 Embench IoT 基准测试套件仓库配置
# ================================================
# ⚡ 专为嵌入式和 IoT 设备设计的性能基准测试程序集
# 🎯 用于评估处理器在实际应用场景下的性能表现
EMBENCH_REPO    ?= https://github.com/embench/embench-iot.git
EMBENCH_BRANCH  ?= master                           # 🌿 主分支：Embench 官方版本
EMBENCH_HASH    ?= 6934ddd1ff445245ee032d4258fdeb9828b72af4    # 🔒 验证兼容的版本

# ✅ RISC-V 合规性测试套件仓库配置
# ================================================
# 📏 RISC-V 基金会官方的指令集合规性测试程序
# 🎯 确保处理器严格遵循 RISC-V ISA 规范要求
COMPLIANCE_REPO   ?= https://github.com/riscv/riscv-compliance
COMPLIANCE_BRANCH ?= master                         # 🌿 主分支：RISC-V 基金会官方
# 📅 版本时间：2020-08-19 - 经过充分验证的稳定版本
COMPLIANCE_HASH   ?= c21a2e86afa3f7d4292a2dd26b759f3f29cde497

# 🔍 Spike RISC-V 仿真器仓库配置 (DPI 反汇编器)
# ================================================
# 🧮 RISC-V 基金会官方的指令集仿真器和反汇编器
# ⚠️  特殊说明：此仓库仅在需要重建 DPI 反汇编器时才会被克隆
# 📝 通常情况下，用户可以直接使用已预编译的共享库文件
# 🔧 如需重建，使用命令：make dpi_dasm
DPI_DASM_SPIKE_REPO   ?= https://github.com/riscv/riscv-isa-sim.git
DPI_DASM_SPIKE_BRANCH ?= master                     # 🌿 主分支：RISC-V 官方维护
DPI_DASM_SPIKE_HASH   ?= 8faa928819fb551325e76b463fc0c978e22f5be3  # 🔒 兼容的版本

# 📚 SVLIB SystemVerilog 实用库仓库配置
# ================================================
# 🛠️ Verilab 公司开发的 SystemVerilog 通用功能库
# 🎯 提供验证环境中常用的 SystemVerilog 工具函数和类
# 📍 注意：使用 Bitbucket 而非 GitHub 托管
SVLIB_REPO       ?= https://bitbucket.org/verilab/svlib/src/master/svlib
SVLIB_BRANCH     ?= master                          # 🌿 主分支：Verilab 官方版本
SVLIB_HASH       ?= c25509a7e54a880fe8f58f3daa2f891d6ecf6428     # 🔒 测试兼容的稳定版本

# 🏁 配置文件结束
# ================================================
# 💡 使用提示：
# 1. 修改任何版本信息后，运行 'make clean_all' 清理环境
# 2. 使用 'make clone_all' 重新下载所有外部依赖
# 3. 建议在修改前备份当前的工作环境
# 4. 如遇到兼容性问题，可回退到上述推荐的哈希值
