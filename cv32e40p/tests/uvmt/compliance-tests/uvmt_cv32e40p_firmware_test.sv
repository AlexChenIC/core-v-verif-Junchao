//
// CV32E40P 固件测试类 - UVM验证环境的核心测试控制器
//
// 版权所有 2020 OpenHW Group
// 版权所有 2020 Datum Technology Corporation
// 版权所有 2020 Silicon Labs, Inc.
//
// 本文件采用 Solderpad Hardware Licence, Version 2.0 许可协议
// 许可证详情请访问：https://solderpad.org/licenses/
//
// 除非适用法律要求或书面同意，本软件按"原样"分发，
// 不提供任何明示或暗示的保证或条件。
//

// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

`ifndef __UVMT_CV32E40P_FIRMWARE_TEST_SV__
`define __UVMT_CV32E40P_FIRMWARE_TEST_SV__

/**
 * 🎭 CV32E40P 固件测试类 (uvmt_cv32e40p_firmware_test_c)
 *
 * 📋 主要功能：
 *    • 管理预编译固件程序的测试执行流程
 *    • 协调 RISC-V GCC 工具链编译 C/汇编代码为可执行文件
 *    • 将编译后的程序加载到 CV32E40P 指令内存中
 *    • 控制处理器的启动、执行和结束过程
 *
 * 🎯 设计理念：
 *    本测试类采用"黑盒"测试方法，不关心固件的具体实现细节，
 *    只负责提供执行环境并监控执行结果。这种设计使得测试类
 *    可以灵活适应各种不同类型的固件测试程序。
 *
 * ⚡ 工作流程：
 *    1. 📥 读取预编译的固件文件 (ELF 或 HEX 格式)
 *    2. 🔄 调用 RISC-V 工具链进行必要的格式转换
 *    3. 💾 将程序加载到 CV32E40P 的指令内存中
 *    4. 🚀 启动处理器执行测试程序
 *    5. 📊 监控执行过程并收集测试结果
 *    6. 🏁 根据虚拟外设信号判断测试成功或失败
 *
 * 🔧 支持特性：
 *    • 随机调试信号注入 (可选)
 *    • 随机中断噪声生成 (可选)
 *    • 处理器 fetch_enable 信号随机控制 (可选)
 *    • 复位期间调试模式测试 (可选)
 */
// 🎭 CV32E40P 固件测试类定义
// 继承自基础测试类，专门处理预编译固件程序的测试
class uvmt_cv32e40p_firmware_test_c extends uvmt_cv32e40p_base_test_c;

   // 🎯 测试类型约束：限制为预编译自检程序类型
   // 这个约束确保测试配置使用正确的测试程序类型
   constraint test_type_cons {
     test_cfg.tpt == PREEXISTING_SELFCHECKING;  // 预编译的自检测试程序
   }

   // 🔧 UVM 组件注册宏：将此类注册到 UVM 工厂机制
   // 这使得 UVM 可以通过字符串名称动态创建此类的实例
   `uvm_component_utils_begin(uvmt_cv32e40p_firmware_test_c)
   `uvm_object_utils_end

   // 🏗️ 构造函数声明
   // 创建测试类实例，设置默认名称和父组件
   extern function new(string name="uvmt_cv32e40p_firmware_test", uvm_component parent=null);

   // 🎬 主要执行阶段任务
   // 控制整个测试的执行流程：启动处理器、等待程序完成、收集结果
   extern virtual task run_phase(uvm_phase phase);

   // 🐛 随机调试功能任务
   // 在测试执行期间随机生成调试请求，验证调试模式的正确性
   extern virtual task random_debug();

   // 🔄 复位期间调试任务
   // 在处理器复位期间应用调试信号，测试调试模块的复位行为
   extern virtual task reset_debug();

   // 🚀 启动时调试任务
   // 在处理器启动的早期阶段应用调试信号，测试启动过程中的调试功能
   extern virtual task bootset_debug();

   // 🚨 中断噪声生成任务
   // 在测试执行期间随机生成中断信号，验证中断处理逻辑的正确性
   extern virtual task irq_noise();

   // ⚡ 取指使能随机控制任务
   // 随机控制 fetch_enable_i 信号，测试处理器在取指暂停/恢复时的行为
   extern virtual task random_fetch_toggle();

