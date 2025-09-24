# {CORE_NAME} {ISA_VERSION} 基础指令集验证计划模板

**文档版本**: v1.0
**创建日期**: {DATE}
**作者**: {AUTHOR_NAME}
**项目**: {PROJECT_NAME}

基于CV32E40P成功实践的标准化验证计划模板，适用于RISC-V基础指令集验证。

## 📋 Excel表格结构

### Sheet 1: 验证计划主表

| ID | Requirement Location | Feature | Sub-Feature | Verification Goals | Pass/Fail Criteria | Coverage Method | Priority | Owner | Target Date | Status | Comments |
|----|---------------------|---------|-------------|-------------------|-------------------|-----------------|----------|-------|-------------|--------|----------|
| {ISA_VERSION}.001 | RISC-V ISA Spec 2.4 | Integer Computation | ADD Instruction | • Verify correct addition operation<br/>• Verify overflow detection<br/>• Verify register x0 handling | Self-checking test with reference model comparison | Functional Coverage:<br/>• Operand ranges<br/>• Overflow conditions | High | {AUTHOR_NAME} | {DATE+30} | Ready | - |
| {ISA_VERSION}.002 | RISC-V ISA Spec 2.4 | Integer Computation | SUB Instruction | • Verify correct subtraction<br/>• Verify underflow detection<br/>• Verify two's complement arithmetic | Signature-based verification | Functional Coverage:<br/>• Operand combinations<br/>• Edge cases | High | {AUTHOR_NAME} | {DATE+30} | Ready | - |

### Sheet 2: 覆盖率模型定义

| Coverage Group | Coverage Point | Bins Definition | Cross Coverage | Target % |
|----------------|----------------|-----------------|----------------|----------|
| arithmetic_ops_cg | cp_opcode | bins add_ops[] = {ADD, ADDI};<br/>bins sub_ops[] = {SUB}; | cross_operand_opcode | 100% |
| operand_values_cg | cp_rs1_value | bins zero = {0};<br/>bins max = {2^{XLEN}-1};<br/>bins boundary[] = {1, 2^31-1}; | cross_rs1_rs2 | 95% |

## 🎯 使用说明

### 1. 模板定制步骤

```bash
# 步骤1: 替换所有占位符
sed -i 's/{CORE_NAME}/CVA6/g' BasicISA_VerifPlan_Template.md
sed -i 's/{ISA_VERSION}/RV64I/g' BasicISA_VerifPlan_Template.md
sed -i 's/{PROJECT_NAME}/CVA6_Verification/g' BasicISA_VerifPlan_Template.md
sed -i 's/{AUTHOR_NAME}/Your_Name/g' BasicISA_VerifPlan_Template.md
sed -i 's/{DATE}/2024-01-15/g' BasicISA_VerifPlan_Template.md
sed -i 's/{XLEN}/64/g' BasicISA_VerifPlan_Template.md

# 步骤2: 生成Excel文件（需要Python环境）
python3 ../tools/md_to_excel_converter.py BasicISA_VerifPlan_Template.md
```

### 2. 完整指令列表模板

#### RV32I/RV64I 基础指令集

| 分类 | 指令 | 验证复杂度 | 关键验证点 |
|------|------|------------|------------|
| **整数运算** | ADD, ADDI, SUB | ⭐⭐⭐ | 溢出处理、x0特殊性 |
| **逻辑运算** | AND, ANDI, OR, ORI, XOR, XORI | ⭐⭐ | 位操作正确性 |
| **移位运算** | SLL, SLLI, SRL, SRLI, SRA, SRAI | ⭐⭐⭐ | 移位量处理、符号扩展 |
| **比较运算** | SLT, SLTI, SLTU, SLTIU | ⭐⭐⭐ | 有符号/无符号比较 |
| **分支指令** | BEQ, BNE, BLT, BGE, BLTU, BGEU | ⭐⭐⭐⭐ | 跳转目标计算、条件判断 |
| **跳转指令** | JAL, JALR | ⭐⭐⭐⭐ | 返回地址、目标地址计算 |
| **内存指令** | LB, LH, LW, LBU, LHU, SB, SH, SW | ⭐⭐⭐⭐⭐ | 地址对齐、内存访问、符号扩展 |
| **系统指令** | ECALL, EBREAK | ⭐⭐⭐⭐ | 异常产生、特权级转换 |

**RV64I专有指令（64位扩展）：**

| 指令 | 验证复杂度 | 关键验证点 |
|------|------------|------------|
| ADDIW, ADDW, SUBW | ⭐⭐⭐ | 32位运算结果的符号扩展 |
| SLLIW, SRLIW, SRAIW | ⭐⭐⭐ | 32位移位操作和符号扩展 |
| SLLW, SRLW, SRAW | ⭐⭐⭐ | 动态移位的32位处理 |
| LD, LWU, SD | ⭐⭐⭐⭐ | 64位内存访问、无符号32位加载 |

### 3. 验证目标模板

#### 标准验证目标格式

