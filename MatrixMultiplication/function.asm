.MODEL FLAT, C 

.CODE ;Indicates the start of the code segment.

PUBLIC matrix_multiple
matrix_multiple PROC
; BILGI : EIP call fonksiyonu cagriminda pushlanmistir
push ebp
mov ebp, esp
push ecx
push ebx
push edx

mov ecx, 0
mov ebx, [ebp+12] ;ebx 2. matrisin adresini tutar
transpose1:
	push ecx; buradaki ecx ROW sayisi 0 1 2 3 4 4 6 ...
	mov ecx, 0
	transpose2:
			;; transpoze iþlemi (m2[i][j] alinir transpozeMatrix[j][i] kismina koyulur)
			;i
			mov eax, [esp] ; r1 icin row sayisi da gelir dikkat sayi oldugundan onu satir tamamlanmis gibi almamiz lazim
			shl eax, 2
			mov edx, [ebp+16] ; n sayisi ile carpilir ki o kadar eleman tamamlanmis ve satir atlanmis olsun
			mul edx
			push eax 

			;j
			mov eax, 4; int 4 byte kacinci siradaki (bu sadece carpim icin matrix sonucu icin yer tutulurken bu kisim alinmaz)
			mul ecx; bu komutla j carpilir ki satir bulunur

			; i + j
			pop edx
			add eax, edx

			; 2. matrisin matrix adresin eklenmesi
			add eax, ebx ; 2. matrisin adresi gelir ve iterasyonda tasinacak index bulunmus olur
			push [eax] ; 2. matrisin degeri tutulur


			; m2[i][j] in transpozeM[j][i] adreste tutulmasi
			; i (yukaridakí j gibi davranir)
			mov eax, [esp+4] ; r1 alinir! r1 burada 1 2 3 4 5 6
			shl eax, 2 ; 4 byte carpim
			push eax ; eax tutalim 

			; j (ustteki i gibi davranir)
			mov eax, 4; int 4 byte kacinci siradaki (bu sadece carpim icin matrix sonucu icin yer tutulurken bu kisim alinmaz)
			mul ecx; bu komutla j alinir
			mov edx, [ebp+16] ; n sayisi
			mul edx
			
			; i + j 
			pop edx ; i geri getirilir
			add eax, edx; i + j

			; Aradaki transpoze edilecek olan matrix adresin eklenmesi
			mov edx, [ebp+24] ; transpoze matrisi
			add eax, edx ; i+j ile transpoze matrisi adresi toplanir. offset saglandi!

			;; adres gecici olarak edx de tutulur ki eax karismasin
			pop edx ; 2. matrix degeri gelir
			mov [eax], edx ; edx adresine 2. matrisin degeri atilir
			
			;; tasima sonu
			inc ecx; 1 ekle - bir sonraki j icin

			; row lara gore adres eklenir ve sonraki row a gecis saglanir
			mov eax, [ebp+16] ; n sayýsý
			cmp ecx, eax ; n kadar gidildi mi check
			jne transpose2;

	pop ecx; ;transpose1 ecx'i geri getirilir

	inc ecx 
	mov eax, [ebp+16] ; n sayýsý
	cmp ecx, eax ; n kadar gidildi mi check
	jne transpose1;

mov eax, [ebp+24]
mov [ebp+12], eax ; transpoze edilmis adres ebp ye aktarilir. matrix 2 ile isimiz kalmadi. transpoze edilmis matris var. onun adresi kullanilir.

; transpose iþlemi sonucunda 2. matrisin adresi transpoze ettiðimiz adrese yönlendirir ki simd column wised oldugundan kolaylik saglar

