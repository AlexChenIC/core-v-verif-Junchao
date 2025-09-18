/*
**
** Copyright 2020 OpenHW Group
**
** Licensed under the Solderpad Hardware Licence, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     https://solderpad.org/licenses/
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
**
*******************************************************************************
**
** CV32E40P 处理器核心完整性测试程序
**
** 🎯 程序功能：读取并验证关键 CSR 寄存器，确保处理器核心正常工作
**
** 📋 验证的 CSR 寄存器：
**     • MVENDORID (0xF11) - 厂商标识寄存器：验证是否为 OpenHW Group (0x602)
**     • MISA (0x301) - 指令集架构寄存器：验证支持的指令扩展
**     • MARCHID (0xF12) - 架构标识寄存器：验证是否为 CV32E40P (0x4)
**     • MIMPID (0xF13) - 实现标识寄存器：验证实现版本 (0x0)
**
** 🔍 验证逻辑：如果任何 CSR 寄存器的值与期望值不符，程序将：
**     • 输出详细的错误信息到标准输出
**     • 返回 EXIT_FAILURE (非零退出码)
**     • 触发仿真环境的测试失败检测机制
**
*******************************************************************************
*/

// 📚 标准C库头文件包含
#include <stdio.h>      // 标准输入输出函数 (printf 等)
#include <stdlib.h>     // 标准库函数 (EXIT_SUCCESS, EXIT_FAILURE 等)

// 🎯 MISA 寄存器期望值定义
// MISA (Machine ISA) 寄存器描述了处理器支持的指令集架构和扩展
//
// 📋 FIXME 说明：当前测试平台无法在编译时动态选择 PULP/NO_PULP 配置
//       因此我们设置默认的 MISA 值为 NO_PULP 配置
//       这个问题需要修复，但目前不影响 UVM 验证环境的运行
#define EXP_MISA 0x40001104  // 默认配置：RV32IMC (无 PULP 扩展)

#ifdef NO_PULP
// 🚫 NO_PULP 配置：标准的 RV32IMC 指令集
// 0x40001104 解析：
//   [31:30] MXL = 01 (32位架构)
//   [25:0]  Extensions = 0x001104
//           I(8)=1, M(12)=1, C(2)=1 (基础整数 + 乘法除法 + 压缩指令)
#define EXP_MISA 0x40001104
#endif

#ifdef PULP
// ⚡ PULP 配置：包含 PULP 扩展的 RV32IMC 指令集
// 0x40801104 解析：
//   [31:30] MXL = 01 (32位架构)
//   [25:0]  Extensions = 0x801104
//           增加了 PULP 特定的指令扩展 (X扩展位置)
#define EXP_MISA 0x40801104
#endif


