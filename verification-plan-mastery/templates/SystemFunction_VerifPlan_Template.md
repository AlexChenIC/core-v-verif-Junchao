# {CORE_NAME} 系统功能验证计划模板

**文档版本**: v1.0
**创建日期**: {DATE}
**作者**: {AUTHOR_NAME}
**项目**: {PROJECT_NAME}
**适用范围**: 中断系统、异常处理、CSR寄存器、特权模式

基于CV32E40P中断和系统功能验证的成功实践，为复杂系统级功能提供标准化验证计划框架。

## 📋 Excel表格结构示例

### Sheet 1: 中断系统验证计划

| ID | Requirement Location | Feature | Sub-Feature | Verification Goals | Pass/Fail Criteria | Coverage Method | Priority | Owner | Target Date | Status | Comments |
|----|---------------------|---------|-------------|-------------------|-------------------|-----------------|----------|-------|-------------|--------|----------|
| INT.001 | RISC-V Priv Spec 3.1.6 | Machine Timer Interrupt | MTIME Counter | • Verify mtime increments correctly<br/>• Verify 64-bit counter width<br/>• Verify counter overflow behavior | Assertion checking + Reference model comparison | Functional Coverage:<br/>• Counter values<br/>• Increment timing<br/>• Overflow conditions | High | {AUTHOR_NAME} | {DATE+14} | Ready | - |
| INT.002 | RISC-V Priv Spec 3.1.6 | Machine Timer Interrupt | MTIMECMP Register | • Verify mtimecmp write/read operations<br/>• Verify comparison with mtime<br/>• Verify interrupt generation timing | Self-checking test with signature verification | Functional Coverage:<br/>• Register values<br/>• Compare results<br/>• Timing scenarios | High | {AUTHOR_NAME} | {DATE+14} | Ready | - |
| INT.003 | RISC-V Priv Spec 3.1.9 | Machine Software Interrupt | MSIP Register | • Verify MSIP bit set/clear operations<br/>• Verify software interrupt triggering<br/>• Verify interrupt clearing mechanism | Assertion checking + SW test | Functional Coverage:<br/>• Set/clear operations<br/>• Interrupt scenarios | High | {AUTHOR_NAME} | {DATE+21} | Ready | - |

### Sheet 2: 异常处理验证计划

| ID | Requirement Location | Feature | Sub-Feature | Verification Goals | Pass/Fail Criteria | Coverage Method | Priority | Owner | Target Date | Status | Comments |
|----|---------------------|---------|-------------|-------------------|-------------------|-----------------|----------|-------|-------------|--------|----------|
| EXC.001 | RISC-V Priv Spec 3.1.15 | Instruction Address Misaligned | Exception Generation | • Verify exception on misaligned PC<br/>• Verify exception priority handling<br/>• Verify MCAUSE register update | Exception handler verification | Functional Coverage:<br/>• Misalignment types<br/>• Exception priority<br/>• CSR updates | High | {AUTHOR_NAME} | {DATE+21} | Ready | - |
| EXC.002 | RISC-V Priv Spec 3.1.16 | Illegal Instruction | Exception Detection | • Verify illegal opcode detection<br/>• Verify exception generation<br/>• Verify MTVAL register content | Self-checking exception handler | Functional Coverage:<br/>• Illegal opcodes<br/>• Exception handling<br/>• Register states | High | {AUTHOR_NAME} | {DATE+21} | Ready | - |

### Sheet 3: CSR寄存器验证计划

