//
// Copyright 2020 OpenHW Group
// Copyright 2020 Datum Technology Corporation
// Copyright 2020 Silicon Labs, Inc.
// 
// Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://solderpad.org/licenses/
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// 
///////////////////////////////////////////////////////////////////////////////
//
// Modified version of the wrapper for a RI5CY testbench, containing RI5CY,
// plus Memory and stdout virtual peripherals.
// Contributor: Robert Balas <balasr@student.ethz.ch>
// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//


`ifndef __UVMT_CV32E40P_DUT_WRAP_SV__
`define __UVMT_CV32E40P_DUT_WRAP_SV__


/**
 * 🔌 CV32E40P DUT 包装器模块
 * ============================================================================
 *
 * 📋 功能描述：
 * 这个模块是 CV32E40P 处理器核心的包装器，作为 RTL 设计和 UVM 验证环境之间的桥梁
 * 它负责连接处理器核心与验证环境中的各种 UVM 代理 (Agents)
 *
 * 🔧 主要职责：
 * - 实例化 CV32E40P 处理器核心
 * - 连接处理器端口到 UVM 接口
 * - 处理信号格式转换和适配
 * - 提供调试和中断信号的聚合逻辑
 *
 * 🎯 设计特点：
 * - 支持可配置的处理器参数
 * - 兼容 OBI (Open Bus Interface) 内存协议
 * - 集成调试接口和中断处理
 * - 为验证环境提供标准化的接口
 */
