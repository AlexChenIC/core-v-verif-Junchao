# CV32E40P Excel文档实例解析

本文档提供CV32E40P项目中关键Excel验证计划文档的具体内容分析，作为学习和复用的实际参考。

## 📊 文档分析说明

**重要说明：** 由于Excel文档的二进制格式无法直接查看具体内容，本分析基于：
1. 文档大小和复杂度推断
2. CORE-V项目的标准模板结构
3. VerificationPlanning101.md的官方指导
4. 相关功能规范的验证需求

## 🔧 CV32E40P_OBI_VerifPlan.xlsx 深度解析

**文档特征：**
- 文件大小：16KB (中等复杂度)
- 功能领域：微架构总线接口
- 验证复杂度：⭐⭐⭐⭐⭐

### 预期文档结构

根据OBI-1.0规范和CV32E40P用户手册，这个验证计划likely包含：

| Requirement Location | Feature | Sub-Feature | Verification Goals |
|---------------------|---------|-------------|-------------------|
| OBI-1.0 Spec Section 2.1 | Basic OBI Protocol | Request Phase | • Verify req signal assertion<br/>• Verify addr validity<br/>• Verify we signal for writes |
| OBI-1.0 Spec Section 2.2 | Basic OBI Protocol | Grant Phase | • Verify gnt response timing<br/>• Verify gnt for all req<br/>• Verify back-to-back grants |
| OBI-1.0 Spec Section 2.3 | Basic OBI Protocol | Response Phase | • Verify rvalid timing<br/>• Verify rdata validity<br/>• Verify response ordering |
| CV32E40P Manual Ch 3.2 | Memory Interface | Instruction Fetch | • Verify fetch request generation<br/>• Verify fetch address alignment<br/>• Verify fetch data handling |
| CV32E40P Manual Ch 3.3 | Memory Interface | Data Access | • Verify load/store requests<br/>• Verify data width handling<br/>• Verify unaligned access |

### 关键验证技术

**1. 协议断言验证：**
```systemverilog
// 预期的OBI协议断言
property obi_req_gnt_handshake;
  @(posedge clk) disable iff (!rst_n)
    req |-> ##[0:MAX_GRANT_DELAY] gnt;
endproperty

property obi_rvalid_follows_gnt;
  @(posedge clk) disable iff (!rst_n)
    gnt |-> ##[1:MAX_RESPONSE_DELAY] rvalid;
endproperty
```

**2. 功能覆盖率模型：**
```systemverilog
covergroup obi_transaction_cg;
  cp_req_type: coverpoint {req, we} {
    bins read = {2'b10};
    bins write = {2'b11};
  }

  cp_addr_alignment: coverpoint addr[1:0] {
    bins aligned = {2'b00};
    bins unaligned[] = {2'b01, 2'b10, 2'b11};
  }

  cp_burst_length: coverpoint burst_length {
    bins single = {1};
    bins burst[] = {[2:8]};
  }

  cross_req_alignment: cross cp_req_type, cp_addr_alignment;
endgroup
```

## ⚡ CV32E40P_interrupts.xlsx 深度解析

**文档特征：**
- 文件大小：30KB (高复杂度)
- 功能领域：CLINT中断控制器
- 验证复杂度：⭐⭐⭐⭐⭐

### 预期文档结构

基于RISC-V特权规范和CLINT规范：

| Requirement Location | Feature | Sub-Feature | Verification Goals |
|---------------------|---------|-------------|-------------------|
| RISC-V Priv Spec 3.1.6 | Machine Timer Interrupt | MTIME Register | • Verify mtime counter increment<br/>• Verify mtime readability<br/>• Verify mtime 64-bit width |
| RISC-V Priv Spec 3.1.6 | Machine Timer Interrupt | MTIMECMP Register | • Verify mtimecmp write/read<br/>• Verify comparison logic<br/>• Verify interrupt generation |
| RISC-V Priv Spec 3.1.9 | Machine Software Interrupt | MSIP Register | • Verify msip bit set/clear<br/>• Verify software interrupt trigger<br/>• Verify interrupt clearing |
| RISC-V Priv Spec 3.1.6 | Machine External Interrupt | MEIP Signal | • Verify external interrupt input<br/>• Verify interrupt latching<br/>• Verify priority handling |
| CV32E40P Manual Ch 4 | Interrupt Controller | Interrupt Priority | • Verify interrupt priority order<br/>• Verify nested interrupt handling<br/>• Verify interrupt masking |