endclass : uvmt_cv32e40p_firmware_test_c


// 🏗️ 构造函数实现
// 初始化固件测试类实例，调用父类构造函数并输出测试类型信息
function uvmt_cv32e40p_firmware_test_c::new(string name="uvmt_cv32e40p_firmware_test", uvm_component parent=null);

   super.new(name, parent);  // 调用父类构造函数
   `uvm_info("TEST", "This is the FIRMWARE TEST", UVM_NONE)  // 📢 声明测试类型

endfunction : new

// 🎬 主要执行阶段任务实现
// 这是整个测试的核心控制逻辑，管理测试的完整生命周期
task uvmt_cv32e40p_firmware_test_c::run_phase(uvm_phase phase);

   // 🔗 调用父类的run_phase：启动时钟和看门狗定时器
   super.run_phase(phase);

   // 🐛 可选功能：随机调试信号生成
   // 通过命令行参数 +gen_random_debug 激活
   if ($test$plusargs("gen_random_debug")) begin
    fork
      random_debug();  // 并行启动随机调试任务
    join_none
   end

   // 🚨 可选功能：中断噪声生成
   // 通过命令行参数 +gen_irq_noise 激活，用于测试中断处理的鲁棒性
   if ($test$plusargs("gen_irq_noise")) begin
    fork
      irq_noise();  // 并行启动中断噪声生成任务
    join_none
   end

   // ⚡ 可选功能：随机取指控制
   // 通过命令行参数 +random_fetch_toggle 激活，测试取指暂停/恢复机制
   if ($test$plusargs("random_fetch_toggle")) begin
     fork
       random_fetch_toggle();  // 并行启动取指控制任务
     join_none
   end

   // 🔄 可选功能：复位期间调试
   // 通过命令行参数 +reset_debug 激活，测试复位状态下的调试功能
   if ($test$plusargs("reset_debug")) begin
    fork
      reset_debug();  // 并行启动复位调试任务
    join_none
   end

   // 🚀 可选功能：启动时调试
   // 通过命令行参数 +debug_boot_set 激活，测试启动过程中的调试功能
   if ($test$plusargs("debug_boot_set")) begin
    fork
      bootset_debug();  // 并行启动启动调试任务
    join_none
   end

   // 🎯 开始测试执行的主要流程
   phase.raise_objection(this);  // 🔒 阻止UVM阶段结束，开始测试

   // ⏳ 等待系统复位释放
   @(posedge env_cntxt.clknrst_cntxt.vif.reset_n);

   // 🕐 稳定等待：给系统33个时钟周期稳定时间
   repeat (33) @(posedge env_cntxt.clknrst_cntxt.vif.clk);

   // 🚀 启动处理器取指：激活fetch_enable信号
   core_cntrl_vif.go_fetch();
   `uvm_info("TEST", "Started RUN", UVM_NONE)  // 📢 宣布测试开始执行

   // 📊 等待固件程序完成执行
   // 固件程序需要向虚拟外设写入退出状态和通过/失败指示
   wait (
          (vp_status_vif.exit_valid    == 1'b1) ||  // 退出状态有效
          (vp_status_vif.tests_failed  == 1'b1) ||  // 测试失败
          (vp_status_vif.tests_passed  == 1'b1)     // 测试通过
        );

   // 🕐 等待额外100个时钟周期，确保所有信号稳定
   repeat (100) @(posedge env_cntxt.clknrst_cntxt.vif.clk);

   // TODO: exit_value信号可能无效 - 需要在vp_status_vif中添加锁存器
   `uvm_info("TEST", $sformatf("Finished RUN: exit status is %0h", vp_status_vif.exit_value), UVM_NONE)

   // 🔓 释放UVM阶段阻塞，允许测试结束
   phase.drop_objection(this);

endtask : run_phase

task uvmt_cv32e40p_firmware_test_c::reset_debug();
    uvme_cv32e40p_random_debug_reset_c debug_vseq;
    debug_vseq = uvme_cv32e40p_random_debug_reset_c::type_id::create("random_debug_reset_vseqr", vsequencer);
    `uvm_info("TEST", "Applying debug_req_i at reset", UVM_NONE);
    @(negedge env_cntxt.clknrst_cntxt.vif.reset_n);

    if (!debug_vseq.randomize()) begin
        `uvm_fatal("TEST", "Cannot randomize the debug sequence!")
    end
    debug_vseq.start(vsequencer);

endtask

task uvmt_cv32e40p_firmware_test_c::bootset_debug();
    uvme_cv32e40p_random_debug_bootset_c debug_vseq;
    debug_vseq = uvme_cv32e40p_random_debug_bootset_c::type_id::create("random_debug_bootset_vseqr", vsequencer);
    `uvm_info("TEST", "Applying single cycle debug_req after reset", UVM_NONE);
    @(negedge env_cntxt.clknrst_cntxt.vif.reset_n);

    // Delay debug_req_i by up to 35 cycles.Should hit BOOT_SET
    if (!test_randvars.randomize() with { random_int inside {[1:35]}; }) begin
        `uvm_fatal("TEST", "Cannot randomize test_randvars for debug_req_delay!")
    end
    repeat(test_randvars.random_int) @(posedge env_cntxt.clknrst_cntxt.vif.clk);

    if (!debug_vseq.randomize()) begin
        `uvm_fatal("TEST", "Cannot randomize the debug sequence!")
    end
    debug_vseq.start(vsequencer);

endtask

task uvmt_cv32e40p_firmware_test_c::random_debug();
    `uvm_info("TEST", "Starting random debug in thread UVM test", UVM_NONE)

    while (1) begin
        uvme_cv32e40p_random_debug_c debug_vseq;
        repeat (100) @(env_cntxt.debug_cntxt.vif.mon_cb);
        debug_vseq = uvme_cv32e40p_random_debug_c::type_id::create("random_debug_vseqr", vsequencer);
        if (!debug_vseq.randomize()) begin
           `uvm_fatal("TEST", "Cannot randomize the debug sequence!")
        end
        debug_vseq.start(vsequencer);
        break;
    end
endtask : random_debug

task uvmt_cv32e40p_firmware_test_c::irq_noise();
  `uvm_info("TEST", "Starting IRQ Noise thread in UVM test", UVM_NONE);
  while (1) begin
    uvme_cv32e40p_interrupt_noise_c interrupt_noise_vseq;

    interrupt_noise_vseq = uvme_cv32e40p_interrupt_noise_c::type_id::create("interrupt_noise_vseqr", vsequencer);
    assert(interrupt_noise_vseq.randomize() with {
      reserved_irq_mask == 32'h0;
    });
    interrupt_noise_vseq.start(vsequencer);
    break;
  end
endtask : irq_noise

task uvmt_cv32e40p_firmware_test_c::random_fetch_toggle();
  `uvm_info("TEST", "Starting random_fetch_toggle thread in UVM test", UVM_NONE);
  while (1) begin
    int unsigned fetch_assert_cycles;
    int unsigned fetch_deassert_cycles;

    // SVTB.29.1.3.1 - Banned random number system functions and methods calls
    // Waive for performance reasons.
    //@DVT_LINTER_WAIVER_START "MT20211214_4" disable SVTB.29.1.3.1

    // Randomly assert for a random number of cycles
    randcase
      9: fetch_assert_cycles = $urandom_range(100_000, 100);
      1: fetch_assert_cycles = $urandom_range(100, 1);
      1: fetch_assert_cycles = $urandom_range(3, 1);
    endcase
    repeat (fetch_assert_cycles) @(core_cntrl_vif.drv_cb);
    core_cntrl_vif.stop_fetch();

    // Randomly dessert for a random number of cycles
    randcase
      3: fetch_deassert_cycles = $urandom_range(100, 1);
      1: fetch_deassert_cycles = $urandom_range(3, 1);
    endcase
    //@DVT_LINTER_WAIVER_END "MT20211214_4"

    repeat (fetch_deassert_cycles) @(core_cntrl_vif.drv_cb);
    core_cntrl_vif.go_fetch();
  end

endtask : random_fetch_toggle

`endif // __UVMT_CV32E40P_FIRMWARE_TEST_SV__
