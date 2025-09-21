# 常用验证工作流程速查表

## 🎯 日常工作流程

### 🚀 1. 环境启动和基础验证

**标准启动流程：**
```bash
# 1. 环境准备
cd cv32e40p/sim/uvmt
source setup-env.sh  # 如果存在

# 2. 快速功能检查
make hello-world

# 3. 完整编译检查
make comp

# 4. 带波形的调试运行
make hello-world WAVES=1

# 5. 覆盖率收集
make hello-world COV=1
```

**检查项清单：**
- [ ] 编译无错误和警告
- [ ] Hello world测试通过
- [ ] 波形文件正确生成
- [ ] 覆盖率数据正常收集

---

### 🔧 2. 新测试开发流程

**Step-by-Step流程：**

```bash
# Step 1: 创建测试文件
cd cv32e40p/tests/uvmt
cp uvmt_cv32e40p_hello_world_test.sv uvmt_cv32e40p_my_test.sv

# Step 2: 修改测试类名和内容
# 编辑 uvmt_cv32e40p_my_test.sv

# Step 3: 注册测试
# 在 uvmt_cv32e40p_test_pkg.sv 中添加:
# `include "uvmt_cv32e40p_my_test.sv"

# Step 4: 编译测试
make comp

# Step 5: 运行测试
make test TEST=my_test

# Step 6: 分析结果
make test TEST=my_test WAVES=1
```

**测试开发模板：**
```systemverilog
class uvmt_cv32e40p_my_test_c extends uvmt_cv32e40p_base_test_c;

  `uvm_component_utils(uvmt_cv32e40p_my_test_c)

  function new(string name = "uvmt_cv32e40p_my_test",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void configure_test();
    super.configure_test();

    // 自定义配置
    test_cfg.timeout_cycles = 100000;
    test_cfg.enable_detailed_logging = 1;
  endfunction

  virtual task start_sequences();
    my_custom_seq_c my_seq;

    my_seq = my_custom_seq_c::type_id::create("my_seq");
    my_seq.start(env.sequencer);
  endtask

endclass
```

---

### 🐛 3. 调试工作流程

**系统性调试步骤：**

```bash
# Step 1: 重现问题
make test TEST=failing_test WAVES=1

# Step 2: 分析日志
grep -i "error\|fatal\|warning" sim_results/transcript

# Step 3: 检查波形
# 使用 questasim/modelsim:
# vsim -view sim_results/waves.wlf

# Step 4: 增加调试信息
make test TEST=failing_test UVM_VERBOSITY=UVM_HIGH WAVES=1

# Step 5: 隔离问题
# 创建最小复现测试案例

# Step 6: 根因分析
# 分析RTL、UVM环境、或测试代码
```

**调试技巧速查：**
```systemverilog
// 1. 增加调试信息
`uvm_info("DEBUG", $sformatf("Signal value: %h", signal), UVM_LOW)

// 2. 断点和等待
wait(condition);
#1000; // 添加延时观察

// 3. 强制信号值
force dut.signal = value;
#1000;
release dut.signal;

// 4. 监控信号变化
$monitor("Time:%0t Signal:%h", $time, signal);
```

---

### 📊 4. 覆盖率分析流程

**覆盖率收集和分析：**

```bash
# Step 1: 收集覆盖率
make regression COV=1

# Step 2: 生成覆盖率报告
# (具体命令取决于仿真器)
# For Questa:
# vcover report -details sim_results/coverage.ucdb

# Step 3: 查看覆盖率报告
# 在浏览器中打开HTML报告

# Step 4: 分析覆盖率缺口
python3 scripts/analyze_coverage.py coverage_report.html

# Step 5: 生成改进建议
# 基于缺口分析制定测试改进计划
```

**覆盖率优化策略：**
```systemverilog
// 1. 添加功能覆盖点
covergroup my_cg;
  cp_new_feature: coverpoint new_feature_signal {
    bins low  = {[0:7]};
    bins high = {[8:15]};
  }
endgroup

// 2. 排除不关心的覆盖点
covergroup existing_cg;
  option.per_instance = 1;

  cp_signal: coverpoint signal {
    ignore_bins ignore_invalid = {invalid_values};
  }
endgroup

// 3. 添加交叉覆盖
cross cp_signal1, cp_signal2 {
  ignore_bins illegal = cross_signal1_signal2 with
    (cp_signal1 == illegal_val);
}
```

---

### 🔄 5. 回归测试流程

**自动化回归测试：**

```bash
# Step 1: 准备回归测试列表
cat > regression_list.txt << EOF
hello_world
arithmetic_basic
memory_operations
interrupt_basic
debug_basic
EOF

# Step 2: 运行回归测试
./scripts/run_regression.sh regression_list.txt

# Step 3: 生成回归报告
./scripts/generate_regression_report.sh

# Step 4: 分析失败的测试
./scripts/analyze_failures.sh
```

**回归测试脚本模板：**
```bash
#!/bin/bash
# run_regression.sh

TEST_LIST=$1
PASSED=0
FAILED=0
FAILED_TESTS=""

while read test_name; do
    echo "Running test: $test_name"

    if make test TEST=$test_name > logs/${test_name}.log 2>&1; then
        echo "✅ $test_name PASSED"
        ((PASSED++))
    else
        echo "❌ $test_name FAILED"
        ((FAILED++))
        FAILED_TESTS="$FAILED_TESTS $test_name"
    fi
