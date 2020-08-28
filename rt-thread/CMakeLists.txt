cmake_minimum_required(VERSION 3.10)
SET(CMAKE_BUILD_TYPE "Debug")

set(TARGETS rt-thread-nano)

#交叉编译环境
set(CMAKE_SYSTEM_NAME Generic)

set(CMAKE_C_COMPILER /opt/rv32ima/bin/riscv32-unknown-elf-gcc )
set(CMAKE_CPP_COMPILER /opt/rv32ima/bin/riscv32-unknown-elf-g++ )

set(CMAKE_FIND_ROOT_PATH /opt/rv32ima)

set(OBJCOPY /opt/rv32ima/bin/riscv32-unknown-elf-objcopy)
set(OBJDUMP /opt/rv32ima/bin/riscv32-unknown-elf-objdump)

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(MABI  ilp32) 
set(MARCH rv32i)
set(MODE    QEMU)

set(LINKER_SCRIPT ./../src/linker.ld)
#set(CMAKE_OUTPUT_DIRECTORY ./build)


#设置编译flag
set(CMAKE_C_FLAGS "-march=${MARCH}  -mabi=${MABI} -MD -fstrict-volatile-bitfields -fno-strict-aliasing -D${MODE}")

set(LD_FLAGS "-march=${MARCH}  -mabi=${MABI} -nostdlib -lgcc -mcmodel=medany -nostartfiles -ffreestanding -Wl,-Bstatic,--print-memory-usage,-Map,${TARGETS}.map")
set(CMAKE_EXE_LINKER_FLAGS ${LD_FLAGS})
set(CMAKE_MODULE_LINKER_FLAGS ${LD_FLAGS})
set(CMAKE_SHARED_LINKER_FLAGS ${LD_FLAGS})
set(CMAKE_STATIC_LINKER_FLAGS ${LD_FLAGS})
link_libraries(${LD_FLAGS})


#项目
project(${TARGETS} C)

enable_language( ASM )



#src文件
file(GLOB_RECURSE RT_SOURCE_FILES  "./rtthread_nano/*.c" "./rtthread_nano/*.S" )
file(GLOB_RECURSE APP_SOURCE_FILES "./src/*.c" "./src/*.cpp" "src/*.S"  )
add_executable(${TARGETS}.elf   ${APP_SOURCE_FILES} ${RT_SOURCE_FILES})


#include路径
include_directories( ./rtthread_nano/libcpu/risc-v/bumblebee ./rtthread_nano/libcpu/risc-v/common )
include_directories( ./rtthread_nano/include ./rtthread_nano/include/libc ./rtthread_nano/ ./rtthread_nano/libcpu/risc-v/common)
include_directories( ./src )

target_link_libraries(${TARGETS}.elf PRIVATE -T${LINKER_SCRIPT} )

#set_target_properties(${TARGETS} PROPERTIES LINK_DEPENDS ${LINKER_SCRIPT})

#生成hex/bin

add_custom_command(TARGET ${TARGETS}.elf  POST_BUILD    
        COMMAND  ${OBJCOPY} -O ihex ${TARGETS}.elf ${TARGETS}.hex)
add_custom_command(TARGET ${TARGETS}.elf  POST_BUILD    
        COMMAND  ${OBJCOPY} -O binary ${TARGETS}.elf ${TARGETS}.bin)
add_custom_command(TARGET ${TARGETS}.elf  POST_BUILD    
        COMMAND  ${OBJCOPY} -O verilog ${TARGETS}.elf ${TARGETS}.v)

#导出asm
add_custom_command(TARGET ${TARGETS}.elf  POST_BUILD    
	COMMAND  ${OBJDUMP} -S -d ${TARGETS}.elf > ${TARGETS}.asm)
