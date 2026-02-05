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
# Define replacement for add_xocc_hw_link_targets
# -------------------------------------------------------------------
function(add_xocc_hw_link_targets target_name xo_file)
  if(NOT VPP_EXECUTABLE)
    message(FATAL_ERROR "v++ not found, cannot create hardware link target")
  endif()

  # 输出文件路径
  set(xclbin_file ${CMAKE_BINARY_DIR}/${target_name}.xclbin)

  # 用 add_custom_command 生成文件
  add_custom_command(
    OUTPUT ${xclbin_file}
    COMMAND ${VPP_EXECUTABLE} -t hw --link ${xo_file} -o ${xclbin_file}
    DEPENDS ${xo_file}
    COMMENT "Linking hardware kernel ${xo_file} -> ${xclbin_file}"
  )

  # 自动去掉路径，只保留文件名作为 target 名字
  get_filename_component(target_basename ${target_name} NAME)
  add_custom_target(${target_basename}_hw_link ALL DEPENDS ${xclbin_file})
endfunction()
