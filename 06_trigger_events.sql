DELIMITER //

CREATE TRIGGER trg_Enforce_Virtualization_Architecture
BEFORE INSERT ON VIRTUAL_SERVER
FOR EACH ROW
BEGIN
    DECLARE v_host_type VARCHAR(20);
    
    -- Truy vấn ngược lại bảng cha (SERVER) để dò xem cái host_physical_id người dùng truyền vào có bản chất là gì
    SELECT server_type INTO v_host_type
    FROM SERVER
    WHERE server_id = NEW.host_physical_id;
    
    -- Nếu Host_ID này lại bị phát hiện là VIRTUAL -> Vi phạm kiến trúc hạ tầng
    IF v_host_type = 'VIRTUAL' THEN
        -- Báo tín hiệu Lỗi Custom (SQLSTATE 45000), tống cổ dòng lệnh, hủy Insert
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = '[LỖI KIẾN TRÚC IT] Một máy chủ ảo không thể làm Host nền tảng cho máy chủ ảo khác. Hãy chỉ định Host là một Máy Chủ Vật Lý thật!';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER trg_Enforce_Zero_Trust_Security
BEFORE INSERT ON DEVICE_SERVER_APPROVAL
FOR EACH ROW
BEGIN
    DECLARE v_dev_type VARCHAR(50);
    DECLARE v_is_secure BOOLEAN;
    
    -- Bước 1: Tra cứu xem thiết bị đang xin cấp quyền là PC Cố định hay Mobile?
    SELECT device_type INTO v_dev_type
    FROM DEVICE WHERE device_id = NEW.device_id;
    
    -- Bước 2: Chỉ áp dụng luật kiểm duyệt khắt khe này nếu nó là thiết bị Mobile hay di chuyển
    IF v_dev_type = 'MOBILE_DEVICE' THEN
        -- Truy xuất cờ bảo mật (đã được tự động chấm điểm ở Computed Column)
        SELECT security_eligible INTO v_is_secure
        FROM MOBILE_DEVICE WHERE device_id = NEW.device_id;
        
        -- Bước 3: Đưa ra phán quyết
        -- Nếu cột computed column báo 0 (FALSE - tức là thiếu Khóa MH hoặc thiếu Mã hóa DL)
        IF v_is_secure = 0 THEN
            -- Giương cờ đỏ chặn lại
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = '[CẢNH BÁO AN NINH ZERO-TRUST] Thiết bị di động này vi phạm tiêu chuẩn bảo mật. Yêu cầu thiết lập Khóa màn hình VÀ Mã hóa dữ liệu trước khi xin cấp quyền!';
        END IF;
    END IF;
END //

DELIMITER ;

-- Mục đích nghiệp vụ: Định kỳ dọn dẹp các phiên kết nối mạng đã bị thu hồi (revoked) quá 1 năm để giảm tải không gian lưu trữ cho bảng DEVICE_SERVER_APPROVAL.
CREATE EVENT IF NOT EXISTS ev_cleanup_expired_approvals
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
ON COMPLETION PRESERVE
DISABLE 
-- Bắt buộc để trạng thái DISABLE trong môi trường Lab theo đúng quy định an toàn
DO
  DELETE FROM DEVICE_SERVER_APPROVAL
  WHERE revoked_date < CURRENT_DATE - INTERVAL 1 YEAR;