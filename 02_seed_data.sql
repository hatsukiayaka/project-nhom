-- ==============================================================================
-- SKYLOG SMART WAREHOUSE - DUMMY DATA GENERATOR
-- THIẾT KẾ ĐỂ ĐÁNH GIÁ CÁC CÂU LỆNH SELECT VÀ REPORTING VIEWS
-- ==============================================================================

-- Tắt khóa ngoại tạm thời để TRUNCATE làm sạch bảng trước khi Insert
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE DEVICE_SERVER_APPROVAL;
TRUNCATE TABLE MOBILE_DEVICE;
TRUNCATE TABLE FIXED_WORKSTATION;
TRUNCATE TABLE DEVICE;
TRUNCATE TABLE SERVICE_ACCESS;
TRUNCATE TABLE SERVICE;
TRUNCATE TABLE VIRTUAL_SERVER;
TRUNCATE TABLE PHYSICAL_SERVER;
TRUNCATE TABLE SERVER;
TRUNCATE TABLE COMPUTER_ROOM;
TRUNCATE TABLE ACCOUNT;
TRUNCATE TABLE EMPLOYEE;
TRUNCATE TABLE DEPARTMENT;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------------------
-- 1. INSERT DATA: DEPARTMENT (PHÒNG BAN)
-- ------------------------------------------------------------------------------
INSERT INTO DEPARTMENT (dept_code, dept_name, internal_mailbox, phone_number) VALUES
('BOD', 'Hội đồng Quản trị', 'BOX-001', '024-1111-0001'),
('IT_SYS', 'Hệ thống Công nghệ Thông tin', 'BOX-IT-99', '024-1111-1001'),
('LOG_OPS', 'Điều phối Logistics Tổng', 'BOX-LOG-01', '024-1111-2001'),
('WH_Z_A', 'Quản lý Kho Zone A', 'BOX-WHA-01', '024-1111-3001'),
('WH_Z_B', 'Quản lý Kho Zone B', 'BOX-WHB-01', '024-1111-3002'),
('HR_ADM', 'Nhân sự & Hành chính', 'BOX-HR-01', '024-1111-4001'),
('RND_ROB', 'Nghiên cứu & Bảo trì Robot', 'BOX-RND-01', '024-1111-6001'),
('SEC_PHY', 'An ninh Vật lý Kho xưởng', 'BOX-SEC-01', '024-1111-7001');

-- ------------------------------------------------------------------------------
-- 2. INSERT DATA: EMPLOYEE (NHÂN SỰ)
-- ------------------------------------------------------------------------------
INSERT INTO EMPLOYEE (emp_id, last_name, middle_initial, first_name, job_title, dept_code) VALUES
('E0001', 'Nguyen', 'Van', 'An', 'Giám đốc Công nghệ (CTO)', 'BOD'),
('E0002', 'Tran', 'Thi', 'Binh', 'Quản lý IT Hệ thống', 'IT_SYS'),
('E0003', 'Le', 'Hoang', 'Cuong', 'Chuyên viên Quản trị Mạng', 'IT_SYS'),
('E0004', 'Pham', 'Thanh', 'Dung', 'Điều phối viên Logistics', 'LOG_OPS'),
('E0005', 'Hoang', 'Minh', 'Tien', 'Trưởng Kho Zone A', 'WH_Z_A'),
('E0006', 'Dinh', 'Quang', 'Hieu', 'Nhân viên Lái xe Nâng', 'WH_Z_A'),
('E0007', 'Vo', 'Thi', 'Hoa', 'Nhân viên Kiểm đếm (Checker)', 'WH_Z_B'),
('E0008', 'Ngo', 'Van', 'Khoa', 'Kỹ thuật viên Robot AGV', 'RND_ROB'),
('E0009', 'Vu', 'Thanh', 'Long', 'Tổ trưởng Bảo vệ', 'SEC_PHY'),
('E0010', 'Bui', 'Ngoc', 'Mai', 'Chuyên viên Nhân sự', 'HR_ADM'),
('E0011', 'Trinh', 'Thi', 'Phuong', 'Database Admin (DBA)', 'IT_SYS'),
('E0012', 'Mai', 'Xuan', 'Quang', 'Trưởng Kho Zone B', 'WH_Z_B'),
('E0013', 'Phan', 'Van', 'Vinh', 'Kỹ sư Bảo trì Lõi', 'WH_Z_A');

