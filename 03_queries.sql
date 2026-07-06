--  Thống kê số lượng thiết bị theo từng phòng ban
SELECT 
    dp.dept_name AS 'Phòng Ban',
    COUNT(d.device_id) AS 'Tổng số thiết bị',
    SUM(CASE WHEN d.device_type = 'FIXED_WORKSTATION' THEN 1 ELSE 0 END) AS 'PC Cố Định',
    SUM(CASE WHEN d.device_type = 'MOBILE_DEVICE' THEN 1 ELSE 0 END) AS 'Thiết bị Di Động'
FROM DEPARTMENT dp
LEFT JOIN EMPLOYEE e ON dp.dept_code = e.dept_code
LEFT JOIN DEVICE d ON e.emp_id = d.emp_id
GROUP BY dp.dept_code, dp.dept_name
ORDER BY COUNT(d.device_id) DESC;


--  Danh sách các thiết bị đang mở firewall vào Máy chủ Ảo (Trạng thái Active)
SELECT 
    dsa.approval_id AS 'Ticket No.',
    s.server_name AS 'Máy Chủ Đích',
    s.ip_address AS 'IP Mạng',
    d.device_id AS 'Thiết Bị Nguồn',
    e.last_name AS 'Chủ Sở Hữu',
    dsa.approval_date AS 'Ngày Mở Firewall',
    DATEDIFF(CURDATE(), dsa.approval_date) AS 'Số Ngày Đang Mở (Days)'
FROM DEVICE_SERVER_APPROVAL dsa
JOIN SERVER s ON dsa.server_id = s.server_id
JOIN DEVICE d ON dsa.device_id = d.device_id
JOIN EMPLOYEE e ON d.emp_id = e.emp_id
WHERE s.server_type = 'VIRTUAL' 
  AND dsa.revoked_date IS NULL  -- Lọc trạng thái Active
ORDER BY dsa.approval_date ASC;


--  Top 3 nhân viên sở hữu nhiều thiết bị di động nhất
SELECT 
    e.emp_id AS 'Mã NV', 
    CONCAT(e.last_name, ' ', e.first_name) AS 'Nhân Viên',  
    COUNT(d.device_id) AS 'Số Lượng Thiết Bị' 
FROM EMPLOYEE e 
JOIN DEVICE d ON e.emp_id = d.emp_id 
WHERE d.device_type = 'MOBILE_DEVICE' 
GROUP BY e.emp_id, e.last_name, e.first_name 
ORDER BY COUNT(d.device_id) DESC 
LIMIT 3; 
 

--  Liệt kê các dịch vụ phần mềm đang vận hành trên các Máy chủ Ảo (Virtual Server)  
-- thuộc quyền quản lý của Máy chủ Vật lý cụ thể có ID 'SRV-P-002' 
SELECT 
    svc.service_code AS 'Mã Dịch Vụ', 
    svc.service_name AS 'Tên Dịch Vụ',  
    s.server_name AS 'Chạy Trên VM', 
    p.server_id AS 'Host Vật Lý' 
FROM SERVICE svc 
JOIN SERVER s ON svc.server_id = s.server_id 
JOIN VIRTUAL_SERVER v ON s.server_id = v.server_id 
JOIN PHYSICAL_SERVER p ON v.host_physical_id = p.server_id 
WHERE p.server_id = 'SRV-P-002'; 
 

--  Thống kê số lượng nhân sự được cấp quyền truy cập theo từng dịch vụ ứng dụng 
SELECT 
    svc.service_code AS 'Mã Dịch Vụ', 
    svc.service_name AS 'Tên Ứng Dụng',  
    COUNT(sa.emp_id) AS 'Số Người Được Dùng' 
FROM SERVICE svc 
LEFT JOIN SERVICE_ACCESS sa ON svc.service_code = sa.service_code 
GROUP BY svc.service_code, svc.service_name 
ORDER BY COUNT(sa.emp_id) DESC; 
 

--  Phát hiện các nhân viên chưa từng được cấp tài khoản SSO hệ thống (Phục vụ rà soát HR) 
SELECT 
    e.emp_id AS 'Mã NV', 
    CONCAT(e.last_name, ' ', e.first_name) AS 'Nhân Viên',  
    e.job_title AS 'Chức Danh', 
    d.dept_name AS 'Phòng Ban' 
FROM EMPLOYEE e 
JOIN DEPARTMENT d ON e.dept_code = d.dept_code 
LEFT JOIN ACCOUNT a ON e.emp_id = a.emp_id 
WHERE a.username IS NULL; 
 

--  Đếm tổng số lượt phê duyệt tường lửa đang còn hiệu lực (Active) cho từng máy chủ
SELECT 
    s.server_id AS 'Mã Server', 
    s.server_name AS 'Tên Máy Chủ', 
    s.ip_address AS 'IP', 
    COUNT(dsa.approval_id) AS 'Số Kết Nối Hiện Hành' 
FROM SERVER s 
LEFT JOIN DEVICE_SERVER_APPROVAL dsa ON s.server_id = dsa.server_id AND dsa.revoked_date IS NULL 
GROUP BY s.server_id, s.server_name, s.ip_address 
ORDER BY COUNT(dsa.approval_id) DESC; 


--  Thống kê danh sách các máy chủ chưa triển khai bất kỳ dịch vụ phần mềm nội bộ nào 
SELECT 
    s.server_id AS 'Mã Server', 
    s.server_name AS 'Tên Máy Chủ', 
    s.server_type AS 'Loại Máy Chủ' 
FROM SERVER s 
LEFT JOIN SERVICE svc ON s.server_id = svc.server_id 
WHERE svc.service_code IS NULL;