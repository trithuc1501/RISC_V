// PC | Mã Hex (32-bit) | Lệnh Assembly       | Giải thích
// ---|-----------------|---------------------|------------------------------------------------
// ==================== HÀM MAIN ====================
   0  | 04000513        | addi a0, x0, 64     | a0 (x10) = 64. Trỏ a0 tới địa chỉ bắt đầu của mảng (DMEM[64])
   4  | 00300593        | addi a1, x0, 3      | a1 (x11) = 3. Số lượng phần tử trong mảng
   8  | 010000ef        | jal  ra, 16         | Gọi hàm Sum: Nhảy đến PC=24 (8+16), lưu địa chỉ trả về (PC=12) vào ra (x1)
  12  | 00a03023        | sd   a0, 0(x0)      | Lệnh trả về từ hàm: Ghi kết quả tổng (đang lưu ở a0) vào DMEM[0]
  16  | 0000006f        | jal  x0, 0          | Vòng lặp vô tận: Dừng chương trình (Nhảy tại chỗ PC=16)
  20  | 00000013        | nop                 | (Lệnh rỗng) addi x0, x0, 0 để căn lề địa chỉ
// ==================== HÀM SUM =====================
  24  | 00000293        | addi t0, x0, 0      | t0 (x5) = 0. Khởi tạo biến TỔNG (Sum)
  28  | 00000313        | addi t1, x0, 0      | t1 (x6) = 0. Khởi tạo biến ĐẾM (Index)
// --- Bắt đầu vòng lặp (Loop) ---
  32  | 00b35c63        | bge  t1, a1, 24     | Kiểm tra: Nếu t1 >= a1 (Index >= 3), thoát vòng lặp nhảy đến PC=56 (32+24)
  36  | 00053383        | ld   t2, 0(a0)      | Đọc phần tử mảng từ RAM vào t2 (x7)
  40  | 007282b3        | add  t0, t0, t2     | CỘNG DỒN: t0 = t0 + t2 (Tổng = Tổng + Phần tử hiện tại)
  44  | 00850513        | addi a0, a0, 8      | a0 = a0 + 8. Dịch con trỏ mảng sang phần tử tiếp theo (8 bytes = 64-bit)
  48  | 00130313        | addi t1, t1, 1      | t1 = t1 + 1. Tăng biến đếm Index lên 1
  52  | fedff06f        | jal  x0, -20        | Nhảy lặp lại: Quay về đầu vòng lặp tại PC=32 (52 - 20)
// --- Thoát vòng lặp (Exit) ---
  56  | 00500533        | add  a0, x0, t0     | Chép kết quả tổng từ t0 sang a0 để chuẩn bị trả về (Return value)
  60  | 00008067        | jalr x0, 0(ra)      | Return: Nhảy về địa chỉ đã lưu trong thanh ghi ra (PC=12)