-- ------------------------------------------------------------------------------
-- 3. INSERT DATA: ACCOUNT (TÀI KHOẢN SINGLE SIGN-ON)
-- ------------------------------------------------------------------------------
-- Sử dụng SHA2() để giả lập quá trình sinh mã hash mật khẩu trong DB thực tế
INSERT INTO ACCOUNT (emp_id, username, password_hash) VALUES
('E0001', 'admin.an', SHA2('ComplexP@ss1', 256)),
('E0002', 'mgr.binh', SHA2('ComplexP@ss2', 256)),
('E0003', 'sys.cuong', SHA2('ComplexP@ss3', 256)),
('E0005', 'wh.tien', SHA2('ComplexP@ss5', 256)),
('E0008', 'tech.khoa', SHA2('ComplexP@ss8', 256)),
('E0011', 'dba.phuong', SHA2('ComplexP@ss11', 256));

-- ------------------------------------------------------------------------------
-- 4. INSERT DATA: COMPUTER_ROOM (PHÒNG MÁY CHỦ)
-- ------------------------------------------------------------------------------
INSERT INTO COMPUTER_ROOM (room_id, room_name) VALUES
('CR-MAIN-HN', 'Data Center Cốt lõi - Trụ sở Hà Nội'),
('CR-DR-HCM', 'Data Center Dự phòng (Disaster Recovery) - HCM'),
('CR-EDG-WHA', 'Phòng Edge Computing - Cạnh Kho Zone A');

-- ------------------------------------------------------------------------------
-- 5. INSERT DATA: SERVER (MÁY CHỦ TỔNG)
-- ------------------------------------------------------------------------------
INSERT INTO SERVER (server_id, server_name, vendor, ip_address, os, server_type, room_id) VALUES
-- Các máy chủ Vật lý (PHYSICAL)
('SRV-P-001', 'Core-Router-Phy-01', 'Cisco', '10.0.0.1', 'Cisco IOS', 'PHYSICAL', 'CR-MAIN-HN'),
('SRV-P-002', 'Dell-PowerEdge-R740-01', 'Dell EMC', '10.0.0.10', 'VMware ESXi 8.0', 'PHYSICAL', 'CR-MAIN-HN'),
('SRV-P-003', 'Dell-PowerEdge-R740-02', 'Dell EMC', '10.0.0.11', 'VMware ESXi 8.0', 'PHYSICAL', 'CR-MAIN-HN'),
('SRV-P-004', 'HP-ProLiant-Edge-Node', 'HP', '10.1.0.10', 'Windows Server Core', 'PHYSICAL', 'CR-EDG-WHA'),

-- Các máy chủ Ảo (VIRTUAL) sẽ cưỡi lên các máy vật lý trên
('SRV-V-001', 'VM-AppServer-WMS', 'VMware', '10.0.0.50', 'Ubuntu Server 24.04', 'VIRTUAL', 'CR-MAIN-HN'),
('SRV-V-002', 'VM-DBServer-Oracle', 'VMware', '10.0.0.51', 'RedHat Enterprise Linux', 'VIRTUAL', 'CR-MAIN-HN'),
('SRV-V-003', 'VM-MailServer-Exch', 'VMware', '10.0.0.52', 'Windows Server 2022', 'VIRTUAL', 'CR-MAIN-HN'),
('SRV-V-004', 'VM-Edge-RobotController', 'Hyper-V', '10.1.0.50', 'Ubuntu Server 24.04', 'VIRTUAL', 'CR-EDG-WHA');