| ID | Requirement Location | Feature | Sub-Feature | Verification Goals | Pass/Fail Criteria | Coverage Method | Priority | Owner | Target Date | Status | Comments |
|----|---------------------|---------|-------------|-------------------|-------------------|-----------------|----------|-------|-------------|--------|----------|
| CSR.001 | RISC-V Priv Spec 3.1.8 | Machine Status Register | MSTATUS Fields | • Verify MIE bit functionality<br/>• Verify MPIE bit save/restore<br/>• Verify MPP field handling | Register access test + Assertion checking | Functional Coverage:<br/>• All field values<br/>• Field interactions<br/>• State transitions | High | {AUTHOR_NAME} | {DATE+28} | Ready | - |
| CSR.002 | RISC-V Priv Spec 3.1.11 | Machine Cause Register | MCAUSE Encoding | • Verify interrupt vs exception encoding<br/>• Verify cause code accuracy<br/>• Verify read-only behavior | Exception/interrupt verification | Functional Coverage:<br/>• All cause codes<br/>• Encoding accuracy | High | {AUTHOR_NAME} | {DATE+28} | Ready | - |

## 🎯 功能分类和验证策略

### 1. 中断系统验证

```yaml
interrupt_verification_strategy:

  # 基础中断类型
  interrupt_types:
    machine_timer:
      complexity: ⭐⭐⭐⭐
      key_aspects: [timing_accuracy, comparison_logic, interrupt_delivery]
      special_considerations: [64bit_counter, overflow_handling]

    machine_software:
      complexity: ⭐⭐⭐
      key_aspects: [sw_trigger_mechanism, clearing_behavior]
      special_considerations: [multi_hart_coordination]

    machine_external:
      complexity: ⭐⭐⭐⭐
      key_aspects: [signal_latching, priority_handling, masking]
      special_considerations: [platform_specific_wiring]

  # 验证场景矩阵
  verification_scenarios:
    basic_functionality:
      - single_interrupt_handling
      - interrupt_enable_disable
      - interrupt_pending_behavior

    advanced_scenarios:
      - nested_interrupt_handling
      - interrupt_priority_resolution
      - simultaneous_multiple_interrupts

    edge_cases:
      - interrupt_during_exception
      - interrupt_in_debug_mode
      - interrupt_with_wfi_instruction

  # 覆盖率目标
  coverage_targets:
    functional_coverage: 95%
    code_coverage: 90%
    assertion_coverage: 100%
```

### 2. 异常处理验证

```yaml
exception_verification_strategy:

  # 异常类型分类
  exception_categories:
    synchronous_exceptions:
      instruction_address_misaligned:
        trigger_conditions: [pc_not_aligned, jump_target_misaligned]
        verification_focus: [detection_accuracy, mcause_update, mtval_content]

      illegal_instruction:
        trigger_conditions: [invalid_opcode, privileged_instruction_in_user_mode]
        verification_focus: [opcode_decoding, exception_priority]

      load_address_misaligned:
        trigger_conditions: [unaligned_load_access]
        verification_focus: [address_alignment_checking, data_width_handling]

    asynchronous_exceptions:
      external_debug_interrupt:
        trigger_conditions: [debug_request_assertion]
        verification_focus: [debug_mode_entry, state_preservation]

  # 验证方法
  verification_methods:
    directed_tests:
      purpose: "测试特定异常条件"
      coverage_contribution: "边界条件和异常路径"

    random_tests:
      purpose: "发现意外的异常情况"
      coverage_contribution: "异常组合和并发场景"

    assertion_based:
      purpose: "实时检查异常处理正确性"
      coverage_contribution: "时序和状态检查"
```

### 3. CSR寄存器验证

