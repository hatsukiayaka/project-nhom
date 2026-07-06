# SkyLog Smart Warehouse Network - Database System (Final Project)

Bài tập cuối kỳ môn học **Cơ sở dữ liệu** - Trường Quốc tế, Đại học Quốc gia Hà Nội (VNU-IS).

## 📝 Thông tin dự án
* **Đề tài:** Phân tích, Thiết kế và Triển khai Cơ sở dữ liệu cho Hệ thống SkyLog Smart Warehouse Network
* **Học phần:** Cơ sở dữ liệu 
* **Mã lớp học phần:** ISV10701
* **Giảng viên hướng dẫn:** Ths. Vũ Đức Minh
* **Thực hiện bởi:** Nhóm 4

---

## 💻 Cấu hình môi trường hệ thống
* **Hệ quản trị CSDL:** MySQL Server 8.0+
* **Storage Engine:** InnoDB
* **Bảng mã kí tự:** `utf8mb4`
* **Collation:** `utf8mb4_0900_ai_ci`

---

## 📁 Cấu trúc thư mục mã nguồn
Các tập tin cần thực thi theo đúng thứ tự sau:

| STT | Tên tập tin | Mô tả |
| :--- | :--- | :--- |
| 01 | `01_schema.sql` | Khởi tạo cấu trúc 13 bảng (DDL). |
| 02 | `02_seed_data.sql` | Nạp dữ liệu mẫu (DML). |
| 03 | `03_queries.sql` | 8 câu truy vấn báo cáo nghiệp vụ (Q01-Q08). |
| 04 | `04_views.sql` | Các khung nhìn quản trị. |
| 05 | `05_routines.sql` | Procedures & Functions. |
| 06 | `06_triggers_events.sql` | Triggers & Event Scheduler. |
| 07 | `07_indexes_explain.sql` | Chỉ mục (Index) & Phân tích hiệu năng. |
| 08 | `08_admin_backup.md` | Phân quyền & Hướng dẫn Backup. |
| 09 | `09_tests.sql` | Kiểm thử âm tính (Negative Testing). |

---

## 🚀 Hướng dẫn Triển khai
Mở MySQL Workbench, thực thi lần lượt các file từ `01` đến `07` theo thứ tự. Sử dụng file `09_tests.sql` để kiểm tra khả năng phòng vệ của hệ thống.

---
*Bản quyền thuộc về Nhóm 4 - ISV10701 - VNU IS © 2026.*