; Carpma islemi
mov ecx, 0
mov ebx, [ebp+8] ;ebx 1. matrixin adresini tutar r1 icerisinde her iterasyonda ebx arttirilir
r1:
	push ecx; buradaki ecx ROW (offsetsiz  0 - 16 - 32 gibi olur adresler)
	mov ecx, 0
		r2:
			psllq xmm2, 64 ; resets xmm2 (preventing r[0][0] wrong calculation)
			push ecx; buradaki ecx COL tutar (offsetsiz  0 - 4 - 8 gibi)
			mov ecx, 0
			r3: ; r3 0 16 32 64 diye gider burada amac 4lü toplamlarý kolaylastýrma
				mov eax, ecx; ; 
				add eax, ebx ; 1 .matris gelir
				add eax, [esp+4] ; r1 icin row adresi de gelir 0 16 32 gibi . Boylece kacinci column da oldugu gorulur
				movdqu xmm0, [eax] ; eax degeri movdqu da tutulur

				;; r2 column ve r3 adresi iterasyonlari
				;; transpoze matrix ile rahatlikla islem
				;; n x eleman sayisi x 4 byte ile satirin baslangici. r2 de n kullandik cunku r2 kaydederken n gerekiyor maalesef o yuzden direkt adres olamiyor
				mov eax, [esp] ; satir sayisi
				shl eax, 2 ; 4 ile carpariz (mov edx, 4 mul edx)
				mov edx, [ebp+16] ; eleman ile carpariz ki o satira gideriz
				mul edx

				add eax, ecx; ecx adresi kadar adres eklenir ki diger 4lu
				add eax, [ebp+12] ; 2. matrix ana adresi
				movdqu xmm1, [eax] ; 2 . matrix sonraki 4luyu belirten 1. adres movdqu da getilir ve orada tutulur (cunku tek tek eklemek lazim column)
				
				; 4 sayi karsiligindaki 4 sayiyla carpilir
				pmaddwd xmm0, xmm1 ; xmm1 ile xmm 0 carpilir sonuclar xmm 0 da olur
				
				; XMM0 icinde horizantal toplama
				pshufd xmm1,xmm0,4eh
				paddd  xmm0,xmm1
				pshuflw xmm1,xmm0,4eh
				paddd  xmm0,xmm1
				movd   eax,xmm0 ; Deger eax'a aktarilir

				;; toplama kismi 
				paddd xmm2, xmm0; stack deki eax ile toplanir. Kumulatif.
				 
				; n kadar olacak
				add ecx, 16 ; ecx 16 eklenir. Yani 4 eleman gitti 4x4= 16 eleman
				mov eax, [ebp+16] ; n ile esit mi kontrol et
				shl eax, 2
				cmp ecx, eax ; n kadar gidildi mi check
				jne r3;
			pop ecx ; r2 iterasyonu geri eklendi 

			; EAX i yeni matrix adresine aktarmak. Bu kod parcaciklari daha iyi sekle optimize edilebilir
			mov eax, ecx ; r2 iterasyonu da eklenir
			shl eax, 2 ; r2 (sayi) x 4 bit
			add eax, [ebp+20]; GOLD ! Iterasyon adresi ile ucuncu matris adresi ebx uzerinde toplanir hmmm push a gerek kalmadi
			add eax, [esp];  r1 in iterasyonu geldi hmm.
			mov edx, eax

			movd eax, xmm2
			psllq xmm2, 64 ; sagli sollu 64 bit kaydirma yani sifirlar BILGI: https://www.officedaytime.com/simd512e/simdimg/shift.php?f=psllq
			
			mov [edx], eax ; ve eax taki calculated sonuc ebx e aktarildi

			; row lara gore adres eklenir ve sonraki row a gecis saglanir
			inc ecx; 1 eklenir
			mov eax, [ebp+16]
			cmp ecx, eax ; n. adim kadar gidildi mi check
			jne r2;
	pop ecx;

	;; row daki iterasyon bitince sonraki row icin: column(bu row ile esittir) sayisi * 4 byte kadar adres gider.
	mov eax, [ebp+16]
	shl eax, 2 ; 4 bit sola kaydirip carpma. 8 row alindiysa 8 x 4 = 32 adres gitmistir demek
	add ecx, eax

	; iterasyon 1 de maks size ulasildi mi kontrolu
	mov eax, [ebp+16]
	imul eax; ; kendisiyle carpar ki o kadar eleman vardir 8 x 8 = 64 eleman gibi
	shl eax, 2  ; int 4 byte adresledigi icin o kadar da carpilir  8 x 8 x 4 = adres
	cmp ecx, eax
	jne r1;


pop edx
pop ebx
pop ecx
pop ebp
ret
matrix_multiple ENDP
END 