// 🚀 主函数：CV32E40P 处理器核心验证程序入口点
// 📝 参数：argc - 命令行参数个数，argv - 命令行参数数组 (此程序中未使用)
// 🔄 返回值：EXIT_SUCCESS (0) 表示测试通过，EXIT_FAILURE (1) 表示测试失败
int main(int argc, char *argv[])
{
    // 📊 CSR 寄存器读取值存储变量
    unsigned int misa_rval,      // MISA 寄存器读取值 (指令集架构信息)
                 mvendorid_rval, // MVENDORID 寄存器读取值 (厂商标识)
                 marchid_rval,   // MARCHID 寄存器读取值 (架构标识)
                 mimpid_rval,    // MIMPID 寄存器读取值 (实现标识)
                 mxl;            // MXL 字段值 (机器字长度，从MISA中提取)

    // 🔍 MISA 寄存器扩展支持标志位统计变量
    int reserved,   // 保留位计数器 (不应该被设置的位)
        tentative,  // 试验性扩展计数器 (尚未标准化的扩展)
        nonstd,     // 非标准扩展计数器 (厂商自定义扩展)
        user,       // 用户模式支持标志
        super;      // 监管者模式支持标志

    // 🔧 初始化所有统计变量为零
    // 这些变量将用于分析 MISA 寄存器中的各个扩展位
    mxl = 0; reserved = 0; tentative = 0; nonstd = 0; user = 0; super = 0;

    // ⚡ 内联汇编：直接读取 RISC-V CSR (控制状态寄存器)
    // 💡 使用 csrr (CSR Read) 指令直接访问处理器的控制状态寄存器

    // 📋 读取 MVENDORID CSR (0xF11) - 厂商标识寄存器
    // 🎯 期望值：0x602 (OpenHW Group 的 JEDEC 厂商标识)
    // 🔍 csrr 指令：csrr rd, csr_addr (将CSR的值读到通用寄存器)
    __asm__ volatile("csrr %0, 0xF11" : "=r"(mvendorid_rval));

    // 📋 读取 MISA CSR (0x301) - 机器指令集架构寄存器
    // 🎯 描述：包含处理器支持的指令集和扩展信息
    // 📊 位域：[31:30]MXL机器字长，[25:0]各种指令扩展支持位
    __asm__ volatile("csrr %0, 0x301" : "=r"(misa_rval));

    // 📋 读取 MARCHID CSR (0xF12) - 架构标识寄存器
    // 🎯 期望值：0x4 (RISC-V Foundation 分配给 CV32E40P 的架构ID)
    __asm__ volatile("csrr %0, 0xF12" : "=r"(marchid_rval));

    // 📋 读取 MIMPID CSR (0xF13) - 实现标识寄存器
    // 🎯 期望值：0x0 (OpenHW Group 为 CV32E40P 首版分配的实现ID)
    __asm__ volatile("csrr %0, 0xF13" : "=r"(mimpid_rval));

    // 🔍 第一项验证：MVENDORID CSR 厂商标识寄存器
    // 📋 标准要求：0x602 是 JEDEC 分配给 OpenHW Group 的厂商标识符
    // ❌ 失败条件：如果读取值不等于期望值，说明处理器厂商标识错误
    if (mvendorid_rval != 0x00000602) {
      printf("\tERROR: CSR MVENDORID reads as 0x%x - should be 0x00000602 for the OpenHW Group.\n\n", mvendorid_rval);
      return EXIT_FAILURE;  // 🚨 测试失败，返回错误码
    }

    // 🔍 第二项验证：MISA CSR 指令集架构寄存器
    // 📋 重要性：如果此寄存器为零，可能表示根本没有实现该CSR
    // 🎯 验证点：确保处理器支持正确的指令集配置 (RV32IMC 或 RV32IMC+PULP)
    if (misa_rval != EXP_MISA) {
      printf("\tERROR: CSR MISA reads as 0x%x - should be 0x%x for this release of CV32E40P!\n\n", misa_rval, EXP_MISA);
      return EXIT_FAILURE;  // 🚨 测试失败，指令集配置不正确
    }

    // 🔍 第三项验证：MARCHID CSR 架构标识寄存器
    // 📋 标准要求：0x4 是 RISC-V Foundation 分配给 CV32E40P 的架构ID
    // 🎯 验证点：确认这确实是一个 CV32E40P 处理器核心
    if (marchid_rval != 0x00000004) {
      printf("\tERROR: CSR MARCHID reads as 0x%x - should be 0x00000004 for CV32E40P.\n\n", marchid_rval);
      return EXIT_FAILURE;  // 🚨 测试失败，架构标识不匹配
    }

    // 🔍 第四项验证：MIMPID CSR 实现标识寄存器
    // 📋 版本管理：0x0 是 OpenHW Group 为 CV32E40P 首次发布版本分配的实现ID
    // 🎯 验证点：确认处理器实现版本符合预期
    if (mimpid_rval != 0x00000000) {
      printf("\tERROR: CSR MIMPID reads as 0x%x - should be 0x00000000 for this release of CV32E40P.\n\n", mimpid_rval);
      return EXIT_FAILURE;  // 🚨 测试失败，实现版本不正确
    }

    /* Print a banner to stdout and interpret MISA CSR */
    printf("\nHELLO WORLD!!!\n");
    printf("This is the OpenHW Group CV32E40P CORE-V processor core.\n");
    printf("CV32E40P is a RISC-V ISA compliant core with the following attributes:\n");
    printf("\tmvendorid = 0x%x\n", mvendorid_rval);
    printf("\tmarchid   = 0x%x\n", marchid_rval);
    printf("\tmimpid    = 0x%x\n", mimpid_rval);
    printf("\tmisa      = 0x%x\n", misa_rval);
    mxl = ((misa_rval & 0xC0000000) >> 30); // MXL == MISA[31:30]
    switch (mxl) {
      case 0:  printf("\tERROR: MXL cannot be zero!\n");
               return EXIT_FAILURE;
               break;
      case 1:  printf("\tXLEN is 32-bits\n");
               break;
      case 2:  printf("\tXLEN is 64-bits\n");
               break;
      case 3:  printf("\tXLEN is 128-bits\n");
               break;
      default: printf("\tERROR: mxl (%0d) not in 0..3, your code is broken!\n", mxl);
               return EXIT_FAILURE;
    }

    printf("\tSupported Instructions Extensions: ");
    if ((misa_rval >> 25) & 0x00000001) ++reserved;
    if ((misa_rval >> 24) & 0x00000001) ++reserved;
    if ((misa_rval >> 23) & 0x00000001) {
      printf("X");
      ++nonstd;
    }
    if ((misa_rval >> 22) & 0x00000001) ++reserved;
    if ((misa_rval >> 21) & 0x00000001) ++tentative;
    if ((misa_rval >> 20) & 0x00000001) ++user;
    if ((misa_rval >> 19) & 0x00000001) ++tentative;
    if ((misa_rval >> 18) & 0x00000001) ++super;
    if ((misa_rval >> 17) & 0x00000001) ++reserved;
    if ((misa_rval >> 16) & 0x00000001) printf("Q");
    if ((misa_rval >> 15) & 0x00000001) ++tentative;
    if ((misa_rval >> 14) & 0x00000001) ++reserved;
    if ((misa_rval >> 13) & 0x00000001) printf("N");
    if ((misa_rval >> 12) & 0x00000001) printf("M");
    if ((misa_rval >> 11) & 0x00000001) ++tentative;
    if ((misa_rval >> 10) & 0x00000001) ++reserved;
    if ((misa_rval >>  9) & 0x00000001) printf("J");
    if ((misa_rval >>  8) & 0x00000001) printf("I");
    if ((misa_rval >>  7) & 0x00000001) printf("H");
    if ((misa_rval >>  6) & 0x00000001) printf("G");
    if ((misa_rval >>  5) & 0x00000001) printf("F");
    if ((misa_rval >>  4) & 0x00000001) printf("E");
    if ((misa_rval >>  3) & 0x00000001) printf("D");
    if ((misa_rval >>  2) & 0x00000001) printf("C");
    if ((misa_rval >>  1) & 0x00000001) printf("B");
    if ((misa_rval      ) & 0x00000001) printf("A");
    printf("\n");
    if (super) {
      printf("\tThis machine supports SUPERVISOR mode.\n");
    }
    if (user) {
      printf("\tThis machine supports USER mode.\n");
    }
    if (nonstd) {
      printf("\tThis machine supports non-standard instructions.\n");
    }
    if (tentative) {
      printf("\tWARNING: %0d tentative instruction extensions are defined!\n", tentative);
    }
    if (reserved) {
      printf("\tERROR: %0d reserved instruction extensions are defined!\n\n", reserved);
      return EXIT_FAILURE;
    }
    else {
      printf("\n");
      return EXIT_SUCCESS;
    }
}
