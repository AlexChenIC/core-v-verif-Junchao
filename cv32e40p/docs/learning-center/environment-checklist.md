# CV32E40P 环境配置检查清单 ✅

这是 CV32E40P 验证环境的完整配置检查清单。你可以手动逐项检查，或使用自动化脚本进行快速验证。

## 🚀 快速自动检查

```bash
# 运行自动检查脚本
cd cv32e40p/docs/learning-center/
bash check-environment.sh
```

## 📋 手动检查清单

### 1️⃣ 基础工具检查

#### 必需工具
- [ ] **Make 构建工具**
  ```bash
  make --version
  # 应该显示 GNU Make 版本信息
  ```

- [ ] **Git 版本控制**
  ```bash
  git --version
  # 应该显示 Git 版本信息（建议 2.20+）
  ```

- [ ] **Python 3**
  ```bash
  python3 --version
  # 应该显示 Python 3.6+ 版本
  ```

- [ ] **Bash Shell**
  ```bash
  echo $BASH_VERSION
  # 应该显示 Bash 版本信息
  ```

#### 可选工具
- [ ] **GTKWave** (用于波形查看)
  ```bash
  which gtkwave
  ```

- [ ] **Vim/Emacs** (代码编辑)
  ```bash
  which vim || which emacs
  ```

### 2️⃣ RISC-V 工具链检查

#### 核心编译器
- [ ] **RISC-V GCC**
  ```bash
  which riscv32-unknown-elf-gcc
  riscv32-unknown-elf-gcc --version
  # 应该显示 RISC-V GCC 版本信息
  ```

- [ ] **RISC-V 二进制工具**
  ```bash
  which riscv32-unknown-elf-objdump
  which riscv32-unknown-elf-objcopy
  which riscv32-unknown-elf-readelf
  ```

#### 编译测试
- [ ] **测试编译功能**
  ```bash
  echo 'int main(){return 0;}' > test.c
  riscv32-unknown-elf-gcc -o test.elf test.c
  file test.elf
  rm test.c test.elf
  # 应该成功编译并生成 RISC-V ELF 文件
  ```

### 3️⃣ 仿真器检查

选择并检查至少一个仿真器：

#### Metrics DSim
- [ ] **DSim 可用性**
  ```bash
  which dsim
  dsim -version
  # 检查许可证是否可用
  ```

#### Cadence Xcelium
- [ ] **Xrun 可用性**
  ```bash
  which xrun
  xrun -version
  # 检查许可证是否可用
  ```

#### Synopsys VCS
- [ ] **VCS 可用性**
  ```bash
  which vsim
  vsim -version
  # 检查许可证是否可用
  ```

#### Aldec Riviera
- [ ] **Riviera 可用性**
  ```bash
  which riviera
  riviera -version
  ```

### 4️⃣ 环境变量检查

#### 必需环境变量
- [ ] **RISCV 工具链路径**
  ```bash
  echo $RISCV
  # 应该指向 RISC-V 工具链安装目录
  # 例如：/opt/riscv 或 /usr/local/riscv
  ```

- [ ] **PATH 包含工具链**
  ```bash
  echo $PATH | grep -q "$RISCV/bin" && echo "包含" || echo "未包含"
  # 应该显示 "包含"
  ```

#### 推荐环境变量
- [ ] **CV_CORE 核心类型**
  ```bash
  echo $CV_CORE
  # 推荐设置为 CV32E40P
  ```

- [ ] **CV_SIMULATOR 仿真器**
  ```bash
  echo $CV_SIMULATOR
  # 设置为你使用的仿真器：dsim/xrun/vsim/riviera
  ```

- [ ] **CORE_V_VERIF 项目根目录**
  ```bash
  echo $CORE_V_VERIF
  # 指向 core-v-verif 项目根目录
  ```

### 5️⃣ 项目结构检查

#### 核心目录结构
- [ ] **CV32E40P 主目录**
  ```bash
  ls cv32e40p/
  # 应该看到：sim/ tests/ tb/ env/ docs/
  ```

- [ ] **仿真目录**
  ```bash
  ls cv32e40p/sim/
  # 应该看到：uvmt/ ExternalRepos.mk 等
  ```

- [ ] **测试目录**
  ```bash
  ls cv32e40p/tests/
  # 应该看到：programs/ uvmt/
  ```

- [ ] **主 Makefile**
  ```bash
  ls cv32e40p/sim/uvmt/Makefile
  # 文件应该存在
  ```

#### 关键配置文件
- [ ] **外部仓库配置**
  ```bash
  ls cv32e40p/sim/ExternalRepos.mk
  # 文件应该存在
  ```

- [ ] **测试程序目录**
  ```bash
  ls cv32e40p/tests/programs/custom/hello-world/
  # 应该看到：hello-world.c test.yaml 等
  ```

### 6️⃣ 外部依赖检查

