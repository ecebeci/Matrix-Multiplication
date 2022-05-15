.MODEL FLAT, C 
.CODE 

PUBLIC matrix_multiple
matrix_multiple PROC
push ebp
mov ebp, esp
push ecx
push ebx
push edx

; Transpose 2nd Matrix
mov ecx, 0
mov ebx, [ebp+12] 
transpose1:
	push ecx; buradaki ecx ROW sayisi 0 1 2 3 4 4 6 ...
	mov ecx, 0
	transpose2:
			;i
			mov eax, [esp] 
			shl eax, 2
			mov edx, [ebp+16] 
			mul edx
			push eax 

			;j
			mov eax, 4
			mul ecx

			; i + j
			pop edx
			add eax, edx

			; 2nd matrix address
			add eax, ebx 
			push [eax] 

			; m2[i][j] to transpozeM[j][i] 
			; i (behaves j like above)
			mov eax, [esp+4] 
			shl eax, 2 
			push eax 

			; j (behaves i like above)
			mov eax, 4
			mul ecx
			mov edx, [ebp+16] 
			mul edx
			
			; i + j 
			pop edx 
			add eax, edx

			; Matris2Transposed address
			mov edx, [ebp+24] 
			add eax, edx ; i and j addresses added

			pop edx ; 2nd matrix value
			mov [eax], edx 
			
			;; end of move
			inc ecx; 1 ekle - for next j

			mov eax, [ebp+16] ; n sayýsý
			cmp ecx, eax ; checking iteration
			jne transpose2;

	pop ecx; 

	inc ecx 
	mov eax, [ebp+16] 
	cmp ecx, eax 
	jne transpose1;

mov eax, [ebp+24]
mov [ebp+12], eax 


; Matrix Multiplication
mov ecx, 0
mov ebx, [ebp+8] ;ebx 1st matrix address
r1:
	push ecx; ROW
	mov ecx, 0
		r2: ; 0,1,2,3,4
			psllq xmm2, 64 ; resets xmm2 (preventing r[0][0] wrong calculation)
			push ecx; 
			mov ecx, 0
			r3: ; r3 0 16 32 64 
				mov eax, ecx;  
				add eax, ebx 
				add eax, [esp+4] 
				movdqu xmm0, [eax] 

				;; r2 column ve r3 adresi iterations
				mov eax, [esp] 
				shl eax, 2 
				mov edx, [ebp+16] 
				mul edx

				add eax, ecx
				add eax, [ebp+12]
				movdqu xmm1, [eax] 
			
				pmaddwd xmm0, xmm1 
				
				pshufd xmm1,xmm0,4eh
				paddd  xmm0,xmm1
				pshuflw xmm1,xmm0,4eh
				paddd  xmm0,xmm1
				movd   eax,xmm0 

				
				paddd xmm2, xmm0
				 
			
				add ecx, 16 
				mov eax, [ebp+16] 
				shl eax, 2
				cmp ecx, eax 
				jne r3;
			pop ecx 

		
			mov eax, ecx 
			shl eax, 2
			add eax, [ebp+20]
			add eax, [esp]
			mov edx, eax

			movd eax, xmm2
			psllq xmm2, 64 
			
			mov [edx], eax 

			inc ecx
			mov eax, [ebp+16]
			cmp ecx, eax 
			jne r2
	pop ecx;


	mov eax, [ebp+16]
	shl eax, 2 
	add ecx, eax

	
	mov eax, [ebp+16]
	imul eax; 
	shl eax, 2  
	cmp ecx, eax
	jne r1;

pop edx
pop ebx
pop ecx
pop ebp
ret
matrix_multiple ENDP
END 
