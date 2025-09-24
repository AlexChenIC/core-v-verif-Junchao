# 验证计划模板库

本目录提供完整的验证计划模板集合，基于CV32E40P项目的成功实践，为CVA6和其他RISC-V核心验证项目提供标准化起点。

## 📋 模板分类

### 1. Excel验证计划模板

| 模板文件 | 适用场景 | 复杂度 | 说明 |
|----------|----------|--------|------|
| `BasicISA_VerifPlan_Template.md` | 基础指令集验证 | ⭐⭐⭐ | RV32I/RV64I通用模板 |
| `SystemFunction_VerifPlan_Template.md` | 系统级功能验证 | ⭐⭐⭐⭐ | 中断、异常、CSR等 |
| `Microarch_VerifPlan_Template.md` | 微架构验证 | ⭐⭐⭐⭐⭐ | 流水线、缓存、总线等 |
| `Integration_VerifPlan_Template.md` | 集成验证 | ⭐⭐⭐⭐⭐ | 系统集成和合规性 |

### 2. 审查模板

| 模板文件 | 用途 | 角色 |
|----------|------|------|
| `PeerReview_Template.md` | 同行评审模板 | 验证工程师 |
| `TechnicalReview_Template.md` | 技术审查模板 | 技术专家 |
| `ManagementReview_Template.md` | 管理层审查模板 | 项目经理 |

### 3. 状态追踪模板

| 模板文件 | 功能 | 更新频率 |
|----------|------|----------|
| `StatusReport_Template.md` | 状态报告模板 | 每周 |
| `ProgressDashboard_Template.html` | 进度面板模板 | 实时 |
| `MilestoneTracker_Template.md` | 里程碑追踪 | 每月 |

## 🚀 快速开始

### 步骤1: 选择合适的模板

```bash
# 对于新的基础指令集验证计划
cp BasicISA_VerifPlan_Template.md MyCore_RV64I_VerifPlan.md

# 对于系统级功能验证
cp SystemFunction_VerifPlan_Template.md MyCore_Interrupts_VerifPlan.md
```

### 步骤2: 定制模板内容

1. **替换占位符变量**
   - `{CORE_NAME}` → 你的核心名称 (如 CVA6)
   - `{ISA_VERSION}` → ISA版本 (如 RV64I)
   - `{PROJECT_NAME}` → 项目名称
   - `{AUTHOR_NAME}` → 作者姓名

2. **根据实际需求调整**
   - 添加特有功能验证条目
   - 修改覆盖率目标
   - 更新参考文档链接

### 步骤3: 使用自动化工具

```bash
# 使用模板生成器
./template_generator.py --core CVA6 --isa RV64I --template BasicISA

# 批量验证模板完整性
./validate_templates.py --directory ./my_verification_plans
```

## 📖 模板使用指南

### Excel模板结构说明

所有Excel模板遵循统一的列结构：

```
Column A: ID (条目编号)
Column B: Requirement Location (需求位置)
Column C: Feature (功能)
Column D: Sub-Feature (子功能)
Column E: Verification Goals (验证目标)
Column F: Pass/Fail Criteria (通过/失败标准)
Column G: Coverage Method (覆盖率方法)
Column H: Priority (优先级)
Column I: Owner (负责人)
Column J: Target Date (目标日期)
Column K: Status (状态)
Column L: Comments (备注)
```

### 质量标准

每个模板都包含：
- ✅ **完整性检查**：所有必需字段都有内容
- ✅ **一致性标准**：术语和格式统一
- ✅ **可追溯性**：每项都可追溯到需求
- ✅ **可测试性**：每个目标都是可验证的

### 版本控制

- 模板版本号：`v1.x` (基于CV32E40P经验)
- 更新日志：参见各模板文件的更新历史
- 兼容性：向前兼容，建议定期更新

---

**注意**：这些模板基于OpenHW Group CORE-V项目的实际经验，已在CV32E40P项目中验证有效。使用前请根据具体项目需求进行适当调整。