### 中断验证的关键场景

**1. 基础中断流程：**
```
中断验证场景矩阵：
┌─────────────┬──────────────┬──────────────┬──────────────┐
│ 中断源      │ CPU状态      │ MIE状态      │ 预期行为     │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ Timer       │ Running      │ Enabled      │ Interrupt    │
│ Timer       │ Running      │ Disabled     │ Pending      │
│ Timer       │ WFI          │ Enabled      │ Wake + Int   │
│ Software    │ Running      │ Enabled      │ Interrupt    │
│ External    │ In ISR       │ Enabled      │ Nested Int   │
└─────────────┴──────────────┴──────────────┴──────────────┘
```

**2. 中断优先级验证：**
```
Priority Matrix (from highest to lowest):
1. Debug Interrupt (highest)
2. Machine External Interrupt (MEIP)
3. Machine Software Interrupt (MSIP)
4. Machine Timer Interrupt (MTIP)
```

**3. 中断覆盖率设计：**
```systemverilog
covergroup interrupt_coverage_cg;
  cp_int_source: coverpoint interrupt_source {
    bins timer = {TIMER_INT};
    bins software = {SOFTWARE_INT};
    bins external = {EXTERNAL_INT};
    bins debug = {DEBUG_INT};
  }

  cp_cpu_state: coverpoint cpu_state {
    bins normal = {CPU_NORMAL};
    bins wfi = {CPU_WFI};
    bins debug = {CPU_DEBUG};
    bins isr = {CPU_IN_ISR};
  }

  cp_mie_status: coverpoint mie_reg {
    bins all_enabled = {4'b1111};
    bins partial[] = {4'b0001, 4'b0010, 4'b0100, 4'b1000,
                      4'b0011, 4'b0101, 4'b1001, 4'b0110,
                      4'b1010, 4'b1100, 4'b0111, 4'b1011,
                      4'b1101, 4'b1110};
    bins all_disabled = {4'b0000};
  }

  cross_int_scenario: cross cp_int_source, cp_cpu_state, cp_mie_status {
    // 排除无效组合
    ignore_bins invalid = cross_int_scenario with
      (cp_cpu_state == CPU_DEBUG && cp_int_source != DEBUG_INT);
  }
endgroup
```

## 🐛 CV32E40P_debug.xlsx 深度解析

**文档特征：**
- 文件大小：79KB (最高复杂度)
- 功能领域：RISC-V调试接口
- 验证复杂度：⭐⭐⭐⭐⭐

### 预期文档结构 (部分示例)

基于RISC-V调试规范1.0：

| Requirement Location | Feature | Sub-Feature | Verification Goals |
|---------------------|---------|-------------|-------------------|
| Debug Spec 1.0 Ch 4.1 | Debug Mode Entry | Debug Request | • Verify debug req assertion<br/>• Verify debug mode entry timing<br/>• Verify PC save to DPC |
| Debug Spec 1.0 Ch 4.2 | Debug Mode Operation | Debug CSR Access | • Verify DCSR read/write<br/>• Verify DPC read/write<br/>• Verify DSCRATCH access |
| Debug Spec 1.0 Ch 4.3 | Debug Mode Exit | DRET Instruction | • Verify dret execution<br/>• Verify PC restoration<br/>• Verify mode transition |
| Debug Spec 1.0 Ch 5.1 | Hardware Breakpoints | Breakpoint Match | • Verify address match logic<br/>• Verify breakpoint trigger<br/>• Verify match priority |
| Debug Spec 1.0 Ch 6.1 | Debug Module Interface | DMI Operations | • Verify DMI read operations<br/>• Verify DMI write operations<br/>• Verify DMI error handling |

### 调试验证的复杂场景