运行以下命令克隆所有外部依赖，然后检查：

```bash
cd cv32e40p/sim/uvmt/
make clone_all
```

#### Google RISC-V DV
- [ ] **RISC-V DV 随机测试生成器**
  ```bash
  ls cv32e40p/vendor_lib/google/riscv-dv/
  # 应该包含 Python 脚本和配置文件
  ```

#### RISC-V 合规性测试
- [ ] **RISC-V 合规性测试套件**
  ```bash
  ls cv32e40p/vendor_lib/riscv/riscv-compliance/
  # 应该包含测试程序和 Makefile
  ```

#### EMBench 基准测试
- [ ] **EMBench IoT 基准测试**
  ```bash
  ls cv32e40p/vendor_lib/embench/
  # 应该包含基准测试程序
  ```

#### SystemVerilog 实用库
- [ ] **SVLIB 库**
  ```bash
  ls cv32e40p/vendor_lib/verilab/svlib/
  # 应该包含 SystemVerilog 库文件
  ```

#### Imperas 参考模型
- [ ] **OVPsim 模型**
  ```bash
  ls cv32e40p/vendor_lib/imperas/
  # 应该包含 Imperas 模型文件
  ```

### 7️⃣ 权限和资源检查

#### 文件权限
- [ ] **临时目录权限**
  ```bash
  [ -w /tmp ] && echo "可写" || echo "不可写"
  # 应该显示 "可写"
  ```

- [ ] **项目目录权限**
  ```bash
  [ -w . ] && echo "可写" || echo "不可写"
  # 应该显示 "可写"
  ```

#### 系统资源
- [ ] **可用内存**
  ```bash
  free -h
  # 建议至少 4GB 可用内存
  ```

- [ ] **可用磁盘空间**
  ```bash
  df -h .
  # 建议至少 10GB 可用空间
  ```

### 8️⃣ 功能测试

#### Makefile 系统测试
- [ ] **查看帮助信息**
  ```bash
  cd cv32e40p/sim/uvmt/
  make help
  # 应该显示可用的 make 目标
  ```

- [ ] **测试基本功能**
  ```bash
  make test TEST=hello-world DRY_RUN=1
  # 应该显示将要执行的命令，不实际运行
  ```

#### 快速烟雾测试
- [ ] **运行 Hello World 测试**
  ```bash
  make test TEST=hello-world
  # 如果环境配置正确，应该成功完成
  ```

## 🔧 常见问题解决方案

### 问题 1：找不到 RISC-V 工具链

**症状：**
```bash
riscv32-unknown-elf-gcc: command not found
```

**解决方案：**
1. 下载并安装 RISC-V 工具链
2. 设置环境变量：
   ```bash
   export RISCV=/path/to/riscv-toolchain
   export PATH=$RISCV/bin:$PATH
   ```

### 问题 2：仿真器许可证问题

**症状：**
```bash
License checkout failed for simulator
```

**解决方案：**
1. 检查许可证服务器连接
2. 验证环境变量设置
3. 联系系统管理员或仿真器厂商

### 问题 3：外部依赖克隆失败

**症状：**
```bash
Failed to clone repository
```

**解决方案：**
1. 检查网络连接
2. 配置 Git 代理（如需要）
3. 手动克隆失败的仓库

### 问题 4：编译错误

**症状：**
```bash
Compilation failed
```

**解决方案：**
1. 检查工具链版本兼容性
2. 清理编译缓存：`make clean_all`
3. 检查源码文件完整性

## 📊 检查结果评估

### 🟢 环境完美 (所有项目通过)
- 可以立即开始验证工作
- 建议运行完整的回归测试

### 🟡 环境良好 (1-3 个警告)
- 可以进行基本验证工作
- 建议逐步完善配置

### 🔴 环境需要修复 (多个失败项目)
- 必须先修复基础配置
- 参考解决方案逐项处理

## 🚀 配置完成后的下一步

### 验证环境测试
```bash
# 运行基础测试
make test TEST=hello-world

# 运行调试测试
make test TEST=debug-test

# 运行中断测试
make test TEST=interrupt-test
```

### 学习资源
- **[5分钟快速开始](quick-start-5min.md)** - 立即开始第一个测试
- **[Hello World 流程详解](hello-world-flow/README.md)** - 深入理解验证流程
- **[调试技巧](hello-world-flow/07-debug-tips.md)** - 解决常见问题

## 💡 维护提示

### 定期检查
- 每月运行一次环境检查
- 更新外部依赖：`make update_deps`
- 清理临时文件：`make clean_all`

### 性能优化
- 监控磁盘空间使用
- 定期更新工具链版本
- 配置仿真器缓存目录

---

*📝 建议将此清单保存为你的环境配置参考，并在遇到问题时首先检查这些基础设置。*

*🔄 此清单会随着项目发展持续更新，请关注最新版本。*