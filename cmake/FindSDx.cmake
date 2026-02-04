# FindSDx.cmake - 占位符
set(SDx_FOUND TRUE)
message(WARNING "SDx/Vitis not found - using stub. Hardware targets will not work.")

# 定义空的宏
macro(add_xocc_hw_link_targets)
  # 忽略所有参数
endmacro()
