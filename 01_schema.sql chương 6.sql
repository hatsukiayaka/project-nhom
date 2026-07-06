-- PROJECT: SKYLOG SMART WAREHOUSE NETWORK DATABASE
-- DESCRIPTION: SCRIPT KHỞI TẠO CẤU TRÚC BẢNG (DDL) VỚI ĐẦY ĐỦ RÀNG BUỘC
-- ==============================================================================

-- 1. Xóa cơ sở dữ liệu cũ (nếu có) để tránh xung đột dữ liệu trong lúc Build
DROP DATABASE IF EXISTS SkyLog_SmartWarehouse;

-- 2. Tạo CSDL mới với cấu hình Character Set chuẩn Quốc tế
CREATE DATABASE SkyLog_SmartWarehouse
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- 3. Chọn CSDL để làm việc
USE SkyLog_SmartWarehouse;

-- ==============================================================================
-- MODULE 1: ORGANIZATION & IDENTITY (CỤM TỔ CHỨC VÀ ĐỊNH DANH)
-- Bắt đầu tạo từ các bảng Độc lập (Không chứa Khóa ngoại)
-- ==============================================================================

-- BẢNG 1: QUẢN LÝ PHÒNG BAN
CREATE TABLE DEPARTMENT (
    dept_code VARCHAR(10) PRIMARY KEY COMMENT 'Mã phòng ban (VD: IT_DEP)',
    dept_name VARCHAR(100) NOT NULL COMMENT 'Tên phòng ban',
    internal_mailbox VARCHAR(20) NOT NULL COMMENT 'Mã hòm thư tài liệu nội bộ',
    phone_number VARCHAR(20) NOT NULL COMMENT 'Số điện thoại liên lạc bộ phận',
    -- Đảm bảo không có 2 phòng ban nào được đặt trùng tên
    CONSTRAINT uq_dept_name UNIQUE (dept_name)
) ENGINE=InnoDB;

-- BẢNG 2: QUẢN LÝ HỒ SƠ NHÂN VIÊN
CREATE TABLE EMPLOYEE (
    emp_id VARCHAR(10) PRIMARY KEY COMMENT 'Mã nhân viên công ty',
    last_name VARCHAR(50) NOT NULL COMMENT 'Họ',
    middle_initial VARCHAR(50) NULL COMMENT 'Tên đệm (Tùy chọn)',
    first_name VARCHAR(50) NOT NULL COMMENT 'Tên chính',
    job_title VARCHAR(100) NOT NULL COMMENT 'Chức danh hiện tại',
    dept_code VARCHAR(10) NOT NULL COMMENT 'Khóa ngoại trỏ về phòng ban',
    
    -- THIẾT LẬP RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY CONSTRAINT)
    CONSTRAINT fk_emp_dept FOREIGN KEY (dept_code) 
        REFERENCES DEPARTMENT(dept_code) 
        -- Nếu Mã phòng ban đổi, tự động cập nhật mã mới cho NV (CASCADE)
        ON UPDATE CASCADE 
        -- Ngăn cấm xóa phòng ban nếu vẫn còn nhân sự bên trong (RESTRICT)
        ON DELETE RESTRICT
) ENGINE=InnoDB;

