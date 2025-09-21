CORE-V-VERIF UVM 验证环境通用 Makefile
==================================

本目录包含 UVM 和 Core 测试平台的_通用_ Makefile，用于执行以下常见功能：<br>
- 克隆第三方仓库（Core RTL、库、ISG、RISC-V 合规性库等）
- 调用工具链将定向和/或随机测试程序编译为仿真用的机器码
- 调用工具链编译合规性测试程序用于仿真
- 在 DVT Eclipse IDE (https://dvteclipse.com/) 中导入源代码

在 core-v-verif UVM 环境中，**_测试用例_** 和 **_测试程序_** 的区别很重要：
* **测试用例**：从 uvm_test 扩展的 SystemVerilog 类，用于实例化和控制 UVM 环境。测试用例控制诸如是否以及何时断言中断、外部内存接口上循环时序的随机化等。
* **测试程序**：由核心 RTL 模型执行的 C 或汇编程序。
<br><br>
可能只有一个测试用例，但通常有许多测试程序。更多信息请参考 [验证策略](https://core-v-docs-verif-strat.readthedocs.io/en/latest/intro.html)
<br><br>
测试用例位于 `CV_CORE/tests/uvmt`。
测试程序可以在 `CV_CORE/tests/program` 中找到。
有关更多信息，请参阅这些目录中的 README。
<br><br>
要运行 UVM 环境，您需要：
- Imperas OVPsim 指令集仿真器的运行时许可证
- SystemVerilog 仿真器
- UVM-1.2 库
- RISC-V GCC 编译器
- 至少对 [Make](https://www.gnu.org/software/make/manual/) 和 Makefile 有一定的了解

## 🔧 必需的 COREV 环境变量

Makefile 使用一组通用的 shell 环境变量来控制单个仿真和/或回归。以下变量对于在 core-v-verif 中运行任何 `make` 调用**必须**设置。
这些可以在命令行上设置（例如 `make CV_SIMULATOR=xrun`）或在用户的 shell 环境中设置。
请注意，如果您从 `uvmt` 目录启动测试，Makefile 会推断 `CV_CORE`。

| 环境变量 | 描述  |
|---------|-------|
| CV_SIMULATOR | 所有工具使用的默认仿真器（dsim、vcs、xrun、vsim、riviera）。可以在任何 make 调用中覆盖。 |
| CV_CORE | 默认要仿真的核心。可以在任何 make 命令行中覆盖。 |
| CV_SW_TOOLCHAIN | 指向用于编译、汇编和/或链接测试程序的软件工具链安装路径。 |
| CV_SW_PREFIX | 软件工具链安装的前缀。 |

**注意：**
1. 在 core-v-verif 环境中运行任何测试都需要工具链，详情见下文。
2. 如果未设置 CV_CORE，从 `<core>/sim/uvmt` 目录运行仿真会自动将其设置为"core"。

工具链由一组可执行文件（例如 gcc、objcopy 等）组成，每个可执行文件通常具有 `$(CV_SW_TOOLCHAIN)/bin/$(CV_SW_PREFIX)` 的路径形式。
例如，如果您的工具链可执行文件位于 `/opt/riscv/bin/riscv32-unknown-elf-`，那么您应该将 `CV_SW_TOOLCHAIN` 设置为 **_/opt/riscv_**，将 `CV_SW_PREFIX` 设置为 **_riscv32-unknown-elf-_**。

## ⚙️ 可选的 COREV 环境变量

Makefile 使用一组通用的 shell 环境变量来控制单个仿真和/或回归。以下环境变量可以为任何 `make` 调用设置以运行测试，或在用户环境中设置以自定义设置。

| 环境变量 | 描述  |
|---------|-------|
| CV_SIM_PREFIX | 添加到所有仿真编译和/或执行调用之前。可用于调用作业调度工具（例如 LSF）。 |
| CV_TOOL_PREFIX | 添加到所有独立工具（即非交互式）仿真工具调用之前，如覆盖率工具和波形查看器。可用于调用作业调度工具（例如 LSF）。 |
| CV_RESULTS | 可选的仿真器输出重定向路径。默认为空，即仿真输出将位于 <i>&lt;core></i>/mk/uvmt/<i>&lt;simulator></i>\_results（如果给出相对路径）。也可以使用绝对路径，仿真输出将位于 $(CV\_RESULTS)/<i>&lt;simulator></i>\_results |
| CV_SW_MARCH | 要调用的工具链架构。默认是 `rv32imc`。 |
| CV_SW_CFLAGS | 传递给 $(CV_SW_CC) 的可选命令行参数（标志）。 |
| CV_SW_CC | 用于编译测试程序的 C 编译器的后缀名称。默认是 `gcc`。如果您使用 LLVM 工具链，通常会设置为 `cc`。 |

## 🧮 Imperas 参考模型

在 CORE-V-VERIF 中验证的许多 CORE-V 核心使用来自 [Imperas](https://www.imperas.com/) 的参考模型。
早期版本的 CORE-V-VERIF 使用 **_OVPsim 指令集仿真器_**，从 2023 年 3 月开始，我们已转换到 **_ImperasDV_**。
要购买 ImperasDV 的运行时许可证，请通过上述链接联系 Imperas。

要在没有参考模型的情况下运行 CORE-V-VERIF，请将 `USE_ISS` make 变量设置为"NO"：
```
$ make test TEST=hello-world SIMULATOR=<your-simulator> USE_ISS=NO
```
上述命令适用于所有测试，但请注意，CORE-V-VERIF 中的大多数测试程序不是自检查的，因此没有运行的参考模型，通过的仿真是空洞的。

## 🖥️ SystemVerilog 仿真器

任何实现对 [IEEE-1800-2017](https://ieeexplore.ieee.org/document/8299595) 完整支持的 SystemVerilog 仿真器都能够编译和运行此验证环境。Makefile 支持 Metrics **_dsim_**、Cadence **_Xcelium_**、Mentor 的 **_Questa_**、Aldec 的 **_Riviera-PRO_** 和 Synopsys **_VCS_** 仿真器。如果您有权访问此处未列出的 SystemVerilog 仿真器并希望为 Makefile 添加支持，您的 pull request 将受到热烈欢迎！

## 📚 UVM-1.2 库

core-v-verif 中的 UVM 环境需要使用 UVM 库的 1.2 版本（1.1 版本不够）。通常，UVM 库随 SystemVerilog 仿真器的分发一起提供。将您的 shell 环境变量 `UVM_HOME` 指向您的仿真器的 UVM 库。例如，Metrics dsim 用户将有类似这样的设置：<br>`export UVM_HOME=/tools/Metrics/dsim/20191112.8.0/uvm-1.2`。
<br><br>
或者，您可以从 [Accellera](https://www.accellera.org/downloads/standards/uvm) 下载源代码。UVM LRM（IEEE-1800.2）可以从 [IEEE 标准协会](https://standards.ieee.org/) 获得。

## 🔗 工具链

编译测试程序需要 RISC-V 交叉编译器，通常称为"工具链"。详细的安装说明请参见 [TOOLCHAIN](./TOOLCHAIN.md)。

## ⚙️ Makefile 系统

`Make` 用于生成编译和运行仿真的命令行。<br>
- `CV_CORE/sim/uvmt/Makefile` 是用户可以调用仿真的'根' Makefile。
这个 Makefile 基本上是空的，包含：
- `CV_CORE/sim/ExternalRepos.mk` 应该用于定义指向第三方库的变量。这包括要仿真的 RTL 仓库；Google riscv-dv；RISCV 合规性套件和其他外部仓库。
- `CORE-V-VERIF/mk/uvmt/uvmt.mk`，它实现仿真执行目标并包含：
- `CORE-V-VERIF/mk/Common.mk` 支持所有通用变量、规则和目标，包括克隆 RTL 的特定目标。
<br><br>
仿真器特定的 Makefile 用于构建运行特定测试与特定仿真器的命令行。这些文件的组织如下所示：
```
CORE-V-VERIF/
     |
     +--- mk/
     |     +--- Common.mk                       # 通用变量和目标
     |     +--- uvmt/
     |            +--- uvmt.mk                  # 仿真 makefile（包含 ../Common.mk 和仿真器特定的 mk）
     |            +--- vcs.mk                   # Synopsys VCS
     |            +--- vsim.mk                  # Mentor Questa
     |            +--- dsim.mk                  # Metrics dsim
     |            +--- xrun.mk                  # Cadance Xcelium
     |            +--- riviera.mk               # Aldec Riviera-PRO
     |            +--- <other_simulators>.mk
     +--- CV_CORE/
            +--- sim/
                   +--- ExternalRepos.mk         # 外部仓库的 URL、哈希（RTL、riscv-dv 等）
                   +--- uvmt/
                          +--- Makefile          # "根" Makefile
                                                 # 包含 ../ExternalRepos.mk 和 CORE-V-VERIF/mk/uvmt/uvmt.mk
```
这个结构的目标是最小化 Makefile 中的冗余代码，保持所有核心之间的通用外观和感觉，并简化给定仿真器特定变量、规则和目标的维护。
<br><br>
基本用法是：`make SIMULATOR=<sim> <target>`，其中 `sim` 是 vsim、dsim、xrun、vcs 或 riviera，`target` 选择一个或多个活动（例如 'clean'、'test'、'gen_corev-dv'）
<br><br>
**提示**：定义 shell 环境变量"SIMULATOR"以匹配支持的仿真器特定 Makefile 之一（例如 vsim）可以节省大量打字。
<br><br>
运行测试的基本格式是 `make test SIMULATOR=<sim> TEST=<test-program>`，其中 `test-program` 是位于 <CV_CORE>/tests/programs/custom/<testprogram> 的 [测试程序](https://core-v-docs-verif-strat.readthedocs.io/en/latest/sim_tests.html#test-program)（C 或 RISC-V 汇编）的名称。

### 📊 在 DVT Eclipse IDE 中导入源代码 [dvt](https://www.dvteclipse.com/products/dvt-eclipse-ide)

除了仿真器特定的 Makefile 外，还有一个名为 `dvt.mk` 的 makefile。命令 `make SIMULATOR=<sim> open_in_dvt_ide` 将在 DVT Eclipse IDE 中导入 core-v-verif 测试平台和 RTL 源代码。
<br> <br>
**注意：** `CV_CORE/sim/uvmt/Makefile` 是用户可以调用 DVT 的'根' Makefile。
<br>

## 🚀 运行验证环境

### 使用 Metrics [dsim](https://metrics.ca) 运行环境

命令 **make SIMULATOR=dsim sanity** 将使用 _dsim_ 运行 sanity 测试用例。
<br><br>
将 shell 环境变量 `CV_SIMULATOR` 设置为"dsim"也会将 Makefile 变量 SIMULATOR 定义为 `dsim`，您可以节省大量打字。例如，在 bash shell 中：
<br>**export CV_SIMULATOR=dsim**
<br>**make sanity**
<br><br>
dsim 的 Makefile 还支持控制波形转储的变量。例如：
<br>**make sanity WAVES=1**
<br>查看 `dsim.mk` 以了解控制转储文件文件名等的其他变量。
<br><br>
Makefile 变量 DSIM_RUN_FLAGS 可用于向 dsim 在运行时传递用户定义的参数。例如：
<br>**make sanity DSIM\_RUN\_FLAGS=+print\_uvm\_runflow\_banner=1**

### 使用 Cadence [Xcelium](https://www.cadence.com/en_US/home/tools/system-design-and-verification/simulation-and-testbench-verification/xcelium-parallel-simulator.html) (xrun) 运行环境

命令 **make SIMULATOR=xrun sanity** 将使用 _xrun_ 运行 sanity 测试用例。将 shell 变量 SIMULATOR 设置为 `xrun` 即可简单运行 **`make <target>`**。
<br><br>
**Cadence 用户注意：** 已知此测试平台需要 Xcelium 19.09 或更高版本。有关更多信息，请参见 [Issue 11](https://github.com/openhwgroup/core-v-verif/issues/11)。
<br>

### 使用 Mentor Graphics [Questa](https://www.mentor.com/products/fv/questa/) (vsim) 运行环境

命令 **make SIMULATOR=vsim sanity** 将使用 _vsim_ 运行 sanity 测试用例。将 shell 变量 SIMULATOR 设置为 `vsim` 即可简单运行 **`make <target>`**。
<br> <br>
**Mentor 用户注意：** 已知此测试平台需要 Questa 2019.2 或更高版本。
<br>

### 使用 Synopsys VCS [VCS](https://www.synopsys.com/verification/simulation/vcs.html) (vcs) 运行环境

命令 **make SIMULATOR=vcs sanity** 将使用 _vsim_ 运行 sanity 测试用例。将 shell 变量 SIMULATOR 设置为 `vcs` 即可简单运行 **`make <target>`**。
<br><br>
**Synopsys 用户注意：** 此测试平台最近几周没有用 _vcs_ 编译/运行过。如果您需要更新 Makefile，请这样做并发出 Pull Request。

### 使用 Aldec [Riviera-PRO](https://www.aldec.com/en/products/functional_verification/riviera-pro) (riviera) 运行环境

命令 **make SIMULATOR=riviera sanity** 将使用 _riviera_ 运行 sanity 测试用例。将 shell 变量 SIMULATOR 设置为 `riviera` 即可简单运行 **`make <target>`**。

## 🧪 Sanity 测试

此处的 `make` 命令假设您已将 shell SIMULATION 环境变量设置为您的特定仿真器（见上文）。
<br><br>
在对本地分支中的代码进行更改之前，运行 sanity 测试以确保您从稳定的代码基础开始是个好主意。代码（RTL 和验证）应该_始终_通过 sanity，所以如果不通过，请提出 issue 并分配给 @mikeopenhwgroup。"sanity"的定义可能会随着验证环境对 RTL 的压力能力提高而改变。运行 sanity 很简单：
```
make sanity
```

## 🔄 CI 小型回归

OpenHW 使用 [Metrics CI 平台]() 进行回归。控制脚本是位于此仓库顶层的 `.metrics.json`。Python 脚本 `ci/ci_check` 可用于运行控制脚本中指定的"cv32 CI 检查回归"。在为 RTL 或验证代码发出 pull request 之前，请运行 `ci_check`。如果 `ci_check` 不能成功编译和运行，您的 pull request 将被拒绝。用法很简单：
```
./ci_check --core cv32e40p -s xrun
```
将使用 Xcelium 在 cv32e40p 上运行 CI sanity 回归。
<br><br>
完整的用户信息以通常的方式获得：
```
./ci_check -h
```

## 📋 可用的测试程序

此处的 `make` 命令假设您已将 shell SIMULATION 环境变量设置为您的特定仿真器（见上文）。
<br>
运行测试的一般形式是 `make test TEST=<test-program>`，其中 _test-program_ 是位于 <CV_CORE>/tests/programs/custom 的测试程序的文件名（不带文件扩展名）。每个测试程序（C 或汇编）都有自己的目录，其中包含程序本身（C 或汇编）加上 `test.yaml`，测试程序配置文件（见下面的构建配置）。
<br>
以下是一些例子
* **make test TEST=hello-world**：<br>运行在 `<CV_CORE>/tests/programs/custom` 中找到的 hello_world 程序。
* **make test TEST=dhrystone**：<br>运行在 `<CV_CORE>/tests/programs/custom` 中找到的 dhrystone 程序。
* **make test TEST=riscv_arithmetic_basic_test**：<br>运行在 `<CV_CORE>/tests/programs/custom` 中找到的 riscv_arithmetic_basic_test 程序。
<br>
还有一些目标执行其他操作而不是运行测试。最受欢迎的是：
```
**make clean_all**
```
它删除所有 SIMULATOR 生成的中间文件、波形和日志**以及**克隆的 RTL 代码。

### 🏃‍♂️ CoreMark

有一个可用 [CoreMark](https://www.eembc.org/coremark/) 基准测试的移植版本，可以用以下 make 命令运行。

* **make test TEST=coremark USE_ISS=NO**

这将运行基准测试并打印结果。
数字"Total ticks"和"Iterations"可用于使用以下方程计算 CoreMark/MHz 分数：`CoreMark/MHz = iterations / (totalticks / 1e6)`。

## 🎲 COREV-DV 生成的测试

CV32 UVM 环境使用 [Google riscv-dv](https://github.com/google/riscv-dv) 生成器来自动化测试程序的生成。生成器根据需要被 Makefile 克隆到 `$(CV_CORE)/vendor_lib/google`。特定的类被扩展以创建特定于此环境的 `corev-dv` 生成器。请注意，riscv-dv 没有被修改，只是被扩展，允许 core-v-verif 与 riscv-dv 的最新版本保持同步。
<br><br>
Riscv-dv 使用测试模板，如"riscv_arithmetic_basic_test"和"riscv_rand_jump_test"。Corev-dv 在 `<CV_CORE>/tests/programs/corev-dv` 有一套用于 corev-dv 生成的测试程序的模板。运行这些是一个两步过程。第一步是克隆 riscv-dv 并编译 corev-dv：
```
make corev-dv
```
请注意，`corev-dv` 目标只需要运行一次。下一步是生成、编译和运行测试。例如：
```
make gen_corev-dv test TEST=corev_rand_jump_stress_test
```

## ✅ RISC-V 合规性测试套件和回归

CV32 UVM 环境能够以与 ISS 参考模型的步进比较模式运行 [RISC-V 合规性](https://github.com/riscv/riscv-compliance) 测试套件，并可以选择性地转储和检查签名文件与参考签名。与 riscv-dv 一样，合规性测试套件根据需要被 Makefile 克隆到 `$(CV_CORE)/vendor_lib/riscv`。从合规性测试套件运行单个测试程序的目标形式如下：
```
make compliance RISCV_ISA=<ISA> COMPLIANCE_PROG=<test-program>
```
要转储并检查签名：
```
make compliance_check_sig RISCV_ISA=<ISA> COMPLIANCE_PROG=<test-program>
```
请注意，运行这些目标中的任何一个都会调用 `all_compliance` 目标，它克隆 riscv-compliance 并编译所有测试程序。以下是从套件运行特定测试程序的例子：
```
make compliance RISCV_ISA=rv32Zifencei COMPLIANCE_PROG=I-FENCE.I-01
```
**注意：** RISCV_ISA 和 COMPLIANCE_PROG 之间存在依赖关系。例如，因为 I-ADD-01 测试程序是 rv32i 测试套件的一部分，这有效：
```
make compliance RISCV_ISA=rv32i COMPLIANCE_PROG=I-ADD-01
```
但这无效：
```
make compliance RISCV_ISA=rv32imc COMPLIANCE_PROG=I-ADD-01
```
`compliance_check_sig` 目标可以以与上述相同的方式使用，以运行仿真并执行签名文件的后仿真检查以及作为合规性测试套件一部分提供的参考签名。
<br><br>
可以使用 `compliance_regression` 目标运行按扩展的合规性回归。例如：
```
make compliance_regression RISCV_ISA=rv32imc
```
将运行合规性测试套件中的所有压缩指令测试，diff 签名文件并产生摘要报告。请注意，rv32i 合规性套件中的四个测试程序被故意忽略。参见 [issue #412](https://github.com/openhwgroup/core-v-verif/issues/412)。
<br><br>
_cv_regress_ 实用程序也可用于运行在 [cv32_compliance](https://github.com/openhwgroup/core-v-verif/blob/master/cv32e40p/regress/cv32_compliance.yaml) YAML 回归规范中找到的合规性回归测试。这支持 Metrics JSON（--metrics）、shell 脚本（--sh）和 Cadence Vmanager VSIF（--vsif）输出格式。使用以下例子：
```
# Shell 脚本输出
% cv_regress --file=cv32e40p_compliance --sim=xrun --sh
% ./cv32e40p_compliance.sh
```

## ⚙️ 构建配置

`uvmt` 环境支持向测试平台添加编译标志以支持核心的专用配置。测试平台流程在任何时点都支持单个编译对象，因此建议任何测试平台选项都作为运行时选项支持（参见测试规范文档以设置运行时 plusargs）。但是，如果例如需要更改 DUT 的参数，则需要使用此流程。<br>

所有构建配置都在文件中：<br>

```
<CV_CORE>/tests/cfg/<cfg>.yaml
```

YAML 文件的内容支持以下标签：
| YAML 标签      | 必需 | 描述 |
|---------------|----------|---------------------|
| name          | 是      | 配置的名称                |
| description   | 是      | 构建配置意图的简要描述 |
| compile_flags | 否       | 传递给仿真器编译步骤的编译标志    |
| ovpsim        | 否       | OVPSim ISS 的 IC 文件标志   |

<br>
以下是构建配置的例子：<br>

```
name: no_pulp
description: 将所有 PULP 相关标志设置为 0
compile_flags: >
    +define+NO_PULP
    +define+HAHAHA
ovpsim: >
    --override root/cpu0/misa_Extensions=0x1104
    --showoverrides
```
为了便于使用不同配置的多个同时运行，仿真数据库和输出文件位于 <i>&lt;simulator</i>_results/<i>&lt;CFG></i>-子目录中，其中 CFG 是当前 yaml 配置的名称。如果未覆盖，则选择默认配置并相应地命名子目录。

## 🔧 通用 Makefile 标志

对于 <i>uvmt</i> 目录中的所有测试，以下标志和目标支持与仿真器的通用操作。对于本节中描述的所有标志和目标，假设用户将在 make 命令行上提供 SIMULATOR 设置或填充 CV_SIMULATOR 环境变量。

| SIMULATOR    | 支持 |
|--------------|-----------|
|dsim          | 是       |
|xrun          | 是       |
|vsim(questa)  | 是       |
|vcs           | 是       |
|Riviera-PRO   | 是       |

对于某些仿真器，有多个调试工具可用，启用高级调试功能，但通常需要供应商的相应许可证。默认情况下，本节中的所有调试相关命令都将支持仿真器的标准调试工具。但是，当可用时，提供对高级调试工具的支持。通过在每个 make 命令中设置 **ADV_DEBUG=YES** 标志来选择高级调试工具。

| SIMULATOR   | 标准调试工具 | 高级调试工具 |
|-------------|---------------------|---------------------|
| dsim        | gtkwave             | N/A                 |
| xrun        | SimVision           | Indago              |
| questa      | Questa Tk GUI       | Visualizer          |
| vcs         | DVE                 | Verdi               |
| Riviera-PRO | Riviera-PRO         | Riviera-PRO         |

### 🖥️ 交互式仿真

要在交互模式下运行仿真（以启用单步执行、断点、重新启动），在运行测试时使用 GUI=1 命令。

如果适用于仿真器，将在编译中启用行调试以启用单步执行。

**make test TEST=hello-world GUI=1**

### 🎛️ 向仿真器传递运行时参数

Makefile 支持用户可控变量 **USER_RUN_FLAGS**，可用于传递运行时参数。下面提供了两个典型用例：

#### 设置 UVM 退出计数

所有错误信号和处理都通过所有 OpenHW 测试平台的标准 UVM 报告服务器路由。默认情况下，UVM 配置为在中止测试之前允许最多 5 个错误信号。有一个运行时 plusarg 来配置这个，应该适用于所有测试。使用 USER_RUN_FLAGS make 变量与标准 UVM_MAX_QUIT_COUNT plusarg，如下所示。请注意，NO 是必需的，并表示您希望 UVM 使用您的 plusarg 而不是任何内部配置的退出计数值。

**make test TEST=hello-world USER_RUN_FLAGS=+UVM_MAX_QUIT_COUNT=10,NO**

#### UVM 详细程度控制

以下将详细程度级别增加到 DEBUG。

**make test TEST=hello-world USER_RUN_FLAGS=+UVM_VERBOSITY=UVM_DEBUG**

### 🌊 后处理波形调试

定义了标志和目标以支持在仿真期间生成波形并在特定于使用的相应仿真器的后处理调试工具中查看这些波形。<br>

要在仿真期间创建波形，设置 **WAVES=YES** 标志。<br>

波形转储将包括 <i>uvmt_tb32</i> 测试平台中的所有信号并递归遍历整个层次结构。

**make test TEST=hello-world WAVES=1**

如果适用于仿真器，可用于高级调试工具的波形转储。

**make hello-world WAVES=1 ADV_DEBUG=1**

要调用调试工具本身，使用 **make waves** 目标。请注意必须提供测试。此外，高级调试工具标志必须与波形生成期间使用的设置匹配。

使用标准调试工具调用 hello-world 测试的调试工具。

**make waves TEST=hello-world**

使用高级调试工具调用 hello-world 测试的调试工具。

**make waves TEST=hello-world ADV_DEBUG=1**

### 📊 覆盖率

makefile 支持在仿真期间生成覆盖率数据库并调用仿真器特定的覆盖率报告和浏览工具。

默认情况下，<i>xrun、questa 和 vcs</i> 在仿真期间不生成覆盖率信息。因此，向 makefile 添加了一个标志以在仿真期间启用覆盖率数据库的生成。覆盖率数据库将在生成的数据库中包括行、表达式、切换、功能和断言覆盖率。

要生成覆盖率数据库，设置 **COV=1**。

**make test TEST=hello-world COV=1**

要查看覆盖率结果，向 makefile 添加了新目标 **cov**。默认情况下，该目标将在与输出日志文件和覆盖率数据库相同的目录中生成覆盖率报告。<br>

用户可以通过在 **make cov** 命令行上设置 **GUI=1** 来调用特定于仿真器的 GUI 覆盖率浏览工具。

为 hello-world 测试生成覆盖率报告

**make cov TEST=hello-world**

调用 hello-world 测试的 GUI 覆盖率浏览器：

**make cov TEST=hello-world GUI=1**

**make cov** 目标的一个附加选项是_合并_覆盖率。要合并覆盖率，makefile 将查看<i>所选仿真器</i>和配置的**所有**现有测试结果目录，并在 <i>&lt;simulator>_results/&lt;cfg>/merged_cov</i> 中生成合并的覆盖率报告。相应的覆盖率报告或 GUI 调用将使用该目录作为覆盖率数据库。通过设置 <i>MERGE=1</i> 标志选择覆盖率合并。

为所有执行的具有覆盖率数据库的测试生成覆盖率报告。

**make cov MERGE=1**

调用所有执行的具有覆盖率数据库的测试的 GUI 覆盖率浏览器。

**make cov MERGE=1 GUI=1**

---

## 🔗 相关文档

- **[中文学习中心](../cv32e40p/docs/learning-center/README.md)** - 完整的中文学习指南
- **[5分钟快速开始](../cv32e40p/docs/learning-center/quick-start-5min.md)** - 快速上手
- **[常用命令参考](../cv32e40p/docs/learning-center/commands-reference.md)** - 命令速查表
- **[环境检查脚本](../cv32e40p/docs/learning-center/check-environment.sh)** - 自动环境检查

---

*📝 本文档是 mk/README.md 的中文翻译版本。如发现翻译问题或需要更新，请提交 issue 或 pull request。*