module uvmt_cv32e40p_dut_wrap #(
                            // 🧬 CV32E40P 处理器核心参数配置
                            // 📖 详细说明请参考用户手册
                            parameter PULP_XPULP          =  0,    // 🔧 XPULP 扩展指令集开关
                                      PULP_CLUSTER        =  0,    // 🔧 PULP 集群功能开关
                                      FPU                 =  0,    // 🔧 浮点运算单元开关
                                      PULP_ZFINX          =  0,    // 🔧 ZFINX 浮点扩展开关
                                      NUM_MHPMCOUNTERS    =  1,    // 📊 硬件性能计数器数量
                            // 🎭 以下参数仅用于测试平台组件
                                      INSTR_ADDR_WIDTH    =  32,   // 📏 指令地址总线宽度
                                      INSTR_RDATA_WIDTH   =  32,   // 📏 指令数据总线宽度
                                      RAM_ADDR_WIDTH      =  22    // 📏 RAM 地址空间宽度
                           )

                           (
                            // 🕐 时钟和复位接口
                            uvma_clknrst_if              clknrst_if,

                            // ⚡ 中断接口
                            uvma_interrupt_if            interrupt_if,        // 🎭 UVM 中断代理接口
                            uvma_interrupt_if            vp_interrupt_if,    // 🔌 虚拟外设中断接口

                            // 🎛️ 处理器控制和状态接口
                            uvmt_cv32e40p_core_cntrl_if  core_cntrl_if,      // 🎯 核心控制信号接口
                            uvmt_cv32e40p_core_status_if core_status_if,     // 📊 核心状态信号接口

                            // 🧠 OBI 内存接口
                            uvma_obi_memory_if           obi_memory_instr_if, // 📖 指令内存接口
                            uvma_obi_memory_if           obi_memory_data_if   // 💾 数据内存接口
                           );

    // 📦 导入 UVM 包：提供 UVM 消息服务 (`uvm_info(), `uvm_error 等)
    import uvm_pkg::*;

    // 📖 指令总线信号声明
    // ================================================
    // 🔌 连接处理器核心与指令内存接口的内部信号
    logic                         instr_req;                    // 📤 指令请求信号
    logic                         instr_gnt;                    // ✅ 指令授权信号
    logic                         instr_rvalid;                 // ✅ 指令读数据有效信号
    logic [INSTR_ADDR_WIDTH-1 :0] instr_addr;                  // 📍 指令地址
    logic [INSTR_RDATA_WIDTH-1:0] instr_rdata;                 // 📄 指令读数据

    // 💾 数据总线信号声明
    // ================================================
    // 🔌 连接处理器核心与数据内存接口的内部信号
    logic                         data_req;                     // 📤 数据请求信号
    logic                         data_gnt;                     // ✅ 数据授权信号
    logic                         data_rvalid;                  // ✅ 数据读有效信号
    logic [31:0]                  data_addr;                   // 📍 数据地址
    logic                         data_we;                     // ✏️ 数据写使能
    logic [3:0]                   data_be;                     // 📝 数据字节使能
    logic [31:0]                  data_rdata;                  // 📄 数据读取值
    logic [31:0]                  data_wdata;                  // ✏️ 数据写入值

    // ⚡ 中断信号声明
    // ================================================
    // 🔀 处理来自不同源的中断信号并进行聚合
    logic [31:0]                  irq_vp;                      // 🔌 虚拟外设中断源
    logic [31:0]                  irq_uvma;                    // 🎭 UVM 代理中断源
    logic [31:0]                  irq;                         // 🎯 聚合后的中断信号
    logic                         irq_ack;                     // ✅ 中断确认信号
    logic [ 4:0]                  irq_id;                      // 🔢 中断标识符

    // 🔍 调试信号声明
    // ================================================
    // 🛠️ 支持处理器调试功能的控制信号
    logic                         debug_req_vp;                // 🔌 虚拟外设调试请求
    logic                         debug_req_uvma;              // 🎭 UVM 代理调试请求
    logic                         debug_req;                   // 🎯 聚合后的调试请求
    logic                         debug_havereset;             // 🔄 调试复位状态
    logic                         debug_running;               // 🏃 调试运行状态
    logic                         debug_halted;                // ⏸️ 调试暂停状态

    // 🔍 调试接口信号连接
    // ================================================
    assign debug_if.clk      = clknrst_if.clk;              // 🕐 调试接口时钟连接
    assign debug_if.reset_n  = clknrst_if.reset_n;          // 🔄 调试接口复位连接
    assign debug_req_uvma    = debug_if.debug_req;          // 📥 获取 UVM 调试请求

    // 🔀 调试请求信号聚合逻辑
    assign debug_req = debug_req_vp | debug_req_uvma;       // 🎯 OR 逻辑合并调试请求

    // 📖 OBI 指令总线配置
    // ================================================
    // 🔒 指令总线为只读模式，符合 OBI v1.0 协议
    assign obi_memory_instr_if.we        = 'b0;             // ❌ 指令总线禁用写操作
    assign obi_memory_instr_if.be        = '1;              // ✅ 指令总线全字节使能

    // 💾 数据总线为读写模式，符合 OBI v1.0 协议
    // （数据总线的读写控制由处理器核心直接管理）

    // ⚡ 中断接口信号连接
    // ================================================
    // 🎭 UVM 中断代理接口连接
    assign interrupt_if.clk                     = clknrst_if.clk;           // 🕐 中断接口时钟
    assign interrupt_if.reset_n                 = clknrst_if.reset_n;       // 🔄 中断接口复位
    assign irq_uvma                             = interrupt_if.irq;         // 📥 获取 UVM 中断信号

    // 🔌 虚拟外设中断接口连接
    assign vp_interrupt_if.clk                  = clknrst_if.clk;           // 🕐 虚拟外设时钟
    assign vp_interrupt_if.reset_n              = clknrst_if.reset_n;       // 🔄 虚拟外设复位
    assign irq_vp                               = vp_interrupt_if.irq;      // 📥 获取虚拟外设中断

    // 📤 中断响应信号反向连接
    assign interrupt_if.irq_id                  = irq_id;                   // 📋 中断标识反馈
    assign interrupt_if.irq_ack                 = irq_ack;                  // ✅ 中断确认反馈

    // 🔀 中断信号聚合逻辑
    assign irq = irq_uvma | irq_vp;                                        // 🎯 OR 逻辑合并中断源

    // 🧬 CV32E40P 处理器核心实例化
    // ================================================
    // 🎯 这是整个 DUT 包装器的核心部分：实例化 CV32E40P 处理器
    // 🔧 传递所有配置参数以定制处理器功能
    cv32e40p_wrapper #(
                 .PULP_XPULP       (PULP_XPULP),        // 🔧 XPULP 扩展指令集配置
                 .PULP_CLUSTER     (PULP_CLUSTER),      // 🔧 PULP 集群功能配置
                 .FPU              (FPU),               // 🔧 浮点运算单元配置
                 .PULP_ZFINX       (PULP_ZFINX),        // 🔧 ZFINX 浮点扩展配置
                 .NUM_MHPMCOUNTERS (NUM_MHPMCOUNTERS)   // 📊 硬件性能计数器数量配置
                )
    cv32e40p_wrapper_i                                           // 🏷️ 实例名称
        (
         // 🕐 基础时钟和复位信号
         .clk_i                  ( clknrst_if.clk                 ),  // 🕐 系统时钟输入
         .rst_ni                 ( clknrst_if.reset_n             ),  // 🔄 系统复位输入（低有效）

         // 🎛️ 处理器控制信号
         .pulp_clock_en_i        ( core_cntrl_if.pulp_clock_en    ),  // ⚡ PULP 时钟使能
         .scan_cg_en_i           ( core_cntrl_if.scan_cg_en       ),  // 🔍 扫描时钟门控使能

         // 📍 地址配置信号
         .boot_addr_i            ( core_cntrl_if.boot_addr        ),  // 🚀 启动地址
         .mtvec_addr_i           ( core_cntrl_if.mtvec_addr       ),  // ⚡ 异常向量表基址
         .dm_halt_addr_i         ( core_cntrl_if.dm_halt_addr     ),  // 🛑 调试模式暂停地址
         .hart_id_i              ( core_cntrl_if.hart_id          ),  // 🔢 硬件线程ID
         .dm_exception_addr_i    ( core_cntrl_if.dm_exception_addr),  // 🚨 调试模式异常地址

         // 📖 指令内存接口 (OBI)
         // ================================================
         .instr_req_o            ( obi_memory_instr_if.req        ),  // 📤 指令请求 (核心→代理)
         .instr_gnt_i            ( obi_memory_instr_if.gnt        ),  // ✅ 指令授权 (代理→核心)
         .instr_rvalid_i         ( obi_memory_instr_if.rvalid     ),  // ✅ 指令数据有效
         .instr_addr_o           ( obi_memory_instr_if.addr       ),  // 📍 指令地址
         .instr_rdata_i          ( obi_memory_instr_if.rdata      ),  // 📄 指令数据

         // 💾 数据内存接口 (OBI)
         // ================================================
         .data_req_o             ( obi_memory_data_if.req         ),  // 📤 数据请求
         .data_gnt_i             ( obi_memory_data_if.gnt         ),  // ✅ 数据授权
         .data_rvalid_i          ( obi_memory_data_if.rvalid      ),  // ✅ 数据读有效
         .data_we_o              ( obi_memory_data_if.we          ),  // ✏️ 数据写使能
         .data_be_o              ( obi_memory_data_if.be          ),  // 📝 数据字节使能
         .data_addr_o            ( obi_memory_data_if.addr        ),  // 📍 数据地址
         .data_wdata_o           ( obi_memory_data_if.wdata       ),  // ✏️ 数据写入
         .data_rdata_i           ( obi_memory_data_if.rdata       ),  // 📄 数据读取

         // 🚫 APU (辅助处理单元) 接口 - CV32E40P 中未验证（未来工作）
         // ================================================
         .apu_req_o              (                                ),  // 🚫 APU 请求（未连接）
         .apu_gnt_i              ( 1'b0                           ),  // 🚫 APU 授权（固定为0）
         .apu_operands_o         (                                ),  // 🚫 APU 操作数（未连接）
         .apu_op_o               (                                ),  // 🚫 APU 操作码（未连接）
         .apu_flags_o            (                                ),  // 🚫 APU 标志（未连接）
         .apu_rvalid_i           ( 1'b0                           ),  // 🚫 APU 结果有效（固定为0）
         .apu_result_i           ( {32{1'b0}}                     ),  // 🚫 APU 结果（固定为0）
         .apu_flags_i            ( {5{1'b0}}                      ),  // 🚫 APU 标志反馈（固定为0）

         // ⚡ 中断接口
         // ================================================
         .irq_i                  ( irq_uvma                       ),  // 📥 中断请求输入
         .irq_ack_o              ( irq_ack                        ),  // ✅ 中断确认输出
         .irq_id_o               ( irq_id                         ),  // 🔢 中断ID输出

         // 🔍 调试接口
         // ================================================
         .debug_req_i            ( debug_req_uvma                 ),  // 📥 调试请求输入
         .debug_havereset_o      ( debug_havereset                ),  // 🔄 调试复位状态输出
         .debug_running_o        ( debug_running                  ),  // 🏃 调试运行状态输出
         .debug_halted_o         ( debug_halted                   ),  // ⏸️ 调试暂停状态输出

         // 🎛️ 核心控制和状态接口
         // ================================================
         .fetch_enable_i         ( core_cntrl_if.fetch_en         ),  // 🚀 取指使能控制
         .core_sleep_o           ( core_status_if.core_busy       )   // 😴 核心忙碌状态输出
        ); // cv32e40p_wrapper_i 实例结束


endmodule : uvmt_cv32e40p_dut_wrap

`endif // __UVMT_CV32E40P_DUT_WRAP_SV__