-- BẢNG 3: QUẢN LÝ TÀI KHOẢN SINGLE SIGN-ON
CREATE TABLE ACCOUNT (
    emp_id VARCHAR(10) PRIMARY KEY COMMENT 'Khóa chính kiêm Khóa ngoại (1:1)',
    username VARCHAR(50) NOT NULL COMMENT 'Tên đăng nhập hệ thống',
    password_hash VARCHAR(255) NOT NULL COMMENT 'Chuỗi mã hóa băm mật khẩu',
    
    CONSTRAINT uq_username UNIQUE (username),
    CONSTRAINT fk_acc_emp FOREIGN KEY (emp_id) 
        REFERENCES EMPLOYEE(emp_id) 
        -- Nếu tài khoản nhân viên bị xóa khỏi cty, tài khoản Login tự động bay màu
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==============================================================================
-- MODULE 2: INFRASTRUCTURE & VIRTUALIZATION (HẠ TẦNG MÁY CHỦ & ẢO HÓA)
-- Cụm kiến trúc phức tạp Supertype/Subtype
-- ==============================================================================

-- BẢNG 4: PHÒNG ĐẶT MÁY CHỦ
CREATE TABLE COMPUTER_ROOM (
    room_id VARCHAR(10) PRIMARY KEY COMMENT 'Mã định vị vật lý phòng máy',
    room_name VARCHAR(100) NOT NULL COMMENT 'Tên khu vực data center'
) ENGINE=InnoDB;

-- BẢNG 5: MÁY CHỦ TỔNG QUÁT (SUPERTYPE)
CREATE TABLE SERVER (
    server_id VARCHAR(10) PRIMARY KEY COMMENT 'Mã server quản lý IT',
    server_name VARCHAR(100) NOT NULL COMMENT 'Tên Hostname mạng',
    vendor VARCHAR(100) NOT NULL COMMENT 'Nhà sản xuất/phân phối',
    ip_address VARCHAR(45) NOT NULL COMMENT 'IP tĩnh của máy',
    os VARCHAR(100) NOT NULL COMMENT 'Hệ điều hành',
    -- Cột phân loại (Discriminator)
    server_type ENUM('PHYSICAL', 'VIRTUAL') NOT NULL COMMENT 'Phân loại Vật lý/Ảo',
    room_id VARCHAR(10) NOT NULL COMMENT 'Vị trí phòng máy',
    
    CONSTRAINT uq_server_name UNIQUE (server_name),
    CONSTRAINT uq_server_ip UNIQUE (ip_address),
    CONSTRAINT fk_srv_room FOREIGN KEY (room_id) 
        REFERENCES COMPUTER_ROOM(room_id)
) ENGINE=InnoDB;

-- BẢNG 6: MÁY CHỦ VẬT LÝ BARE-METAL (SUBTYPE)
CREATE TABLE PHYSICAL_SERVER (
    server_id VARCHAR(10) PRIMARY KEY COMMENT 'Tham chiếu 1-1 Server_ID',
    CONSTRAINT fk_phys_srv FOREIGN KEY (server_id) 
        REFERENCES SERVER(server_id) 
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- BẢNG 7: MÁY CHỦ ẢO HÓA (SUBTYPE)
CREATE TABLE VIRTUAL_SERVER (
    server_id VARCHAR(10) PRIMARY KEY COMMENT 'Tham chiếu 1-1 Server_ID',
    -- RÀNG BUỘC ĐỈNH CAO: TRỎ VỀ MÁY VẬT LÝ
    host_physical_id VARCHAR(10) NOT NULL COMMENT 'ID của máy chủ vật lý đang cõng máy ảo này',
    
    CONSTRAINT fk_virt_srv FOREIGN KEY (server_id) 
        REFERENCES SERVER(server_id) 
        ON DELETE CASCADE,
    CONSTRAINT fk_virt_host FOREIGN KEY (host_physical_id) 
        REFERENCES PHYSICAL_SERVER(server_id) 
        -- Rất quan trọng: Ngăn không cho IT xóa máy chủ vật lý nếu bên trong nó vẫn đang cắm các máy ảo chạy nghiệp vụ
        ON DELETE RESTRICT 
) ENGINE=InnoDB;

-- BẢNG 8: DỊCH VỤ PHẦN MỀM
CREATE TABLE SERVICE (
    service_code VARCHAR(10) PRIMARY KEY COMMENT 'Mã dịch vụ/ứng dụng',
    service_name VARCHAR(100) NOT NULL COMMENT 'Tên phần mềm quản trị',
    start_date DATE NOT NULL COMMENT 'Ngày Go-Live',
    server_id VARCHAR(10) NOT NULL COMMENT 'Server chịu trách nhiệm chạy dịch vụ',
    
    CONSTRAINT fk_svc_srv FOREIGN KEY (server_id) 
        REFERENCES SERVER(server_id)
) ENGINE=InnoDB;

-- BẢNG 9: LỊCH SỬ PHÂN QUYỀN SỬ DỤNG DỊCH VỤ (ASSOCIATIVE ENTITY)
CREATE TABLE SERVICE_ACCESS (
    emp_id VARCHAR(10),
    service_code VARCHAR(10),
    granted_date DATE NOT NULL COMMENT 'Ngày nhân sự nhận quyền',
    
    -- Khóa chính phức hợp
    PRIMARY KEY (emp_id, service_code),
    
    CONSTRAINT fk_accs_emp FOREIGN KEY (emp_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE CASCADE,
    CONSTRAINT fk_accs_svc FOREIGN KEY (service_code) 
        REFERENCES SERVICE(service_code) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ==============================================================================
-- MODULE 3: IT ASSET MANAGEMENT & SECURITY (QUẢN LÝ TÀI SẢN & BẢO MẬT)
-- ==============================================================================

-- BẢNG 10: THIẾT BỊ TỔNG QUÁT (SUPERTYPE)
CREATE TABLE DEVICE (
    device_id VARCHAR(10) PRIMARY KEY COMMENT 'Mã tài sản dán trên máy',
    brand VARCHAR(100) NOT NULL COMMENT 'Thương hiệu',
    model VARCHAR(100) NOT NULL COMMENT 'Model máy',
    registration_date DATE NOT NULL COMMENT 'Ngày ghi nhận vào hệ thống',
    device_type ENUM('FIXED_WORKSTATION', 'MOBILE_DEVICE') NOT NULL COMMENT 'Phân loại thiết bị',
    emp_id VARCHAR(10) NOT NULL COMMENT 'Nhân viên sở hữu',
    
    CONSTRAINT fk_dev_emp FOREIGN KEY (emp_id) 
        REFERENCES EMPLOYEE(emp_id)
) ENGINE=InnoDB;

-- BẢNG 11: THIẾT BỊ CỐ ĐỊNH (SUBTYPE)
CREATE TABLE FIXED_WORKSTATION (
    device_id VARCHAR(10) PRIMARY KEY COMMENT 'Tham chiếu 1-1 Device_ID',
    static_ip_address VARCHAR(45) NOT NULL COMMENT 'IP tĩnh thiết lập trên mạng',
    mac_address VARCHAR(50) NOT NULL COMMENT 'Địa chỉ MAC Card mạng',
    building_name VARCHAR(100) NOT NULL COMMENT 'Tên khu xưởng / Tòa nhà',
    room_number VARCHAR(50) NOT NULL COMMENT 'Vị trí zone đặt máy trạm',
    
    CONSTRAINT uq_fixed_ip UNIQUE (static_ip_address),
    CONSTRAINT uq_fixed_mac UNIQUE (mac_address),
    CONSTRAINT fk_fixed_dev FOREIGN KEY (device_id) 
        REFERENCES DEVICE(device_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- BẢNG 12: THIẾT BỊ DI ĐỘNG KÈM THEO DÕI AN NINH (SUBTYPE)
CREATE TABLE MOBILE_DEVICE (
    device_id VARCHAR(10) PRIMARY KEY COMMENT 'Tham chiếu 1-1 Device_ID',
    serial_number VARCHAR(100) NOT NULL COMMENT 'S/N chống giả mạo',
    operating_system VARCHAR(50) NOT NULL COMMENT 'HĐH: iOS, Android, Win...',
    os_version VARCHAR(50) NOT NULL COMMENT 'Phiên bản HĐH',
    screen_lock_enabled BOOLEAN NOT NULL DEFAULT 0 COMMENT '0:Tắt, 1:Bật Khóa MH',
    data_encryption_enabled BOOLEAN NOT NULL DEFAULT 0 COMMENT '0:Tắt, 1:Bật Mã hóa',
    
    -- TÍNH NĂNG COMPUTED COLUMN CỦA MYSQL: Tự động chấm điểm bảo mật
    security_eligible BOOLEAN GENERATED ALWAYS AS (
        screen_lock_enabled = 1 AND data_encryption_enabled = 1
    ) STORED COMMENT 'Tự tính 1 nếu an toàn, 0 nếu ko an toàn',
    
    CONSTRAINT uq_mob_serial UNIQUE (serial_number),
    CONSTRAINT fk_mob_dev FOREIGN KEY (device_id) 
        REFERENCES DEVICE(device_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- BẢNG 13: LỊCH SỬ PHÊ DUYỆT TRUY CẬP FIREWALL (ASSOCIATIVE ENTITY)
CREATE TABLE DEVICE_SERVER_APPROVAL (
    approval_id INT AUTO_INCREMENT PRIMARY KEY COMMENT 'Khóa thay thế (Surrogate)',
    device_id VARCHAR(10) NOT NULL COMMENT 'ID thiết bị',
    server_id VARCHAR(10) NOT NULL COMMENT 'ID máy chủ cần kết nối',
    approval_date DATE NOT NULL COMMENT 'Ngày cấp quyền',
    revoked_date DATE NULL COMMENT 'Ngày thu hồi. NULL = Đang hoạt động',
    
    CONSTRAINT fk_appr_dev FOREIGN KEY (device_id) 
        REFERENCES DEVICE(device_id) ON DELETE CASCADE,
    CONSTRAINT fk_appr_srv FOREIGN KEY (server_id) 
        REFERENCES SERVER(server_id) ON DELETE CASCADE,
        
    -- RÀNG BUỘC MIỀN GIÁ TRỊ (DOMAIN CONSTRAINT) LOGIC THỜI GIAN
    CONSTRAINT chk_revoked_logic CHECK (
        revoked_date IS NULL OR revoked_date >= approval_date
    )
) ENGINE=InnoDB;

-- ==============================================================================
-- TỐI ƯU HIỆU NĂNG (INDEX OPTIMIZATION)
-- Tạo B-Tree Indexes cho các trường thường xuyên bị truy vấn JOIN và WHERE
-- ==============================================================================
CREATE INDEX idx_emp_name ON EMPLOYEE(last_name, first_name);
CREATE INDEX idx_approval_status ON DEVICE_SERVER_APPROVAL(device_id, revoked_date);