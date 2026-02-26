# 定义 TAPA 安装包的根目录
set(TAPA_INSTALL_PREFIX "/home/wangyj/.local/usr")

# 1. 包含路径：指向标准的 include 目录
set(TAPA_INCLUDE_DIR 
    "${TAPA_INSTALL_PREFIX}/include"
    "${TAPA_INSTALL_PREFIX}/include/frt"
    "${TAPA_INSTALL_PREFIX}/include/gflags"
    "${TAPA_INSTALL_PREFIX}/include/glog"
    "${TAPA_INSTALL_PREFIX}/include/tapa"
    # "${TAPA_INSTALL_PREFIX}/share/tapa/system-include"
) 

# 自动寻找 Vitis HLS 路径以支持 ap_int.h
file(GLOB VITIS_HLS_INCLUDE_DIR "/tools/Xilinx/Vitis_HLS/*/include")

# 2. 库文件定义：指向标准的 lib 目录
# 使用 .so 动态链接以避免 Boost.Context 静态初始化问题
set(TAPA_LIBRARY "${TAPA_INSTALL_PREFIX}/lib/libtapa.so")

set(CONTEXT_LIBRARY "${TAPA_INSTALL_PREFIX}/lib/libcontext.so") # 提供了 Boost 相关的符号
set(FRT_LIBRARY  "${TAPA_INSTALL_PREFIX}/lib/libfrt.so")
set(GFLAGS_LIBRARY "${TAPA_INSTALL_PREFIX}/lib/libgflags.so")
set(GLOG_LIBRARY "${TAPA_INSTALL_PREFIX}/lib/libglog.so")
set(CL_LIBRARY   "${TAPA_INSTALL_PREFIX}/lib/libOpenCL.so")
set(THREAD_LIBRARY "${TAPA_INSTALL_PREFIX}/lib/libthread.so") # 提供了 Boost 相关的符号
set(TINYXML_LIBRARY   "${TAPA_INSTALL_PREFIX}/lib/libtinyxml2.so")
set(YAML_LIBRARY   "${TAPA_INSTALL_PREFIX}/lib/libyaml-cpp.so")
# set(DPI_LEGACY_LIBRARY   "${TAPA_INSTALL_PREFIX}/lib/tapa_fast_cosim_dpi_legacy_rdi.so")
# set(DPI_XV_LIBRARY   "${TAPA_INSTALL_PREFIX}/lib/tapa_fast_cosim_dpi_xv.so")


# 3. 创建一个干净的库列表变量
set(TAPA_DEPENDENCY_LIBS
    "${FRT_LIBRARY}"
    "${GLOG_LIBRARY}"
    "${CL_LIBRARY}"
    "${YAML_LIBRARY}"
    "${TINYXML_LIBRARY}"
    "${GFLAGS_LIBRARY}"
    "${THREAD_LIBRARY}"
    "${CONTEXT_LIBRARY}"
)

# 4. 创建 tapa::tapa 目标
if(NOT TARGET tapa::tapa)
    add_library(tapa::tapa SHARED IMPORTED)
endif()

set_target_properties(tapa::tapa PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${TAPA_INCLUDE_DIR};${VITIS_HLS_INCLUDE_DIR}"
    IMPORTED_LOCATION "${TAPA_LIBRARY}"
    # 使用干净的列表变量进行链接
    INTERFACE_LINK_LIBRARIES "${TAPA_DEPENDENCY_LIBS}"
    # 添加 rpath 以便运行时找到共享库
    INTERFACE_LINK_OPTIONS "-Wl,-rpath,${TAPA_INSTALL_PREFIX}/lib"
)

# 4. TAPA 编译器宏定义
# 假设 tapa 可执行文件也在 usr/bin 目录下
set(TAPA_EXE "${TAPA_INSTALL_PREFIX}/bin/tapa")
macro(add_tapa_target TARGET_NAME)
    add_custom_target(${TARGET_NAME}
        COMMAND ${TAPA_EXE} ${ARGN}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endmacro()

set(TAPA_FOUND TRUE)