done < $TEST_LIST

echo "=== 回归测试结果 ==="
echo "通过: $PASSED"
echo "失败: $FAILED"
if [ $FAILED -gt 0 ]; then
    echo "失败测试: $FAILED_TESTS"
fi
```

---

## 🛠️ 环境配置工作流程

### ⚙️ 1. 新核心环境搭建

**完整搭建流程：**
```bash
# Step 1: 创建目录结构
NEW_CORE="my_core"
mkdir -p ${NEW_CORE}/{env,sim,tb,tests,docs}

# Step 2: 复制和修改基础文件
cp -r cv32e40p/sim/uvmt ${NEW_CORE}/sim/
cp -r cv32e40p/tb/uvmt ${NEW_CORE}/tb/

# Step 3: 修改文件名和内容
cd ${NEW_CORE}
find . -name "*cv32e40p*" -exec rename 's/cv32e40p/${NEW_CORE}/g' {} \;

# Step 4: 更新文件内容
find . -name "*.sv" -exec sed -i 's/cv32e40p/${NEW_CORE}/g' {} \;
find . -name "*.mk" -exec sed -i 's/cv32e40p/${NEW_CORE}/g' {} \;

# Step 5: 配置RTL集成
# 修改 ExternalRepos.mk 中的仓库信息

# Step 6: 验证基础功能
make comp
make hello-world
```

### 🔌 2. 接口适配流程

**接口适配检查清单：**
```systemverilog
// 1. 检查信号位宽兼容性
parameter ADDR_WIDTH = 64;  // 从32位改为64位
parameter DATA_WIDTH = 64;  // 从32位改为64位

// 2. 检查协议兼容性
// OBI → AXI 需要开发桥接
// OBI → OBI 可直接复用

// 3. 检查时钟域
// 单时钟 → 多时钟需要添加CDC逻辑

// 4. 检查复位策略
// 同步复位 → 异步复位需要修改复位逻辑
```

**接口适配模板：**
```systemverilog
// 信号位宽适配
generate
  if (ADDR_WIDTH == 32) begin
    assign dut_addr = interface_addr[31:0];
  end else begin
    assign dut_addr = interface_addr;
  end
endgenerate

// 协议转换桥接
obi_to_axi_bridge bridge_inst (
  .obi_if  (obi_interface),
  .axi_if  (axi_interface)
);
```

---

## 🚨 问题排查工作流程

### 🔍 1. 编译问题排查

**常见编译错误处理：**
```bash
# 错误类型1: 文件找不到
# 解决方案: 检查文件路径和Makefile配置
grep -r "missing_file" mk/

# 错误类型2: 语法错误
# 解决方案: 检查SystemVerilog语法
vlog -lint filename.sv

# 错误类型3: 包依赖问题
# 解决方案: 检查包导入顺序
# 在编译文件列表中调整顺序

# 错误类型4: 预处理宏问题
# 解决方案: 检查宏定义
grep -r "MACRO_NAME" .
```

### ⚡ 2. 仿真问题排查

**仿真问题诊断流程：**
```bash
# Step 1: 检查基础设置
make test TEST=hello_world UVM_VERBOSITY=UVM_HIGH

# Step 2: 检查时序问题
# 在波形中查看时钟和复位
# 确认接口时序正确

# Step 3: 检查UVM phase问题
# 查看build_phase, connect_phase日志
grep -i "phase" transcript

# Step 4: 检查sequence执行
# 确认sequence正确启动和完成
grep -i "sequence" transcript

# Step 5: 检查DUT连接
# 验证DUT wrapper的信号连接
```

### 📊 3. 覆盖率问题排查

**覆盖率问题诊断：**
```bash
# 问题1: 覆盖率为0
# 检查覆盖率使能和采样
grep -i "coverage" transcript

# 问题2: 覆盖率不增长
# 检查覆盖点定义和采样条件

# 问题3: 覆盖率报告生成失败
# 检查覆盖率数据库和工具配置
```

---

## 💡 效率提升技巧

### ⚡ 1. 快速命令组合

```bash
# 常用命令别名
alias quick_test="make test TEST=hello_world"
alias debug_test="make test TEST=hello_world WAVES=1 UVM_VERBOSITY=UVM_HIGH"
alias cov_test="make test TEST=hello_world COV=1"

# 快速清理和重新编译
alias clean_comp="make clean && make comp"

# 快速查看最新日志
alias latest_log="ls -t sim_results/*.log | head -1 | xargs cat"
```

### 🔧 2. 调试加速技巧

```bash
# 1. 使用并行编译
make comp -j8

# 2. 增量编译
make comp INCREMENTAL=1

# 3. 跳过不必要的检查
make test TEST=my_test QUICK_RUN=1

# 4. 使用快速仿真模式
make test TEST=my_test FAST_SIM=1
```

### 📁 3. 文件组织技巧

```bash
# 创建工作目录结构
mkdir -p work/{logs,waves,coverage,scripts}

# 自动归档日志
mv sim_results/*.log work/logs/$(date +%Y%m%d)/

# 快速查找文件
find . -name "*test*" -type f | grep -v ".git"
```

---

**🔄 持续改进：根据项目经验持续更新和优化这些工作流程！**