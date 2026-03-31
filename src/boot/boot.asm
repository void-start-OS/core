; src/boot/boot.asm
; BIOSにより 0x7C00 にロードされる 512バイトのブートセクタ
; 16bitリアルモード → GDT設定 → CR0.PE=1 → far jump → 32bit保護モード
; 物理 0x00100000 にロードしたカーネルへ制御を渡す

[BITS 16]
[ORG 0x7C00]

start:
    cli                         ; 割り込み禁止（モード切替中に割り込みが来ると危険）

    ; セグメントレジスタ初期化
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00              ; とりあえずブートローダ直下をスタックにする

    mov [boot_drive], dl        ; BIOSが渡したブートドライブ番号を保存

    ;--------------------------------------
    ; カーネルを 0x00100000 に読み込む
    ;--------------------------------------
    ; ES:BX = 0x1000:0x0000 → 物理 0x1000 * 16 + 0 = 0x00100000
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02                ; INT 13h, AH=2: 読み込み
    mov al, 32                  ; 読み込むセクタ数（とりあえず32セクタ=16KB）
    mov ch, 0                   ; シリンダ 0
    mov cl, 2                   ; セクタ 2 から（セクタ1がブートセクタ）
    mov dh, 0                   ; ヘッド 0
    mov dl, [boot_drive]        ; ブートドライブ
    int 0x13
    jc disk_error               ; CF=1ならエラー

    ;--------------------------------------
    ; GDT 設定
    ;--------------------------------------
    lgdt [gdt_descriptor]

    ;--------------------------------------
    ; 保護モード有効化
    ;--------------------------------------
    mov eax, cr0
    or eax, 0x1                 ; CR0.PE (bit 0) = 1
    mov cr0, eax

    ; far jump で CS を 32bitコードセグメントに切り替えつつ
    ; プリフェッチキューをフラッシュ
    jmp CODE_SEL:protected_entry

;--------------------------------------
; ここから 32bit 保護モード
;--------------------------------------
[BITS 32]

protected_entry:
    ; セグメントレジスタを 32bit データセグメントに設定
    mov ax, DATA_SEL
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; スタックを上位メモリに設定（適当な安全そうな場所）
    mov esp, 0x00900000

    ; カーネルエントリへジャンプ
    ; カーネルは物理アドレス 0x00100000 にリンクされている
    mov eax, 0x00100000
    call eax

hang:
    cli
    hlt
    jmp hang

disk_error:
    ; 簡易エラー処理：とりあえず止まる
    cli
    hlt
    jmp $

;--------------------------------------
; GDT 定義
;--------------------------------------
; GDT はセグメントセレクタ → ベースアドレス/リミット/属性 の対応表。
; ここでは「フラットモデル」：
;   ベース = 0x00000000
;   リミット ≒ 4GB (0xFFFFF, granularity=4KB)
;   コード/データを分けた2エントリ + ヌル

gdt_start:
    dq 0                        ; ヌルディスクリプタ（必須）

gdt_code:                       ; コードセグメント
    dw 0xFFFF                   ; limit[0:15]
    dw 0x0000                   ; base[0:15]
    db 0x00                     ; base[16:23]
    db 10011010b                ; access: present=1, DPL=0, code=1, readable=1
    db 11001111b                ; flags: granularity=1(4KB), 32bit=1, limit[16:19]=0xF
    db 0x00                     ; base[24:31]

gdt_data:                       ; データセグメント
    dw 0xFFFF                   ; limit[0:15]
    dw 0x0000                   ; base[0:15]
    db 0x00                     ; base[16:23]
    db 10010010b                ; access: present=1, DPL=0, data=1, writable=1
    db 11001111b                ; flags: granularity=1, 32bit=1, limit[16:19]=0xF
    db 0x00                     ; base[24:31]

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1  ; サイズ - 1
    dd gdt_start                ; GDT のベースアドレス

CODE_SEL equ gdt_code - gdt_start
DATA_SEL equ gdt_data - gdt_start

boot_drive: db 0

;--------------------------------------
; ブートセクタ署名
;--------------------------------------
times 510 - ($ - $$) db 0
dw 0xAA55