**1. 调试状态机验证：**
```
Debug State Machine:
┌─────────────┐    debug_req    ┌─────────────┐
│   NORMAL    │ ──────────────→ │    DEBUG    │
│   EXECUTION │                 │    MODE     │
│             │ ←────────────── │             │
└─────────────┘      dret       └─────────────┘
       │                               │
       │ ebreak                       │ ebreak
       │                               │ (in debug)
       ↓                               ↓
┌─────────────┐                 ┌─────────────┐
│  EXCEPTION  │                 │   DEBUG     │
│  HANDLER    │                 │ EXCEPTION   │
└─────────────┘                 └─────────────┘
```

**2. 断点验证矩阵：**
```
Breakpoint Verification Matrix:
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ Breakpoint  │ Match Type  │ CPU Mode    │ Expected    │
│ Type        │             │             │ Behavior    │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ Instruction │ Exact       │ Normal      │ Debug Entry │
│ Instruction │ Exact       │ Debug       │ No Trigger  │
│ Data Load   │ Exact       │ Normal      │ Debug Entry │
│ Data Store  │ Range       │ Normal      │ Debug Entry │
│ Data Access │ Mask        │ Normal      │ Debug Entry │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

## 🚀 Xpulp扩展指令验证模式

### CV32E40P_xpulp-packed-simd.xlsx 分析

**文档特征：**
- 文件大小：23KB (高复杂度，Xpulp中最复杂)
- 功能领域：打包SIMD指令扩展

**SIMD指令验证的特殊性：**

1. **数据路径验证**
   ```
   SIMD Data Path Verification:
   32-bit register split into:
   ├── 4 × 8-bit operations (byte SIMD)
   ├── 2 × 16-bit operations (halfword SIMD)
   └── 1 × 32-bit operation (word operation)
   ```

2. **并行性验证**
   - 验证多个运算单元的独立性
   - 验证跨通道操作的正确性
   - 验证饱和算术的实现

3. **覆盖率特殊考虑**
   ```systemverilog
   covergroup simd_operations_cg;
     cp_operation: coverpoint opcode {
       bins add_ops[] = {SIMD_ADD_8, SIMD_ADD_16};
       bins sub_ops[] = {SIMD_SUB_8, SIMD_SUB_16};
       bins mul_ops[] = {SIMD_MUL_8, SIMD_MUL_16};
       bins sat_ops[] = {SIMD_SAT_ADD, SIMD_SAT_SUB};
     }

     cp_data_pattern: coverpoint data_pattern {
       bins all_zero = {32'h00000000};
       bins all_one = {32'hFFFFFFFF};
       bins alternating[] = {32'hAAAAAAAA, 32'h55555555};
       bins boundary[] = {32'h7F7F7F7F, 32'h80808080};
     }
   endgroup
   ```

## 💡 Excel文档最佳实践模式总结

### 1. 文档复杂度管理

**复杂度与文档大小的关系：**
```
文档复杂度分级：
├── 简单 (5-10KB): 单一功能，直接验证
├── 中等 (10-20KB): 子系统，多个相关功能
├── 复杂 (20-40KB): 完整功能模块，多交互
└── 超复杂 (40KB+): 完整规范实现，系统级
```

### 2. 验证策略模式

**常见验证策略组合：**
1. **协议验证模式** (OBI, Debug)
   - 断言 + 功能覆盖率 + 随机测试

2. **指令验证模式** (ISA, Xpulp)
   - 参考模型 + 定向测试 + 约束随机

3. **系统功能模式** (Interrupt, Pipeline)
   - 功能覆盖率 + 系统测试 + 交互验证

### 3. 覆盖率设计模式

**覆盖率复杂度分级：**
- **基础覆盖率** - 单变量coverpoint
- **交叉覆盖率** - 2-3个变量的cross
- **条件覆盖率** - 复杂条件和状态机
- **系统覆盖率** - 端到端场景覆盖

---

**注意：** 这些分析基于文档大小、功能复杂度和相关规范的推断。实际文档内容可能有所不同，建议结合实际Excel文档内容进行学习和验证。