```yaml
csr_verification_strategy:

  # CSR分类
  csr_categories:
    machine_mode_csrs:
      status_and_control:
        - mstatus: {fields: [MIE, MPIE, MPP], complexity: ⭐⭐⭐⭐}
        - misa: {fields: [Extensions, MXL], complexity: ⭐⭐⭐}
        - mie: {fields: [MTIE, MSIE, MEIE], complexity: ⭐⭐⭐}
        - mtvec: {fields: [BASE, MODE], complexity: ⭐⭐⭐⭐}

      trap_handling:
        - mepc: {functionality: exception_pc_save, complexity: ⭐⭐⭐}
        - mcause: {functionality: exception_cause, complexity: ⭐⭐⭐}
        - mtval: {functionality: trap_value, complexity: ⭐⭐⭐⭐}
        - mip: {functionality: interrupt_pending, complexity: ⭐⭐⭐}

    # CVA6/64位核心专有
    supervisor_mode_csrs:  # 仅CVA6等支持S-mode的核心
      status_and_control:
        - sstatus: {derived_from: mstatus, complexity: ⭐⭐⭐⭐⭐}
        - sie: {derived_from: mie, complexity: ⭐⭐⭐⭐}
        - sip: {derived_from: mip, complexity: ⭐⭐⭐⭐}
        - stvec: {functionality: supervisor_trap_vector, complexity: ⭐⭐⭐⭐}

      memory_management:  # CVA6 MMU相关
        - satp: {functionality: address_translation, complexity: ⭐⭐⭐⭐⭐}

  # 验证重点
  verification_focus:
    access_control:
      - privilege_level_checking
      - read_only_field_protection
      - write_mask_enforcement

    field_interactions:
      - cross_register_dependencies
      - field_update_side_effects
      - reserved_field_behavior

    state_transitions:
      - trap_entry_updates
      - trap_return_restoration
      - mode_switch_effects
```

## 🔧 高级覆盖率模型

### 1. 中断系统覆盖率

```systemverilog
// 中断系统覆盖率模型模板
covergroup interrupt_system_cg @(posedge clk);

  // 中断源覆盖
  cp_interrupt_source: coverpoint interrupt_source {
    bins timer_int = {TIMER_INTERRUPT};
    bins software_int = {SOFTWARE_INTERRUPT};
    bins external_int = {EXTERNAL_INTERRUPT};
    bins debug_int = {DEBUG_INTERRUPT};
  }

  // CPU状态覆盖
  cp_cpu_state: coverpoint cpu_current_state {
    bins normal_execution = {CPU_NORMAL};
    bins wait_for_interrupt = {CPU_WFI};
    bins debug_mode = {CPU_DEBUG};
    bins exception_handler = {CPU_EXCEPTION};
  }

  // 中断使能状态
  cp_interrupt_enable: coverpoint {mstatus.MIE, mie_reg} {
    bins globally_disabled = {2'b0x};
    bins timer_only = {2'b11} iff (mie_reg[TIMER_BIT]);
    bins software_only = {2'b11} iff (mie_reg[SOFTWARE_BIT]);
    bins external_only = {2'b11} iff (mie_reg[EXTERNAL_BIT]);
    bins all_enabled = {2'b11} iff (&mie_reg);
  }

  // 中断优先级场景
  cp_interrupt_priority: coverpoint interrupt_priority_scenario {
    bins single_interrupt = {SINGLE_INT};
    bins multiple_same_priority = {MULTIPLE_SAME};
    bins multiple_different_priority = {MULTIPLE_DIFFERENT};
    bins interrupt_preemption = {PREEMPTION};
  }

  // 关键交叉覆盖
  cross_interrupt_handling: cross cp_interrupt_source, cp_cpu_state, cp_interrupt_enable {
    // 排除无效组合
    ignore_bins invalid_debug = cross_interrupt_handling with
      (cp_cpu_state == CPU_DEBUG && cp_interrupt_source != DEBUG_INTERRUPT);

    ignore_bins disabled_interrupts = cross_interrupt_handling with
      (cp_interrupt_enable == 2'b0x);
  }

  // 时序覆盖
  cp_interrupt_timing: coverpoint interrupt_response_cycles {
    bins immediate = {[1:5]};
    bins fast = {[6:20]};
    bins normal = {[21:100]};
    bins slow = {[101:1000]};
  }

endgroup
```

### 2. 异常处理覆盖率

