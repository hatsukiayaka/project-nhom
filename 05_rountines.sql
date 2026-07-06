DELIMITER //

CREATE PROCEDURE sp_Grant_Access_With_Auto_Account(
    IN p_emp_id VARCHAR(10),
    IN p_service_code VARCHAR(10),
    IN p_default_password VARCHAR(50)
)
BEGIN
    DECLARE v_has_account INT DEFAULT 0;
    
    -- Khai báo Handler bắt lỗi (Bảo toàn dữ liệu bằng kỹ thuật ROLLBACK)
    -- Nếu một trong các bước thất bại, trả database về trạng thái ban đầu
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Giao dịch thất bại do lỗi dữ liệu. Đã hủy bỏ thao tác cấp quyền.';
    END;

    -- Bắt đầu giao dịch an toàn (Transaction)
    START TRANSACTION;

    -- BƯỚC 1: Kiểm tra xem nhân viên đã có tài khoản SSO chưa?
    SELECT COUNT(*) INTO v_has_account 
    FROM ACCOUNT 
    WHERE emp_id = p_emp_id;

    -- BƯỚC 2: Nếu chưa có (Count = 0), tiến hành cấp phát tài khoản tự động (Auto-Provision)
    IF v_has_account = 0 THEN
        INSERT INTO ACCOUNT (emp_id, username, password_hash)
        VALUES (
            p_emp_id,
            -- Tự động sinh username theo quy tắc: usr_ + mã NV (VD: usr_e005)
            CONCAT('usr_', LOWER(p_emp_id)), 
            -- Tuyệt đối an toàn: Gọi hàm băm mật khẩu nội tại của MySQL bằng thuật toán SHA-256
            SHA2(p_default_password, 256)    
        );
    END IF;

    -- BƯỚC 3: Tiến hành cấp quyền vào dịch vụ vào bảng trung gian
    INSERT INTO SERVICE_ACCESS (emp_id, service_code, granted_date)
    VALUES (p_emp_id, p_service_code, CURDATE());

    -- Chốt giao dịch: Ghi toàn bộ dữ liệu mới xuống ổ cứng vĩnh viễn
    COMMIT;
END //

DELIMITER ;DELIMITER //

CREATE PROCEDURE sp_Emergency_Revoke_Device(
    IN p_device_id VARCHAR(10)
)
BEGIN
    UPDATE DEVICE_SERVER_APPROVAL
    SET revoked_date = CURDATE()
    WHERE device_id = p_device_id 
      AND revoked_date IS NULL; -- Chỉ ngắt các kết nối nào đang có hiệu lực
END //

DELIMITER ;

DELIMITER // 
CREATE FUNCTION fn_Get_Employee_Device_Count(p_emp_id VARCHAR(10)) 
RETURNS INT 
DETERMINISTIC 
BEGIN 
	DECLARE v_count INT DEFAULT 0; 
	SELECT COUNT(*) INTO v_count FROM DEVICE WHERE emp_id = p_emp_id; 
	RETURN v_count; 
END // 
DELIMITER ;