#include <stdio.h>
#include <intrin.h>
#include <stdlib.h> // rand()
#include <time.h>  // for srand()

// NOTE: This function just use 4 and multiples of size matrices like 4-8-12-16-...
// Square (N x N) 
#define N 4

extern "C" {
	int matrix_multiple(int[], int[], int, int, int[]);
}

void mulMat(int mat1[][N], int mat2[][N], int results[][N]);
bool resultChecker(int[][N], int[][N]);

int main(int argc, char* argv[])
{
	int matrix1[N][N];
	int matrix2[N][N];

	int matrix2Transposed[N][N];

	int matrixResult[N][N] = { 0 };

	unsigned __int64 initial_counter, final_counter;

	srand(time(0));

	// Generate random values for matrices
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			matrix1[i][j] = rand(); // % 100
			matrix2[i][j] = rand() / 100;
		}
	}

	initial_counter = __rdtsc();
	_asm {
		lea eax, matrix2Transposed
		push eax
		lea eax, matrixResult
		push eax
		push N; indicates Matrix size
		lea eax, matrix2
		push eax
		lea eax, matrix1
		push eax
		call matrix_multiple
		add esp, 20
	}
	final_counter = __rdtsc();
	printf("Assembly with SSE instructions is executed in %I64d CPU cycles. ", final_counter - initial_counter);
	printf("Assembly code result is: \n");
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			printf("%d \t", matrixResult[i][j]);
		}
		printf("\n");
	}

	printf("\n");


	int matrixResult2[N][N] = { 0 };

	initial_counter = __rdtsc();
	mulMat(matrix1, matrix2, matrixResult2); // Calls C++ code function
	final_counter = __rdtsc();
	printf("C/C++ code is executed in %I64d CPU cycles \n", final_counter - initial_counter);
	printf("C/C++ code result is: \n");
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			printf("%d \t", matrixResult2[i][j]);
		}
		printf("\n");
	}
	if (resultChecker(matrixResult, matrixResult2))
		printf("\nSUCCESS! Two of results are same.\n");
	else
		printf("\nFAILURE! Difference is found!\n");

	printf("\nPress any button to exit...");
	(void)getchar();
	return 0;
}

void mulMat(int mat1[][N], int mat2[][N], int rslt[][N]) {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			rslt[i][j] = 0;
			for (int k = 0; k < N; k++) {
				rslt[i][j] += mat1[i][k] * mat2[k][j];
			}
		}
	}
}

bool resultChecker(int m1[][N], int m2[][N]) {
	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			if (m1[i][j] != m2[i][j])
				return false;
		}
	}
	return true;
}