-- Phân rã dữ liệu vào bảng Vật lý
INSERT INTO PHYSICAL_SERVER (server_id) VALUES 
('SRV-P-001'), ('SRV-P-002'), ('SRV-P-003'), ('SRV-P-004');

-- Phân rã dữ liệu vào bảng Ảo (Mapping VM vào Bare-metal)
INSERT INTO VIRTUAL_SERVER (server_id, host_physical_id) VALUES
('SRV-V-001', 'SRV-P-002'), -- VM WMS chạy trên Máy Dell số 1
('SRV-V-002', 'SRV-P-002'), -- VM Database cũng chạy trên Máy Dell số 1
('SRV-V-003', 'SRV-P-003'), -- VM Mail chạy trên Máy Dell số 2
('SRV-V-004', 'SRV-P-004'); -- VM Robot Controller chạy trên Máy HP Edge tại Kho

-- ------------------------------------------------------------------------------
-- 6. INSERT DATA: SERVICE (DỊCH VỤ PHẦN MỀM)
-- ------------------------------------------------------------------------------
INSERT INTO SERVICE (service_code, service_name, start_date, server_id) VALUES
('SVC-WMS-01', 'Hệ thống Quản trị Kho bãi WMS Core', '2024-01-01', 'SRV-V-001'),
('SVC-DBS-01', 'Kho Dữ liệu Trung tâm (Data Lake)', '2024-01-01', 'SRV-V-002'),
('SVC-MAIL', 'Email Doanh nghiệp Exchange', '2024-02-15', 'SRV-V-003'),
('SVC-ROBOT', 'Bộ Não Điều phối Robot AGV', '2025-06-01', 'SRV-V-004');

-- ------------------------------------------------------------------------------
-- 7. INSERT DATA: SERVICE_ACCESS (PHÂN QUYỀN SỬ DỤNG PHẦN MỀM)
-- ------------------------------------------------------------------------------
INSERT INTO SERVICE_ACCESS (emp_id, service_code, granted_date) VALUES
('E0001', 'SVC-WMS-01', '2024-01-02'),
('E0001', 'SVC-DBS-01', '2024-01-02'),
('E0002', 'SVC-DBS-01', '2024-01-05'),
('E0005', 'SVC-WMS-01', '2024-03-01'),
('E0008', 'SVC-ROBOT', '2025-06-05');

-- ------------------------------------------------------------------------------
-- 8. INSERT DATA: DEVICE (ĐĂNG KÝ TÀI SẢN THIẾT BỊ ĐẦU CUỐI)
-- ------------------------------------------------------------------------------
INSERT INTO DEVICE (device_id, brand, model, registration_date, device_type, emp_id) VALUES
('DEV-PC-01', 'Dell', 'Optiplex 7000 MT', '2024-01-10', 'FIXED_WORKSTATION', 'E005'),
('DEV-PC-02', 'HP', 'EliteDesk 800 G6', '2024-06-15', 'FIXED_WORKSTATION', 'E009'),
('DEV-MB-01', 'Apple', 'MacBook Pro 14 M2', '2025-01-05', 'MOBILE_DEVICE', 'E001'),
('DEV-MB-02', 'Lenovo', 'ThinkPad T14 Gen 3', '2025-02-10', 'MOBILE_DEVICE', 'E002'),
('DEV-MB-03', 'Zebra', 'TC52 Handheld Scanner', '2025-05-20', 'MOBILE_DEVICE', 'E006'),
('DEV-MB-04', 'Zebra', 'TC52 Handheld Scanner', '2025-05-20', 'MOBILE_DEVICE', 'E007'),
('DEV-MB-05', 'Samsung', 'Galaxy Tab Active3', '2026-01-10', 'MOBILE_DEVICE', 'E008');