```systemverilog
// 异常处理覆盖率模型模板
covergroup exception_handling_cg @(posedge clk);

  // 异常类型覆盖
  cp_exception_type: coverpoint exception_cause {
    bins instruction_misaligned = {INST_ADDR_MISALIGNED};
    bins instruction_access_fault = {INST_ACCESS_FAULT};
    bins illegal_instruction = {ILLEGAL_INSTRUCTION};
    bins breakpoint = {BREAKPOINT};
    bins load_misaligned = {LOAD_ADDR_MISALIGNED};
    bins load_access_fault = {LOAD_ACCESS_FAULT};
    bins store_misaligned = {STORE_ADDR_MISALIGNED};
    bins store_access_fault = {STORE_ACCESS_FAULT};
    bins ecall_from_m = {ECALL_FROM_M_MODE};
    // CVA6特有异常
    bins ecall_from_s = {ECALL_FROM_S_MODE};
    bins ecall_from_u = {ECALL_FROM_U_MODE};
    bins page_fault = {INSTRUCTION_PAGE_FAULT, LOAD_PAGE_FAULT, STORE_PAGE_FAULT};
  }

  // 异常发生时的特权模式
  cp_current_privilege: coverpoint current_privilege_mode {
    bins machine_mode = {M_MODE};
    bins supervisor_mode = {S_MODE};  // CVA6
    bins user_mode = {U_MODE};        // CVA6
  }

  // 异常嵌套场景
  cp_nested_exceptions: coverpoint nested_exception_depth {
    bins no_nesting = {0};
    bins single_level = {1};
    bins double_level = {2};  // 深度嵌套异常
  }

  // 异常优先级验证
  cp_exception_priority: coverpoint exception_priority_scenario {
    bins single_exception = {SINGLE_EXC};
    bins multiple_simultaneous = {MULTIPLE_SIMUL};
    bins exception_during_interrupt = {EXC_DURING_INT};
    bins interrupt_during_exception = {INT_DURING_EXC};
  }

  // CSR更新覆盖
  cp_csr_updates: coverpoint csr_update_pattern {
    bins mcause_only = {MCAUSE_UPDATE};
    bins mepc_update = {MEPC_UPDATE};
    bins mtval_update = {MTVAL_UPDATE};
    bins mstatus_update = {MSTATUS_UPDATE};
    bins all_trap_csrs = {ALL_TRAP_CSRS};
  }

  // 交叉覆盖：异常类型 vs 特权模式
  cross_exception_privilege: cross cp_exception_type, cp_current_privilege {
    // CVA6特有：页面错误只能在S/U模式发生
    illegal_bins page_fault_in_m_mode = cross_exception_privilege with
      (cp_exception_type inside {INSTRUCTION_PAGE_FAULT, LOAD_PAGE_FAULT, STORE_PAGE_FAULT} &&
       cp_current_privilege == M_MODE);
  }

endgroup
```

### 3. CSR访问覆盖率

