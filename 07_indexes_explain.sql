-- ====================================================================
-- FILE 07: INDEX OPTIMIZATION & EXPLAIN ANALYSIS
-- PROJECT: SKYLOG SMART WAREHOUSE NETWORK DATABASE
-- MỤC ĐÍCH: Tạo chỉ mục B-Tree tối ưu truy vấn & Phân tích kế hoạch thực thi
-- ====================================================================

USE SkyLog_SmartWarehouse;

-- --------------------------------------------------------------------
-- 1. TẠO CÁC CHỈ MỤC B-TREE (CREATE INDEXES)
-- --------------------------------------------------------------------

-- Index 1: Tối ưu tìm kiếm nhân viên theo Họ và Tên (Thường dùng trong ô tìm kiếm App UI)
CREATE INDEX idx_emp_name ON EMPLOYEE(last_name, first_name);

-- Index 2: Tối ưu kiểm tra quyền tường lửa thời gian thực (Lọc theo thiết bị và trạng thái hiệu lực)
CREATE INDEX idx_approval_status ON DEVICE_SERVER_APPROVAL(device_id, revoked_date);


-- --------------------------------------------------------------------
-- 2. PHÂN TÍCH KẾ HOẠCH THỰC THI (EXPLAIN PERFORMANCE ANALYSIS)
-- --------------------------------------------------------------------

-- Yêu cầu kiểm chứng: Đánh giá hiệu năng khi hệ thống tường lửa quét quyền truy cập
-- của thiết bị DEV-MB-02 vào các máy chủ (tìm các kết nối đang Active: revoked_date IS NULL)

EXPLAIN SELECT approval_id, device_id, server_id, approval_date 
FROM DEVICE_SERVER_APPROVAL 
WHERE device_id = 'DEV-MB-02' AND revoked_date IS NULL;

/* =======================================================================
GHI CHÚ ĐÁNH GIÁ KẾ HOẠCH THỰC THI (EXPLAIN RESULTS & TRADE-OFFS):
=======================================================================
1. Hiệu quả của Index (Rationale & Performance):
   - Trước khi có Index: Hệ quản trị MySQL buộc phải thực hiện quét toàn bảng (Full Table Scan - type: ALL), 
     độ trễ sẽ tăng tuyến tính O(N) khi lượng lịch sử log lên tới hàng triệu dòng.
   - Sau khi tạo idx_approval_status: Cột key trong bảng EXPLAIN hiển thị rõ tên chỉ mục idx_approval_status. 
     MySQL thực hiện tìm kiếm theo phạm vi/tham chiếu (type: ref), giúp giảm tối đa số dòng phải quét (cột rows), 
     đáp ứng tốc độ phản hồi tính bằng mili-giây cho hệ thống an ninh mạng.

2. Sự đánh đổi kỹ thuật (Index Trade-offs):
   - Việc duy trì idx_approval_status giúp tối ưu cực nhanh thao tác đọc (SELECT), nhưng đánh đổi lại 
     thao tác ghi (INSERT/UPDATE/DELETE) sẽ chậm đi đôi chút do B-Tree phải tự cân bằng lại cấu trúc. 
   - Đồng thời Index tiêu tốn thêm dung lượng lưu trữ trên đĩa cứng. Do vậy, hệ thống chỉ chỉ định Index 
     cho những cột có tần suất truy vấn WHERE/JOIN cao nhất.
=======================================================================
*/