-- ------------------------------------------------------------------------------
-- 9. Phân rã dữ liệu: FIXED_WORKSTATION
-- ------------------------------------------------------------------------------
INSERT INTO FIXED_WORKSTATION (device_id, static_ip_address, mac_address, building_name, room_number) VALUES
('DEV-PC-01', '192.168.10.100', '00:1A:2B:3C:4D:5E', 'Warehouse Zone A', 'Bàn Điều phối Số 1'),
('DEV-PC-02', '192.168.99.100', '00:1A:2B:3C:4D:6F', 'Cổng Chính Trụ Sở', 'Chốt Bảo vệ Số 1');

-- ------------------------------------------------------------------------------
-- 10. Phân rã dữ liệu: MOBILE_DEVICE (Kèm thiết lập Security)
-- ------------------------------------------------------------------------------
INSERT INTO MOBILE_DEVICE (device_id, serial_number, operating_system, os_version, screen_lock_enabled, data_encryption_enabled) VALUES
('DEV-MB-01', 'MAC-999999X', 'macOS', '14.2', 1, 1), -- Máy sếp: FileVault bật, an toàn.
('DEV-MB-02', 'LEN-888888Y', 'Windows', '11 Pro', 1, 1), -- Máy IT: BitLocker bật, an toàn.
('DEV-MB-03', 'ZEB-111111A', 'Android', '11.0', 1, 1), -- Máy quét mã vạch 1: Chuẩn cty cấp, an toàn.
('DEV-MB-04', 'ZEB-222222B', 'Android', '11.0', 1, 0), -- Máy quét mã vạch 2: (GIẢ LẬP LỖI) IT quên bật mã hóa -> Không an toàn.
('DEV-MB-05', 'SAM-777777C', 'Android', '13.0', 0, 0); -- Tablet: (GIẢ LẬP LỖI) Máy cá nhân BYOD, chưa cấu hình.

-- ------------------------------------------------------------------------------
-- 11. INSERT DATA: DEVICE_SERVER_APPROVAL (LỊCH SỬ DUYỆT TRUY CẬP TƯỜNG LỬA)
-- ------------------------------------------------------------------------------
-- Cấp phép cho Macbook của Giám đốc (DEV-MB-01) truy cập kho dữ liệu
INSERT INTO DEVICE_SERVER_APPROVAL (device_id, server_id, approval_date, revoked_date) VALUES
('DEV-MB-01', 'SRV-V-002', '2025-01-10', NULL);

-- Cấp phép Máy tính bàn kho A (DEV-PC-01) kết nối App WMS
INSERT INTO DEVICE_SERVER_APPROVAL (device_id, server_id, approval_date, revoked_date) VALUES
('DEV-PC-01', 'SRV-V-001', '2024-01-15', NULL);

-- Laptop của IT (DEV-MB-02) xin vào Core Router -> Từng được cấp, nhưng sau đó có đợt rà soát nên bị thu hồi
INSERT INTO DEVICE_SERVER_APPROVAL (device_id, server_id, approval_date, revoked_date) VALUES
('DEV-MB-02', 'SRV-P-001', '2025-02-15', '2025-12-31');

-- (GIẢ LẬP LƯU VẾT NHIỀU LẦN): Xin cấp lại cho Laptop IT vào Core Router vào đầu năm nay -> OK (Tạo thành dòng lịch sử số 2)
INSERT INTO DEVICE_SERVER_APPROVAL (device_id, server_id, approval_date, revoked_date) VALUES
('DEV-MB-02', 'SRV-P-001', '2026-01-05', NULL);

-- Máy quét mã vạch 1 (DEV-MB-03) kết nối Edge Server -> OK
INSERT INTO DEVICE_SERVER_APPROVAL (device_id, server_id, approval_date, revoked_date) VALUES
('DEV-MB-03', 'SRV-V-004', '2025-05-21', NULL);
