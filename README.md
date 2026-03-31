# Void-Start-OS / Core

Void-Start-OS/Core は、Void-Start-OS の最小ブート可能カーネルを構成する「OS の心臓部」です。  
本リポジトリは、既存 OS や標準ライブラリに依存せず、x86 ベアメタル環境で OS を起動するための最小限の仕組みを提供します。

本コアは以下の機能を実装しています。

- 16bit リアルモード → 32bit 保護モードへの移行
- A20 ライン有効化
- GDT（Global Descriptor Table）構築
- CR0.PE=1 による保護モード突入
- C++ カーネルエントリ `kernel_main` の実行
- VGA テキスト VRAM への直接描画
- IDT（Interrupt Descriptor Table）構築
- CPU 例外ハンドラ（#DE, #GP, #PF）
- フラットバイナリ構成（boot.bin + kernel.bin）

本コアは Void-Start-OS のすべての機能の基盤となります。

---

---

## 1. 機能概要

### 2.1 ブートローダ（boot.asm）
- BIOS により 0x7C00 にロード
- A20 ラインを Fast A20 方式で有効化
- GDT を構築し、フラット 4GB セグメントを設定
- CR0.PE=1 により保護モードへ移行
- far jump により 32bit コードセグメントへ切り替え
- カーネルを物理アドレス 0x00010000 に読み込み
- C++ 関数 `kernel_main` を直接呼び出す

### 2.2 カーネル（kernel.cpp）
- freestanding C++（標準ライブラリ不使用）
- VGA テキスト VRAM (0xB8000) に直接文字列を描画
- IDT を初期化し、例外ハンドラを登録

### 2.3 IDT / ISR / 例外ハンドラ
- IDT を 256 エントリ分確保
- CPU 例外 (#DE, #GP, #PF) を登録
- 例外発生時に VGA にエラー内容を表示し停止

---

## 2. ビルド方法

### 必要ツール
- `nasm`
- `gcc`（32bit対応）
- `ld`
- `objcopy`
- `qemu-system-i386`

### ビルド
- make

### 実行（QEMU）
- make run

---
## LICENSE
- GNUlicenseです。



