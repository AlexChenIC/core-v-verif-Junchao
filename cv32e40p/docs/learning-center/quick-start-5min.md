# 5 分钟快速开始指南 ⚡

欢迎来到 CV32E40P 验证环境的"闪电入门"！这个指南将帮助你在 5 分钟内运行你的第一个测试。

## 🎯 目标：运行 Hello World 测试

我们的目标很简单：从零开始，5分钟内成功运行一个基本的 CV32E40P 验证测试。

## ⏱️ 第 1 分钟：环境检查

### 快速环境验证
```bash
# 检查 RISC-V 工具链
which riscv32-unknown-elf-gcc
echo $RISCV

# 检查仿真器（任选其一）
which dsim || which xrun || which vsim

# 检查项目目录
cd /path/to/core-v-verif  # 替换为你的实际路径
ls cv32e40p/
```

### 如果检查失败 ❌
```bash
# 快速设置环境变量（示例）
export RISCV=/path/to/riscv-gcc        # 替换为实际路径
export PATH=$RISCV/bin:$PATH
export CV_SIMULATOR=dsim               # 或 xrun、vsim
```

## ⏱️ 第 2 分钟：克隆外部依赖

```bash
# 进入 CV32E40P 仿真目录
cd cv32e40p/sim/uvmt/

# 克隆所有外部依赖（第一次运行必须）
make clone_all
```

> 💡 **提示**: 这步骤只需要运行一次，后续可以跳过

## ⏱️ 第 3-4 分钟：运行 Hello World 测试

```bash
# 运行基础的 Hello World 测试
make test TEST=hello-world

# 如果你想看详细输出，添加 VERBOSE=1
make test TEST=hello-world VERBOSE=1
```

### 等待测试完成 ⏳
你应该看到类似这样的输出：
```
# 编译阶段
Compiling hello-world.c...
Compiling UVM environment...

# 仿真阶段
Starting simulation...
UVM_INFO: Test PASSED
Simulation finished successfully
```

## ⏱️ 第 5 分钟：验证结果

### 成功的标志 ✅
```bash
# 检查测试结果
grep "Test.*PASSED" hello-world.log

# 查看生成的文件
ls -la hello-world.*
```

你应该看到：
- `✅ Test PASSED` 在日志中
- 生成了 `hello-world.log` 文件
- 可能有 `hello-world.vcd` 波形文件

### 如果测试失败 ❌
```bash
# 查看错误信息
tail -50 hello-world.log

# 常见问题快速修复
make clean               # 清理环境
make test TEST=hello-world TIMEOUT=20000000  # 增加超时时间
```

## 🎉 恭喜！你已经成功了！

如果看到 `Test PASSED`，说明：
- ✅ 环境配置正确
- ✅ 工具链工作正常
- ✅ CV32E40P 核心功能正常
- ✅ UVM 验证环境运行成功

## 🚀 下一步可以做什么？

### 📊 查看更多信息
```bash
# 查看详细日志
less hello-world.log

# 如果有波形文件，可以查看
gtkwave hello-world.vcd &  # 如果安装了 GTKWave
```

### 🧪 尝试其他测试
```bash
# 运行其他简单测试
make test TEST=debug-test
make test TEST=interrupt-test

# 查看所有可用测试
ls ../../tests/programs/custom/
```

### 📚 深入学习
- **[学习中心首页](README.md)** - 系统学习验证环境
- **[Hello World 流程详解](hello-world-flow/README.md)** - 深入理解刚才运行的测试
- **[调试技巧](hello-world-flow/07-debug-tips.md)** - 当遇到问题时参考

## 🆘 快速故障排除

### 问题 1：找不到工具链
```bash
# 错误：riscv32-unknown-elf-gcc: command not found
# 解决：安装或正确设置 RISC-V 工具链
export RISCV=/opt/riscv      # 示例路径
export PATH=$RISCV/bin:$PATH
```

### 问题 2：仿真器不可用
```bash
# 错误：Simulator not found
# 解决：指定可用的仿真器
make test TEST=hello-world SIMULATOR=xrun    # 尝试 Xrun
make test TEST=hello-world SIMULATOR=vsim    # 尝试 VCS
```

### 问题 3：测试超时
```bash
# 错误：Test timeout
# 解决：增加超时时间
make test TEST=hello-world TIMEOUT=50000000
```

### 问题 4：权限错误
```bash
# 错误：Permission denied
# 解决：清理临时文件
make clean_all
rm -rf /tmp/*core-v-verif*
```

## 💡 实用技巧

### 🔧 常用命令组合
```bash
# 清理 + 测试（当遇到奇怪问题时）
make clean && make test TEST=hello-world

# 并行运行（如果系统性能好）
make test TEST=hello-world PARALLEL=1

# 生成波形用于调试
make test TEST=hello-world WAVES=1
```

### 📈 性能优化
```bash
# 使用最快的编译选项
make test TEST=hello-world COMP_FLAGS="-O2"

# 如果不需要覆盖率，可以禁用
make test TEST=hello-world COVERAGE=0
```

## 🎯 快速参考卡片

| 命令 | 用途 |
|------|------|
| `make clone_all` | 下载外部依赖（仅第一次） |
| `make test TEST=hello-world` | 运行基础测试 |
| `make clean` | 清理编译文件 |
| `make clean_all` | 完全清理环境 |
| `make help` | 查看所有可用命令 |

| 环境变量 | 示例值 | 说明 |
|----------|--------|------|
| `RISCV` | `/opt/riscv` | RISC-V 工具链路径 |
| `CV_SIMULATOR` | `dsim` | 仿真器选择 |
| `CV_CORE` | `CV32E40P` | 处理器核心类型 |

## 🎊 完成！

你现在已经：
- ✅ 成功运行了第一个 CV32E40P 测试
- ✅ 验证了开发环境的正确性
- ✅ 了解了基本的验证流程
- ✅ 掌握了快速故障排除技巧

**现在你可以自信地开始探索更复杂的验证场景了！** 🚀

---

*⏱️ 如果整个过程超过了 5 分钟，不要担心！第一次设置总是需要更多时间。一旦环境配置好，后续的测试运行会非常快速。*

*💡 建议将这个页面收藏，作为日常开发的快速参考手册！*