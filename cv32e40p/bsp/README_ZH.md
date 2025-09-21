# CV32E40P 验证的板级支持包 (BSP)

此 BSP 提供支持在 CV32E40P 验证目标上运行程序的代码。它执行初始化任务（`crt0.S`）、处理中断/异常（`vectors.S`、`handlers.S`）、提供系统调用实现（`syscalls.c`）并包含链接器脚本（`link.ld`）来控制二进制文件中段的放置。

下面详细描述每个文件，然后是构建和使用 BSP 的说明。

## 📚 核心文件说明

### 🚀 C 运行时初始化 (crt0.S)

C 运行时文件 `crt0.S` 提供 `_start` 函数，这是程序的入口点并执行以下任务：

- **初始化全局和栈指针**：设置程序运行的基础环境
- **设置中断向量表**：将 `vector_table` 的地址存储在 `mtvec` 中，将低两位设置为 `0x2` 以选择向量化中断模式
- **清零 BSS 段**：初始化未初始化的全局变量
- **调用 C 构造函数初始化**：设置析构函数在退出时被调用
- **清零 argc 和 argv**：由于栈未初始化，清零这些值以防止未初始化值导致与参考结果不匹配
- **调用 main 函数**：执行用户主程序
- **处理程序退出**：如果 `main` 返回，则使用其返回代码调用 `exit`

### ⚡ 中断和异常处理

当 RISC-V 核心遇到中断/异常陷阱时，`pc` 被存储在 `mepc` 中，陷阱原因存储在 `mcause` 中。`mcause` 的 `MSB` 对于异常设置为 `0`，对于中断设置为 `1`；其余位 `mcause[MXLEN-2:0]` 包含异常代码。

`mcause` 值表定义在 [RISC-V 指令集手册第二卷：特权架构版本 20190608-Priv-MSU-Ratified](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMFDQC-and-Priv-v1.11/riscv-privileged-20190608.pdf) 的表 3.6 中。

核心根据存储在 `mtvec` 中的向量表的 `BASE` 地址和 `mcause` 中的异常代码值跳转到向量表中的位置。在向量化模式下，所有异常跳转到 `BASE`，中断跳转到 `BASE+4*mcause[XLEN-2:0]`。

#### 🎯 中断处理器详解

向量表在 `vectors.S` 中定义，可能跳转到 `handlers.S` 中的以下中断请求处理器之一：

**主要处理器：**

- **`u_sw_irq_handler`** - 处理用户软件中断和所有异常
  - 保存所有调用者保存的寄存器
  - 检查 `mcause` 并跳转到适当的处理器：
    - **断点**：跳转到 `handle_ebreak`
    - **非法指令**：跳转到 `handle_illegal`
    - **来自 M 模式的环境调用**：跳转到 `handle_ecall`
    - **任何其他异常或用户软件中断**：跳转到 `handle_unknown`

**机器模式中断处理器：**
- **`m_software_irq_handler`** - 处理机器模式软件中断
- **`m_timer_irq_handler`** - 处理机器模式定时器中断
- **`m_external_irq_handler`** - 处理机器模式外部中断

**CV32 快速中断处理器（平台扩展）：**
- **`m_fast0_irq_handler` 到 `m_fast15_irq_handler`** - 处理机器模式快速外部中断

> 📝 **注意**：目前大多数处理器跳转到 `__no_irq_handler`。具体行为将在未来的提交中定义。

**通用处理器：**
- **`__no_irq_handler`** - 循环打印 "no exception handler installed"

#### 🔧 异常处理器

以下异常处理器可能从 `u_sw_irq_handler` 调用：

- **`handle_ecall`** - 调用 `handle_syscall`，检查系统调用号并调用相应的系统调用函数
- **`handle_ebreak`** - 当前只是打印 "ebreak exception handler entered"
- **`handle_illegal_insn`** - 打印 "illegal instruction exception handler entered"
- **`unknown_handler`** - 当没有中断/异常处理器时调用。这是唯一不增加 `mepc` 的情况，因为我们不知道要采取的适当行动

#### 🔄 处理器返回机制

