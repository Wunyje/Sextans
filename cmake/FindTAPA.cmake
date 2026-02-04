# 定义 Bazel 产物根目录
set(BAZEL_BIN "/home/wangyj/Projects/tapa/bazel-bin")

# 1. 包含路径 (根据你提供的路径批量 include)
set(TAPA_INCLUDE_DIR 
    "/home/wangyj/Projects/tapa/tapa-lib"
    "/home/wangyj/Projects/tapa/tapa-lib/tapa/host"
    "/home/wangyj/Projects/tapa/fpga-runtime"
    "/home/wangyj/Projects/tapa/fpga-runtime/frt"
) 
# 自动寻找 Vitis HLS 路径以支持 ap_int.h
file(GLOB VITIS_HLS_INCLUDE_DIR "/tools/Xilinx/Vitis_HLS/*/include")

# 2. 库文件定义
set(TAPA_LIBRARY "${BAZEL_BIN}/tapa-lib/libtapa.so")
set(FRT_LIBRARY  "${BAZEL_BIN}/fpga-runtime/libfrt.so")
set(GLOG_LIBRARY "${BAZEL_BIN}/external/glog~/libglog.a")

# 3. 创建 tapa::tapa 目标
if(NOT TARGET tapa::tapa)
    add_library(tapa::tapa SHARED IMPORTED)
endif()

set_target_properties(tapa::tapa PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TAPA_INCLUDE_DIR};${VITIS_HLS_INCLUDE_DIR}"
    IMPORTED_LOCATION "${TAPA_LIBRARY}"
    # 链接核心依赖：FRT + GLOG + 系统基础库
    # 注意：Boost 符号通常由 libtapa.so 提供，但需要依赖 pthread 和 rt
    INTERFACE_LINK_LIBRARIES "${FRT_LIBRARY};${GLOG_LIBRARY};gflags;pthread;dl;rt"
)

# 4. TAPA 编译器宏定义
set(TAPA_EXE "${BAZEL_BIN}/tapa/tapa")
macro(add_tapa_target TARGET_NAME)
    add_custom_target(${TARGET_NAME}
        COMMAND ${TAPA_EXE} ${ARGN}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endmacro()

set(TAPA_FOUND TRUE)
