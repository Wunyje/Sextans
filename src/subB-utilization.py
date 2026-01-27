#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
subB-utilization.py
统计稀疏矩阵在分块逻辑下的 B 子矩阵利用率：
UniqueCol(i) = ∪_{q=0}^{p-1} col(A_{qi})
"""

import sys
import numpy as np

WINDOW_SIZE = 4096   # K0
NUM_PE = 8           # 并行度 p

def read_matrix_market_csc(filename):
    """
    读取 MatrixMarket 格式的稀疏矩阵，并返回 CSC 格式
    返回: (M, N, nnz, CSCColPtr, CSCRowIndex, CSCVal)
    """
    from scipy.io import mmread
    mat = mmread(filename).tocsc()
    M, N = mat.shape
    nnz = mat.nnz
    CSCColPtr = mat.indptr.tolist()
    CSCRowIndex = mat.indices.tolist()
    CSCVal = mat.data.tolist()
    return M, N, nnz, CSCColPtr, CSCRowIndex, CSCVal


def compute_utilization(M, N, CSCColPtr, CSCRowIndex):
    num_windows = (N + WINDOW_SIZE - 1) // WINDOW_SIZE
    utilization = []

    for i in range(num_windows):
        start_col = i * WINDOW_SIZE
        end_col = min((i + 1) * WINDOW_SIZE, N)

        # 收集窗口内所有非零列索引
        unique_cols = set()
        nz_count = 0
        for col in range(start_col, end_col):
            col_nz = CSCColPtr[col+1] - CSCColPtr[col]
            nz_count += col_nz
            if col_nz > 0:
                unique_cols.add(col)

        window_size_actual = end_col - start_col
        util = len(unique_cols) / window_size_actual
        avg_nz_per_col = nz_count / len(unique_cols) if unique_cols else 0

        utilization.append((i, len(unique_cols), util, nz_count, avg_nz_per_col))

    return utilization



def main():
    if len(sys.argv) < 2:
        print("用法: python subB-utilization.py matrix.mtx")
        sys.exit(1)

    filename = sys.argv[1]
    M, N, nnz, CSCColPtr, CSCRowIndex, CSCVal = read_matrix_market_csc(filename)

    utilization = compute_utilization(M, N, CSCColPtr, CSCRowIndex)

    print(f"Matrix: {filename}, shape=({M},{N}), nnz={nnz}")
    print(f"WINDOW_SIZE={WINDOW_SIZE}, NUM_PE={NUM_PE}")
    print("Window\tUniqueCol\tUtilization\tNZcount\tAvgNZ/col")
    for i, uniq, util, nz_count, avg_nz in utilization:
        print(f"{i}\t{uniq}\t{util:.4f}\t{nz_count}\t{avg_nz:.2f}")



if __name__ == "__main__":
    main()

    import matplotlib.pyplot as plt

    # 数据
    utilization = [
        0.3870,0.4856,0.5483,0.3477,0.3118,0.3713,0.3159,0.2771,0.3369,0.2546,
        0.2844,0.1838,0.4456,0.3809,0.2605,0.3323,0.5840,0.9202,0.8357
    ]
    windows_mod = list(range(19))
    labels = [f"A{i}" for i in range(19)]

    # 设置全局字体为 Times New Roman
    plt.rcParams["font.family"] = "Times New Roman"

    # 绘图
    fig, ax = plt.subplots(figsize=(10,6))
    bars = ax.bar(windows_mod, utilization, width=0.9, color='steelblue')

    # 设置横轴刻度
    ax.set_xticks(windows_mod)
    ax.set_xticklabels(labels, rotation=45, fontsize=14)

    # 去掉纵坐标刻度和标签
    ax.set_yticks([])
    ax.set_ylabel("")
    ax.set_xlabel("")
    plt.title("")

    # 去掉边框
    for spine in ["top","right","left","bottom"]:
        ax.spines[spine].set_visible(False)

    # 在柱子上显示数值
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2, height + 0.01,
                f"{height:.2f}", ha='center', va='bottom', fontsize=14)

    plt.tight_layout()
    plt.show()

