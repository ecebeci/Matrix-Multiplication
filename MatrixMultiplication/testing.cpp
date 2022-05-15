#include <stdio.h>
#include <intrin.h>
#include <stdlib.h> // rand()
#include <time.h> 

// NOTE: You need to change value if you change matrix size
// Square (N x N) Matrix size 4-8-12-16-...
#define N 20
#define TEST_NUMBER 10000

extern "C" {
	int matrix_multiple(int[], int[], int, int, int[]);
}

void mulMat(int mat1[][N], int mat2[][N], int results[][N]);
bool resultChecker(int[][N], int[][N]);

int testing(int argc, char* argv[]) 
{
	unsigned __int64 initial_counter, final_counter;

	srand(time(0));

	int matrix1[N][N];
	int matrix2[N][N];

	int matrix2Transposed[N][N];
	int matrixResult[N][N] = { 0 };

	// 
	for (int i = 0; i < TEST_NUMBER; i++) {

		for (int i = 0; i < N; i++) {
			for (int j = 0; j < N; j++) {
				matrix1[i][j] = rand(); // % 100;  //Generate number between 0 to 99
				matrix2[i][j] = rand(); //% 100;  //Generate number between 0 to 99
			}
		}

		printf("[%d] Matrices Size: %dx%d \t", i, N, N);
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
		printf("%I64d \t", final_counter - initial_counter);

		int matrixResult2[N][N] = { 0 };

		initial_counter = __rdtsc();
		mulMat(matrix1, matrix2, matrixResult2); // Calls C++ code function
		final_counter = __rdtsc();
		printf("%I64d\n", final_counter - initial_counter);

		if (!resultChecker(matrixResult, matrixResult2)) {
			printf("\nFAILURE! Difference is found! Test is halted!\n");
			return -1;
		}

	}
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