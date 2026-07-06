CREATE VIEW vw_Physical_Server_Load_Report AS
SELECT 
    ps.server_id AS 'Mã Máy Vật Lý',
    s.server_name AS 'Tên Máy Chủ',
    s.ip_address AS 'Địa Chỉ IP Mạng',
    cr.room_name AS 'Vị Trí Phòng Máy Đặt',
    COUNT(vs.server_id) AS 'Số lượng Máy Ảo đang Host'
FROM PHYSICAL_SERVER ps
JOIN SERVER s ON ps.server_id = s.server_id
JOIN COMPUTER_ROOM cr ON s.room_id = cr.room_id
LEFT JOIN VIRTUAL_SERVER vs ON ps.server_id = vs.host_physical_id
GROUP BY ps.server_id, s.server_name, s.ip_address, cr.room_name
ORDER BY COUNT(vs.server_id) DESC;

CREATE VIEW vw_Insecure_Mobile_Devices AS
SELECT 
    d.device_id AS 'Mã Thiết Bị',
    d.model AS 'Dòng Máy',
    md.operating_system AS 'Hệ Điều Hành',
    md.screen_lock_enabled AS 'Khóa Màn Hình (0=Lỗi)',
    md.data_encryption_enabled AS 'Mã Hóa Dữ Liệu (0=Lỗi)',
    e.emp_id AS 'Mã Cán Bộ',
    CONCAT(e.last_name, ' ', IFNULL(e.middle_initial, ''), ' ', e.first_name) AS 'Chủ Sở Hữu',
    dp.dept_name AS 'Thuộc Phòng Ban'
FROM MOBILE_DEVICE md
JOIN DEVICE d ON md.device_id = d.device_id
JOIN EMPLOYEE e ON d.emp_id = e.emp_id
JOIN DEPARTMENT dp ON e.dept_code = dp.dept_code
WHERE md.security_eligible = 0;