```systemverilog
// CSR寄存器覆盖率模型模板
covergroup csr_access_cg @(posedge clk);

  // CSR地址覆盖
  cp_csr_address: coverpoint csr_address {
    // Machine模式CSR
    bins mstatus = {12'h300};
    bins misa = {12'h301};
    bins mie = {12'h304};
    bins mtvec = {12'h305};
    bins mcounteren = {12'h306};
    bins mepc = {12'h341};
    bins mcause = {12'h342};
    bins mtval = {12'h343};
    bins mip = {12'h344};

    // CVA6 Supervisor模式CSR
    bins sstatus = {12'h100};
    bins sie = {12'h104};
    bins stvec = {12'h105};
    bins sepc = {12'h141};
    bins scause = {12'h142};
    bins stval = {12'h143};
    bins sip = {12'h144};
    bins satp = {12'h180};
  }

  // CSR访问类型
  cp_csr_access_type: coverpoint csr_access_type {
    bins read = {CSR_READ};
    bins write = {CSR_WRITE};
    bins set_bits = {CSR_SET};
    bins clear_bits = {CSR_CLEAR};
  }

  // 访问时的特权级别
  cp_access_privilege: coverpoint current_privilege {
    bins machine = {M_MODE};
    bins supervisor = {S_MODE};
    bins user = {U_MODE};
  }

  // CSR字段值覆盖（以mstatus为例）
  cp_mstatus_fields: coverpoint mstatus_value {
    bins mie_disabled = {32'h????_???0} iff (csr_address == 12'h300);
    bins mie_enabled = {32'h????_???1} iff (csr_address == 12'h300);
    bins mpp_machine = {32'h????_18??} iff (csr_address == 12'h300);
    bins mpp_supervisor = {32'h????_08??} iff (csr_address == 12'h300);
    bins mpp_user = {32'h????_00??} iff (csr_address == 12'h300);
  }

  // 非法访问覆盖
  cp_illegal_access: coverpoint illegal_access_type {
    bins privilege_violation = {PRIV_VIOLATION};
    bins write_to_readonly = {WRITE_READONLY};
    bins reserved_csr = {RESERVED_CSR};
    bins unimplemented_csr = {UNIMPL_CSR};
  }

  // 交叉覆盖：CSR访问 vs 特权级别
  cross_csr_privilege: cross cp_csr_address, cp_access_privilege {
    // 非法访问组合
    illegal_bins supervisor_access_machine_csr = cross_csr_privilege with
      (cp_csr_address inside {[12'h300:12'h3FF]} && cp_access_privilege != M_MODE);

    illegal_bins user_access_privileged_csr = cross_csr_privilege with
      (cp_csr_address inside {[12'h100:12'h1FF], [12'h300:12'h3FF]} &&
       cp_access_privilege == U_MODE);
  }

endgroup
```

## 📚 测试用例生成指导

### 1. 中断测试用例模板

```c
// 中断测试用例生成模板
void generate_interrupt_test_cases() {

    // 基础中断功能测试
    test_case_t basic_timer_interrupt = {
        .name = "basic_timer_interrupt",
        .setup = setup_timer_interrupt,
        .test_body = "
            // 配置timer interrupt
            write_csr(mie, MIE_MTIE);
            write_csr(mstatus, MSTATUS_MIE);
            write_csr(mtimecmp, read_csr(mtime) + 1000);

            // 等待中断发生
            wfi();

            // 验证中断处理
            verify_interrupt_handled();
        ",
        .expected_result = INTERRUPT_HANDLED_CORRECTLY
    };

    // 嵌套中断测试
    test_case_t nested_interrupt = {
        .name = "nested_interrupt_test",
        .complexity = COMPLEX,
        .test_body = "
            // 在timer中断handler中触发software interrupt
            enable_timer_interrupt();
            enable_software_interrupt();

            // Timer中断handler会触发software interrupt
            trigger_timer_interrupt();

            verify_nested_interrupt_handling();
        "
    };

    // 中断优先级测试
    test_case_t interrupt_priority = {
        .name = "interrupt_priority_test",
        .test_body = "
            // 同时触发多个中断，验证优先级
            setup_all_interrupts();
            trigger_multiple_interrupts_simultaneously();
            verify_interrupt_priority_order();
        "
    };
}
```

### 2. 异常测试用例模板

