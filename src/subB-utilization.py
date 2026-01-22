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
