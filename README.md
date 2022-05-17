# Square Matrix Multiplication using SIMD Instructions
Efficiently, same size square two matrix multiplication using Assembly and SSE2 Instructions.

**NOTE**: This function is able to multiply 4 and multiples of square matrix size like 4x4-8x8-12x12-16x16-20x20-...

# Introduction

Matrix is an array for numbers, characters, or other types of data,
arranged in rows and columns. A matrix can be modified by operations
with scalars, vectors, or matrices. Each matrix has **row** and
**column** size. A matrix with m rows and n columns is called an m x n
matrix. If matrix has same row and column size, that matrix is called
**square matrix**. Single-instruction, multiple data (**SIMD**)
instructions are used for computing vector operations.

In this work, I had built a function that multiplies two square matrices
whose has integer numbers efficiently. I used **SSE2** (Streaming SIMD
Extensions 2) instructions for parallel operations as it is intended it
to be faster than C compiled only **SISD** architecture-based code.
Besides that, I used the SISD instructions (pure assembly) to flow
control like loops in function. At the final, the function I built, and
C compiled code was compared on **CPU cycles**.

# Results and Comparison 
**10000** iterations with random integer numbers were tested on each
size of square matrix. Average results of C compiled code and SIMD and
Pure Assembly code had compared each other. The minimum size of matrix
was **4x4** and maximum was **224x224** on the testing. Function had
problems after more than 224x244 size in executing. 100% stacked results
chart are given on below.

![image](https://user-images.githubusercontent.com/31591904/168827779-bc4d4423-46c2-4d2b-b8aa-79abb5b54560.png)

As can be seen, it has been observed that it is at least **40 percent**
more efficient in tests. Maximum efficiency is around **60 percent**.

# License
This project is licensed under the GPL License - see the LICENSE.md file for details