```c
// 异常测试用例生成模板
void generate_exception_test_cases() {

    // 非法指令异常
    test_case_t illegal_instruction = {
        .name = "illegal_instruction_exception",
        .test_body = "
            // 执行非法指令
            asm volatile ('.word 0x00000000');  // 全零指令

            // 不应该到达这里
            fail('Exception not generated');
        ",
        .exception_handler = "
            // 验证异常原因
            uint32_t cause = read_csr(mcause);
            assert(cause == CAUSE_ILLEGAL_INSTRUCTION);

            // 验证异常PC
            uint32_t epc = read_csr(mepc);
            assert(epc == expected_exception_pc);

            // 跳过非法指令
            write_csr(mepc, epc + 4);
        "
    };

    // 地址对齐异常
    test_case_t misaligned_access = {
        .name = "load_address_misaligned",
        .test_body = "
            // 尝试非对齐的4字节加载
            volatile uint32_t *misaligned_addr = (uint32_t*)0x10000001;
            uint32_t data = *misaligned_addr;  // 应该产生异常

            fail('Misaligned access did not cause exception');
        ",
        .exception_handler = "
            verify_misaligned_exception_handling();
        "
    };
}
```

### 3. CSR测试用例模板

```c
// CSR测试用例生成模板
void generate_csr_test_cases() {

    // 基础CSR读写测试
    test_case_t basic_csr_rw = {
        .name = "basic_csr_read_write",
        .test_body = "
            // 测试mstatus寄存器
            uint32_t original = read_csr(mstatus);

            // 写入测试值
            uint32_t test_value = 0x00001888;  // MIE=1, MPIE=1, MPP=3
            write_csr(mstatus, test_value);

            // 读回验证
            uint32_t readback = read_csr(mstatus);
            assert((readback & MSTATUS_MIE) == (test_value & MSTATUS_MIE));
            assert((readback & MSTATUS_MPIE) == (test_value & MSTATUS_MPIE));
            assert((readback & MSTATUS_MPP) == (test_value & MSTATUS_MPP));

            // 恢复原值
            write_csr(mstatus, original);
        "
    };

    // CSR访问权限测试
    test_case_t csr_privilege_test = {
        .name = "csr_access_privilege",
        .privilege_mode = USER_MODE,  // 在用户模式下运行
        .test_body = "
            // 尝试访问机器模式CSR，应该产生异常
            read_csr(mstatus);  // 应该产生异常

            fail('Privilege violation not detected');
        ",
        .exception_handler = "
            uint32_t cause = read_csr(mcause);
            assert(cause == CAUSE_ILLEGAL_INSTRUCTION);

            // 跳过非法指令
            write_csr(mepc, read_csr(mepc) + 4);
        "
    };
}
```

## ✅ 质量检查清单

### 验证计划完整性检查

- [ ] **功能覆盖完整**
  - [ ] 所有中断类型都有验证计划
  - [ ] 所有异常类型都有对应测试
  - [ ] 所有CSR寄存器都有访问测试
  - [ ] 特权模式转换都有验证

- [ ] **验证深度充分**
  - [ ] 基础功能测试 ✓
  - [ ] 边界条件测试 ✓
  - [ ] 错误注入测试 ✓
  - [ ] 性能和时序测试 ✓

- [ ] **覆盖率设计合理**
  - [ ] 功能覆盖率目标 ≥ 95%
  - [ ] 代码覆盖率目标 ≥ 90%
  - [ ] 断言覆盖率目标 = 100%
  - [ ] 交叉覆盖率设计合理

- [ ] **测试环境就绪**
  - [ ] 中断源可以模拟
  - [ ] 异常可以人为触发
  - [ ] CSR访问权限可以控制
  - [ ] 时序要求可以验证

### 项目适配检查

- [ ] **核心特性适配**
  - [ ] CV32E40P: M-mode only ✓
  - [ ] CVA6: M/S/U-mode support ✓
  - [ ] 特定扩展指令支持 ✓

- [ ] **验证环境适配**
  - [ ] 中断控制器配置正确
  - [ ] 内存映射地址正确
  - [ ] 时钟和复位信号正确

---

**使用建议**：系统功能验证复杂度高，建议分阶段实施：
1. **第一阶段**：基础中断和异常处理
2. **第二阶段**：CSR寄存器和特权模式
3. **第三阶段**：复杂交互和性能验证

每个阶段完成后进行充分的review，确保质量达标后再进入下一阶段。