# ============================================================================
# CMake 配置文件 - STM32F429 Modbus RTU 采集网关
# ============================================================================

cmake_minimum_required(VERSION 3.28.1)
project(template)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
enable_language(ASM)

add_compile_definitions(STM32F429_439xx)
add_compile_definitions(USE_STDPERIPH_DRIVER)
add_compile_definitions(MODBUS_TRACE_ENABLE=1)

set(MCU cortex-m4)
set(FPU_FLAGS "-mfpu=fpv4-sp-d16 -mfloat-abi=hard")

set(MCU_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../mcu)
set(BSP_DIR ${MCU_DIR}/bsp)
set(USER_DIR ${MCU_DIR}/user)
set(LIB_DIR ${MCU_DIR}/Libraries)
set(LD_DIR ${LIB_DIR}/ld)
set(LIBX_DIR ${MCU_DIR}/libx)
set(APP_DIR ${MCU_DIR}/app)
set(CRM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../crm)
set(FREERTOS_DIR ${CRM_DIR}/freeRTOS)
set(LWIP_DIR ${MCU_DIR}/middleware/LwIP)
set(MODBUS_DIR ${MCU_DIR}/middleware/Modbus-RTU)

set(FRTOS_INC_DIR ${FREERTOS_DIR}/include)
set(FRTOS_PORT_DIR ${FREERTOS_DIR}/portable)
set(FRTOS_SRC_DIR ${FREERTOS_DIR}/src)
set(MEMMANG_DIR ${FRTOS_PORT_DIR}/MemMang)
set(ARM_CM4F_DIR ${FRTOS_PORT_DIR}/GCC/ARM_CM4F)

set(LWIP_INC_DIR ${LWIP_DIR}/src/include)
set(LWIP_PORT_DIR ${LWIP_DIR}/port)

set(CMAKE_C_FLAGS "-mcpu=${MCU} -mthumb ${FPU_FLAGS} -O2 -ffunction-sections -fdata-sections -w -g")
set(CMAKE_ASM_FLAGS "-mcpu=${MCU} -mthumb ${FPU_FLAGS} -w")

set(LINKER_SCRIPT "${LD_DIR}/STM32F429IGTX_FLASH.ld")
set(CMAKE_EXE_LINKER_FLAGS "-T\"${LINKER_SCRIPT}\" -Wl,--gc-sections -static")
set(STARTUP_FILE ${LIB_DIR}/CMSIS/startup_stm32f429_439xx.s)

file(GLOB_RECURSE BSP_INCLUDE_DIRS LIST_DIRECTORIES true ${BSP_DIR}/*/Inc ${BSP_DIR}/*/*/Inc)
file(GLOB_RECURSE APP_INCLUDE_DIRS LIST_DIRECTORIES true ${APP_DIR}/*/Inc ${APP_DIR}/*/*/Inc)
file(GLOB_RECURSE MCU_MODULE_INCLUDE_DIRS LIST_DIRECTORIES true ${MCU_DIR}/middleware/*/Inc)

file(GLOB LIB_CMSIS_SOURCES ${LIB_DIR}/CMSIS/*.c)
file(GLOB LIB_STDPERIPH_SOURCES ${LIB_DIR}/STM32F4xx_StdPeriph_Driver/*.c)
file(GLOB FREERTOS_PORT_SOURCES ${ARM_CM4F_DIR}/*.c)
file(GLOB FREERTOS_MEM_SOURCES ${MEMMANG_DIR}/*.c)
file(GLOB FREERTOS_CORE_SOURCES ${FRTOS_SRC_DIR}/*.c)
file(GLOB LWIP_PORT_SOURCES ${LWIP_PORT_DIR}/*.c)
file(GLOB LWIP_API_SOURCES ${LWIP_DIR}/src/api/*.c)
file(GLOB LWIP_CORE_SOURCES ${LWIP_DIR}/src/core/*.c)
file(GLOB LWIP_NETIF_SOURCES ${LWIP_DIR}/src/netif/*.c)
file(GLOB_RECURSE BSP_SOURCES ${BSP_DIR}/*.c)
file(GLOB LIBX_SOURCES ${LIBX_DIR}/*.c)
file(GLOB_RECURSE APP_SOURCES ${APP_DIR}/*.c)
file(GLOB USER_SOURCES ${USER_DIR}/*.c)
file(GLOB MODBUS_SOURCES ${MODBUS_DIR}/Src/*.c)

set(SRC_FILES
    ${LIB_CMSIS_SOURCES}
    ${LIB_STDPERIPH_SOURCES}
    ${FREERTOS_PORT_SOURCES}
    ${FREERTOS_MEM_SOURCES}
    ${FREERTOS_CORE_SOURCES}
    ${LWIP_PORT_SOURCES}
    ${LWIP_API_SOURCES}
    ${LWIP_CORE_SOURCES}
    ${LWIP_NETIF_SOURCES}
    ${BSP_SOURCES}
    ${LIBX_SOURCES}
    ${APP_SOURCES}
    ${USER_SOURCES}
    ${MODBUS_SOURCES}
)

list(REMOVE_ITEM SRC_FILES
    ${LIB_DIR}/STM32F4xx_StdPeriph_Driver/stm32f4xx_fsmc.c
)
list(FILTER SRC_FILES EXCLUDE REGEX ".*/middleware/LwIP/src/netif/ethernetif\\.c$")

include_directories(
    ${LIB_DIR}/CMSIS
    ${LIB_DIR}/STM32F4xx_StdPeriph_Driver
    ${LWIP_INC_DIR}
    ${LWIP_PORT_DIR}
    ${FRTOS_INC_DIR}
    ${ARM_CM4F_DIR}
    ${USER_DIR}
    ${BSP_INCLUDE_DIRS}
    ${LIBX_DIR}
    ${APP_INCLUDE_DIRS}
    ${MCU_MODULE_INCLUDE_DIRS}
    ${MODBUS_DIR}/Inc
)

add_executable(${PROJECT_NAME}.elf ${SRC_FILES} ${STARTUP_FILE})

target_link_options(${PROJECT_NAME}.elf PRIVATE
    -Wl,-Map=${CMAKE_BINARY_DIR}/${PROJECT_NAME}.map
    -Wl,--cref
)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex ${PROJECT_NAME}.elf ${PROJECT_NAME}.hex
    COMMAND ${CMAKE_OBJCOPY} -O binary ${PROJECT_NAME}.elf ${PROJECT_NAME}.bin
    COMMENT "Generating HEX and BIN firmware images..."
)
