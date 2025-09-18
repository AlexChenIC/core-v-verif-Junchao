#!/bin/bash

# 🔍 CV32E40P 验证环境检查脚本
# ============================================================================
# 这个脚本会自动检查 CV32E40P 验证环境的所有必要组件
# 使用方法：bash check-environment.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 检查结果统计
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# 打印函数
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_section() {
    echo ""
    echo -e "${YELLOW}📋 $1${NC}"
    echo "----------------------------------------"
}

print_pass() {
    echo -e "✅ ${GREEN}PASS${NC}: $1"
    ((PASS_COUNT++))
}

print_fail() {
    echo -e "❌ ${RED}FAIL${NC}: $1"
    ((FAIL_COUNT++))
}

print_warn() {
    echo -e "⚠️  ${YELLOW}WARN${NC}: $1"
    ((WARN_COUNT++))
}

print_info() {
    echo -e "ℹ️  INFO: $1"
}

# 检查命令是否存在
check_command() {
    local cmd=$1
    local desc=$2
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$($cmd --version 2>/dev/null | head -1 || echo "版本信息不可用")
        print_pass "$desc 已安装: $cmd"
        print_info "   版本: $version"
        return 0
    else
        print_fail "$desc 未找到: $cmd"
        return 1
    fi
}

# 检查环境变量
check_env_var() {
    local var=$1
    local desc=$2
    local optional=${3:-false}

    if [ -n "${!var}" ]; then
        print_pass "$desc 已设置: $var=${!var}"
        # 检查路径是否存在
        if [[ "${!var}" == /* ]] && [ ! -d "${!var}" ] && [ ! -f "${!var}" ]; then
            print_warn "   路径不存在: ${!var}"
        fi
        return 0
    else
        if [ "$optional" = "true" ]; then
            print_warn "$desc 未设置（可选）: $var"
            return 0
        else
            print_fail "$desc 未设置: $var"
            return 1
        fi
    fi
}

# 检查目录或文件
check_path() {
    local path=$1
    local desc=$2
    local type=${3:-"dir"}  # dir 或 file

    if [ "$type" = "dir" ]; then
        if [ -d "$path" ]; then
            print_pass "$desc 目录存在: $path"
            return 0
        else
            print_fail "$desc 目录不存在: $path"
            return 1
        fi
    else
        if [ -f "$path" ]; then
            print_pass "$desc 文件存在: $path"
            return 0
        else
            print_fail "$desc 文件不存在: $path"
            return 1
        fi
    fi
}

# 主检查函数
main_check() {
    print_header "🔍 CV32E40P 验证环境检查"
    echo "开始时间: $(date)"
    echo "用户: $(whoami)"
    echo "主机: $(hostname)"
    echo "工作目录: $(pwd)"

    # 1. 基础工具检查
    print_section "基础工具检查"
    check_command "make" "Make 构建工具"
    check_command "git" "Git 版本控制"
    check_command "python3" "Python 3"
    check_command "bash" "Bash Shell"

    # 2. RISC-V 工具链检查
    print_section "RISC-V 工具链检查"
    check_env_var "RISCV" "RISC-V 工具链路径"

    local riscv_gcc="riscv32-unknown-elf-gcc"
    if check_command "$riscv_gcc" "RISC-V GCC 编译器"; then
        # 测试编译
        local test_code='int main(){return 0;}'
        local temp_c=$(mktemp --suffix=.c)
        local temp_elf=$(mktemp --suffix=.elf)
        echo "$test_code" > "$temp_c"

        if "$riscv_gcc" -o "$temp_elf" "$temp_c" 2>/dev/null; then
            print_pass "RISC-V 编译测试成功"
        else
            print_fail "RISC-V 编译测试失败"
        fi

        rm -f "$temp_c" "$temp_elf"
    fi

    check_command "riscv32-unknown-elf-objdump" "RISC-V Objdump"
    check_command "riscv32-unknown-elf-objcopy" "RISC-V Objcopy"

    # 3. 仿真器检查
    print_section "仿真器检查"
    local simulator_found=false

    if check_command "dsim" "Metrics DSim"; then
        simulator_found=true
    fi

    if check_command "xrun" "Cadence Xcelium"; then
        simulator_found=true
    fi

    if check_command "vsim" "Synopsys VCS"; then
        simulator_found=true
    fi

    if check_command "riviera" "Aldec Riviera"; then
        simulator_found=true
    fi

    if [ "$simulator_found" = false ]; then
        print_fail "未找到任何支持的仿真器 (dsim/xrun/vsim/riviera)"
    fi

    # 4. 环境变量检查
    print_section "环境变量检查"
    check_env_var "CORE_V_VERIF" "Core-V 验证根目录"
    check_env_var "CV_CORE" "CV 核心类型" true
    check_env_var "CV_SIMULATOR" "仿真器选择" true
    check_env_var "PATH" "系统路径"

    # 5. 项目结构检查
    print_section "项目结构检查"

    # 检查当前是否在正确目录
    if [ -d "cv32e40p" ]; then
        print_pass "检测到 CV32E40P 项目结构"
    elif [ -d "../cv32e40p" ]; then
        print_warn "CV32E40P 目录在上级目录，建议 cd .."
    else
        print_fail "未找到 CV32E40P 项目结构"
    fi

    # 检查关键目录
    local base_dir="."
    if [ -d "cv32e40p" ]; then
        base_dir="cv32e40p"
    elif [ -d "../cv32e40p" ]; then
        base_dir="../cv32e40p"
    fi

    if [ "$base_dir" != "." ]; then
        check_path "$base_dir/sim/uvmt" "仿真目录"
        check_path "$base_dir/tests" "测试目录"
        check_path "$base_dir/tb" "测试平台目录"
        check_path "$base_dir/env" "环境目录"
        check_path "$base_dir/sim/uvmt/Makefile" "主 Makefile" "file"
    fi

    # 6. 外部依赖检查
    print_section "外部依赖检查"

    local vendor_dirs=(
        "vendor_lib/google/riscv-dv"
        "vendor_lib/riscv/riscv-compliance"
        "vendor_lib/embench"
        "vendor_lib/verilab/svlib"
        "vendor_lib/imperas"
    )

    for vendor_dir in "${vendor_dirs[@]}"; do
        local full_path="$base_dir/$vendor_dir"
        if [ -d "$full_path" ]; then
            print_pass "外部依赖已克隆: $vendor_dir"
        else
            print_warn "外部依赖未克隆: $vendor_dir (运行 make clone_all)"
        fi
    done

    # 7. 权限检查
    print_section "权限检查"

    if [ -w "/tmp" ]; then
        print_pass "临时目录 /tmp 可写"
    else
        print_fail "临时目录 /tmp 不可写"
    fi

    if [ -w "." ]; then
        print_pass "当前目录可写"
    else
        print_fail "当前目录不可写"
    fi

    # 8. 内存和磁盘检查
    print_section "系统资源检查"

    local free_mem=$(free -m 2>/dev/null | awk '/^Mem:/{print $7}' || echo "unknown")
    if [ "$free_mem" != "unknown" ] && [ "$free_mem" -gt 2048 ]; then
        print_pass "可用内存充足: ${free_mem}MB"
    elif [ "$free_mem" != "unknown" ]; then
        print_warn "可用内存较少: ${free_mem}MB (建议 >2GB)"
    else
        print_info "无法检测内存信息"
    fi

    local free_disk=$(df -m . 2>/dev/null | awk 'NR==2{print $4}' || echo "unknown")
    if [ "$free_disk" != "unknown" ] && [ "$free_disk" -gt 5000 ]; then
        print_pass "可用磁盘空间充足: ${free_disk}MB"
    elif [ "$free_disk" != "unknown" ]; then
        print_warn "可用磁盘空间较少: ${free_disk}MB (建议 >5GB)"
    else
        print_info "无法检测磁盘空间"
    fi

    # 9. 快速测试（如果条件允许）
    print_section "快速功能测试"

    if [ -f "$base_dir/sim/uvmt/Makefile" ] && [ "$PASS_COUNT" -gt 10 ]; then
        print_info "尝试运行 make help 命令..."
        if (cd "$base_dir/sim/uvmt" && make help >/dev/null 2>&1); then
            print_pass "Makefile 系统运行正常"
        else
            print_warn "Makefile 系统可能有问题"
        fi
    else
        print_info "跳过功能测试（缺少基础条件）"
    fi
}

# 生成修复建议
generate_recommendations() {
    print_header "🔧 修复建议"

    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "${RED}发现 $FAIL_COUNT 个严重问题，需要修复：${NC}"
        echo ""
        echo "1. 安装缺失的工具："
        echo "   - RISC-V 工具链: https://github.com/riscv/riscv-gnu-toolchain"
        echo "   - 仿真器: 请联系相应厂商或使用开源替代"
        echo ""
        echo "2. 设置环境变量："
        echo "   export RISCV=/path/to/riscv-toolchain"
        echo "   export PATH=\$RISCV/bin:\$PATH"
        echo "   export CV_SIMULATOR=dsim  # 或其他可用仿真器"
        echo ""
        echo "3. 克隆外部依赖："
        echo "   cd cv32e40p/sim/uvmt/"
        echo "   make clone_all"
        echo ""
    fi

    if [ $WARN_COUNT -gt 0 ]; then
        echo -e "${YELLOW}发现 $WARN_COUNT 个警告，建议处理：${NC}"
        echo "   - 检查路径设置是否正确"
        echo "   - 考虑升级系统资源"
        echo "   - 克隆缺失的外部依赖"
        echo ""
    fi

    if [ $FAIL_COUNT -eq 0 ] && [ $WARN_COUNT -eq 0 ]; then
        echo -e "${GREEN}🎉 环境配置完美！可以开始验证工作了。${NC}"
        echo ""
        echo "建议的下一步："
        echo "   cd cv32e40p/sim/uvmt/"
        echo "   make test TEST=hello-world"
        echo ""
    fi
}

# 主程序入口
main() {
    clear
    main_check
    echo ""
    print_header "📊 检查汇总"
    echo -e "✅ 通过: ${GREEN}$PASS_COUNT${NC}"
    echo -e "❌ 失败: ${RED}$FAIL_COUNT${NC}"
    echo -e "⚠️  警告: ${YELLOW}$WARN_COUNT${NC}"
    echo ""

    generate_recommendations

    echo "检查完成时间: $(date)"
    echo "详细信息请参考上述输出。"

    # 返回状态码
    if [ $FAIL_COUNT -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# 运行主程序
main "$@"