从 `u_sw_irq_handler` 返回：所有由 `u_sw_irq_handler` 调用的处理器在调用 `mret` 之前都会增加 `mepc`，除了 `unknown_handler`。需要增加 `mepc` 的处理器跳转到 `end_handler_incr_mepc`，否则跳转到 `end_handler_ret`。在最终调用 `mret` 之前恢复所有调用者保存的寄存器。

### 📞 系统调用 (syscalls.c)

在裸机系统上没有操作系统来处理系统调用，因此我们在 `syscalls.c` 中定义自己的系统调用。例如，`_write` 的实现一次输出一个字节到虚拟打印机外设。由于缺乏必要的操作系统支持（例如没有文件系统），许多函数提供了只是优雅失败的最小实现。

**系统调用约定：**
- 遵循 RISC-V 在 `newlib` 中使用的约定
- 参数在寄存器 `a0` 到 `a5` 中传递
- 系统调用 ID 在 `a7` 中传递（RV32E 上为 `t0`）
- 处理 `ecall` 时，`handle_ecall` 调用 `handle_syscall`，然后调用实现系统调用的适当函数

### 🔗 链接器脚本 (link.ld)

链接器脚本定义内存布局并控制从目标文件的输入段到输出二进制文件中输出段的映射。

`link.ld` 脚本基于标准的上游 RV32 链接器脚本，为 CV32E40P 进行了一些必要的更改：

#### 📍 内存布局：
```
ram: start=0x0, length=4MB
dbg: start=0x1A110800, length=2KB
```

#### 🎯 输出段放置：
- **`.vectors`** - start=ORIGIN(`ram`)
- **`.init`** - start=0x80
- **`.heap`** - 从数据末尾开始，向上增长
- **`.stack`** - 从 `ram` 末尾开始，向下增长
- **`.debugger`** - start=ORIGIN(`dbg`)
- **`.debugger_exception`** - start=0x1A110C00
- **`.debugger_stack`** - 跟随 `.debugger_exception`

## 🔧 构建和使用 BSP 库

### 构建 BSP
在此目录中可以按以下方式构建 BSP：

```bash
make
```

这会生成 `libcv-verif.a`，然后可以与测试程序链接，如下所示：

```bash
gcc test-program.c -nostartfiles -T/path/to/bsp/link.ld -L/path/to/bsp/ -lcv-verif
```

### 🎯 使用场景

#### 基础程序开发：
```bash
# 编译简单的 C 程序
riscv32-unknown-elf-gcc hello.c -nostartfiles -T/path/to/link.ld -L. -lcv-verif

# 编译汇编程序
riscv32-unknown-elf-as program.s -o program.o
riscv32-unknown-elf-ld program.o -T/path/to/link.ld -L. -lcv-verif
```

#### 高级功能验证：
```bash
# 包含中断处理的程序
riscv32-unknown-elf-gcc -DUSE_INTERRUPTS test.c -nostartfiles -T/path/to/link.ld -L. -lcv-verif

# 包含系统调用的程序
riscv32-unknown-elf-gcc -DUSE_SYSCALLS test.c -nostartfiles -T/path/to/link.ld -L. -lcv-verif
```

## 💡 开发技巧

### 自定义处理器
未来，这些处理器将通过将其标签定义为 `.weak` 符号而变得可覆盖。然后测试用例可以在必要时提供自己的处理器。

### 调试建议
1. 使用 `debugger` 段进行调试器相关代码
2. 检查 `mepc` 和 `mcause` 寄存器状态
3. 利用向量表结构进行中断调试
4. 监控栈指针和堆使用情况

## 🔗 相关文档

- **[CV32E40P 主页](../README_ZH.md)** - 项目总体介绍
- **[测试程序指南](../tests/README_ZH.md)** - 如何编写和运行测试
- **[仿真环境](../sim/README_ZH.md)** - 仿真环境设置
- **[学习中心](../docs/learning-center/README.md)** - 完整学习资源

---

*📝 本文档是 README.md 的中文翻译版本，详细说明了 CV32E40P 板级支持包的架构和使用方法。*