```
验证目标编写模板：
• 功能正确性: Verify [specific operation] produces correct result
• 边界条件: Verify [boundary condition] handling
• 异常情况: Verify [exception condition] generates proper exception
• 副作用: Verify no unexpected side effects occur
• 性能: Verify [operation] meets timing requirements
```

#### Pass/Fail标准模板

```
Pass/Fail标准模板：
✅ Pass条件:
  - All functional tests pass
  - Coverage targets achieved (>95%)
  - No assertion failures
  - Reference model matches 100%

❌ Fail条件:
  - Any functional test failure
  - Coverage below threshold (<90%)
  - Assertion violations detected
  - Reference model mismatches
```

## 🔧 高级定制选项

### 1. 针对特定核心的调整

```yaml
# CV32E40P特有配置
cv32e40p_specific:
  xlen: 32
  extensions: [M, C, Xpulp]
  special_features:
    - pulp_simd: true
    - pulp_bitmanip: true
    - pulp_multiply: true

# CVA6特有配置
cva6_specific:
  xlen: 64
  extensions: [M, A, F, D, C]
  special_features:
    - mmu_sv39: true
    - supervisor_mode: true
    - cache_system: true
```

### 2. 覆盖率模型扩展

```systemverilog
// 基础指令覆盖率模型模板
covergroup {ISA_VERSION}_instruction_cg @(posedge clk);

  // 指令类型覆盖
  cp_opcode: coverpoint instruction_opcode {
    bins arithmetic[] = {ADD, ADDI, SUB, ...};
    bins logical[] = {AND, ANDI, OR, ORI, ...};
    bins shift[] = {SLL, SLLI, SRL, SRLI, ...};
    bins branch[] = {BEQ, BNE, BLT, BGE, ...};
    bins jump[] = {JAL, JALR};
    bins memory[] = {LB, LH, LW, SB, SH, SW, ...};
    bins system[] = {ECALL, EBREAK};

    // RV64I特有指令
    bins word_ops[] = {ADDIW, ADDW, SUBW, ...}; // 仅64位
  }

  // 操作数覆盖
  cp_rs1_value: coverpoint rs1_value {
    bins zero = {0};
    bins small_pos[] = {[1:100]};
    bins large_pos[] = {[2^{XLEN-1}:2^{XLEN-1}+100]};
    bins small_neg[] = {[-100:-1]};
    bins large_neg[] = {[-(2^{XLEN-1}):-(2^{XLEN-1})+100]};
    bins boundary[] = {2^{XLEN-1}-1, -2^{XLEN-1}};
  }

  // 立即数覆盖
  cp_immediate: coverpoint immediate {
    bins zero = {0};
    bins positive[] = {[1:2047]};
    bins negative[] = {[-2048:-1]};
    bins boundary[] = {2047, -2048};
  }

  // 交叉覆盖
  cross_opcode_operands: cross cp_opcode, cp_rs1_value, cp_rs2_value {
    // 排除无效组合
    ignore_bins invalid_combinations = cross_opcode_operands with
      (cp_opcode inside {ADDI, ANDI, ORI, XORI} && cp_rs2_value != 0);
  }

endgroup
```

### 3. 测试用例生成指导

```python
# 测试用例生成模板
class {ISA_VERSION}TestGenerator:

    def generate_arithmetic_tests(self):
        """生成算术运算测试用例"""
        test_cases = []

        # 基础功能测试
        for opcode in ['ADD', 'SUB', 'AND', 'OR', 'XOR']:
            test_cases.extend(self.generate_basic_tests(opcode))

        # 边界条件测试
        test_cases.extend(self.generate_boundary_tests())

        # 随机测试
        test_cases.extend(self.generate_random_tests(1000))

        return test_cases

    def generate_basic_tests(self, opcode):
        """生成基础测试用例"""
        return [
            f"{opcode} x1, x2, x3  // 基本操作",
            f"{opcode} x0, x1, x2  // 目标寄存器x0",
            f"{opcode} x1, x0, x2  // 源寄存器x0",
            f"{opcode} x1, x2, x0  // 源寄存器x0"
        ]

    def generate_boundary_tests(self):
        """生成边界条件测试"""
        max_val = 2**({XLEN}-1) - 1
        min_val = -(2**({XLEN}-1))

        return [
            f"ADDI x1, x0, {max_val}    // 最大正数",
            f"ADDI x2, x0, {min_val}    // 最大负数",
            f"ADD x3, x1, x2           // 溢出测试"
        ]
```

## ✅ 质量检查清单

使用此模板前，请确保：

- [ ] **占位符替换完整**：所有 `{VARIABLE}` 都已替换
- [ ] **指令列表完整**：涵盖目标ISA的所有指令
- [ ] **验证目标明确**：每个条目都有清晰的验证目标
- [ ] **覆盖率模型合理**：覆盖率设计与验证目标匹配
- [ ] **优先级设置**：关键指令标记为高优先级
- [ ] **负责人分配**：每个条目都有明确的owner
- [ ] **时间计划合理**：目标日期符合项目timeline

---

**使用提示**：这个模板基于CV32E40P项目的实际经验，已经过充分验证。建议先用于简单指令集，积累经验后再扩展到复杂功能。