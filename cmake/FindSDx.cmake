# FindSDx.cmake
# Locate Vitis / Vitis HLS and define helper macros

set(VITIS_HINTS
  $ENV{XILINX_VITIS}
  /tools/Xilinx/Vitis/2023.2
  /opt/Xilinx/Vitis/2023.2
)

set(VITIS_HLS_HINTS
  $ENV{XILINX_VITIS_HLS}
  /tools/Xilinx/Vitis_HLS/2023.2
  /opt/Xilinx/Vitis_HLS/2023.2
)

# --- Vitis HLS headers ---
find_path(VITIS_HLS_INCLUDE_DIR
  NAMES ap_int.h hls_stream.h
  HINTS ${VITIS_HLS_HINTS}
  PATH_SUFFIXES include
)

# --- Vitis toolchain ---
find_program(VPP_EXECUTABLE
  NAMES v++
  HINTS ${VITIS_HINTS}
  PATH_SUFFIXES bin
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SDx
  REQUIRED_VARS VITIS_HLS_INCLUDE_DIR VPP_EXECUTABLE
)

if(SDx_FOUND)
  message(STATUS "Found Vitis HLS: ${VITIS_HLS_INCLUDE_DIR}")
  message(STATUS "Found Vitis toolchain: ${VPP_EXECUTABLE}")
endif()

# -------------------------------------------------------------------
# Define add_xocc_hw_link_targets
# 用法：
#   add_xocc_hw_link_targets(
#     <base_name>
#     <xo_file>
#     HW_EMU_XCLBIN <emu_target_name>
#     HW_XCLBIN <hw_target_name>
#     [EXTRA_ARGS ...]
#   )
# -------------------------------------------------------------------
function(add_xocc_hw_link_targets base_name xo_file)
  if(NOT VPP_EXECUTABLE)
    message(FATAL_ERROR "v++ not found, cannot create hardware link target")
  endif()

  set(options)
  set(oneValueArgs HW_EMU_XCLBIN HW_XCLBIN)
  set(multiValueArgs EXTRA_ARGS)
  cmake_parse_arguments(XOCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  # 输出文件路径
  set(hw_xclbin_file ${CMAKE_BINARY_DIR}/${base_name}.xclbin)
  set(hw_emu_xclbin_file ${CMAKE_BINARY_DIR}/${base_name}_emu.xclbin)

  # 硬件 xclbin
  add_custom_command(
    OUTPUT ${hw_xclbin_file}
    COMMAND ${VPP_EXECUTABLE} -t hw --link ${xo_file} -o ${hw_xclbin_file} ${XOCC_EXTRA_ARGS}
    DEPENDS ${xo_file}
    COMMENT "Linking hardware kernel ${xo_file} -> ${hw_xclbin_file}"
  )
  add_custom_target(${XOCC_HW_XCLBIN} ALL DEPENDS ${hw_xclbin_file})
  set_target_properties(${XOCC_HW_XCLBIN} PROPERTIES FILE_NAME ${hw_xclbin_file})

  # 硬件仿真 xclbin
  add_custom_command(
    OUTPUT ${hw_emu_xclbin_file}
    COMMAND ${VPP_EXECUTABLE} -t hw_emu --link ${xo_file} -o ${hw_emu_xclbin_file} ${XOCC_EXTRA_ARGS}
    DEPENDS ${xo_file}
    COMMENT "Linking hardware emu kernel ${xo_file} -> ${hw_emu_xclbin_file}"
  )
  add_custom_target(${XOCC_HW_EMU_XCLBIN} ALL DEPENDS ${hw_emu_xclbin_file})
  set_target_properties(${XOCC_HW_EMU_XCLBIN} PROPERTIES FILE_NAME ${hw_emu_xclbin_file})

  # 导出变量
  set(hw_xclbin ${XOCC_HW_XCLBIN} PARENT_SCOPE)
  set(hw_emu_xclbin ${XOCC_HW_EMU_XCLBIN} PARENT_SCOPE)
endfunction()