-- 8.5. Kiểm thử các khung nhìn quản trị (Test View Select) 
SELECT * FROM vw_Physical_Server_Load_Report; 
SELECT * FROM vw_Insecure_Mobile_Devices; 
--  8.6. Kiểm thử Stored Function (Trường hợp Success) 
SELECT emp_id, first_name, fn_Get_Employee_Device_Count(emp_id) AS 'Số thiết bị nắm giữ'  
FROM EMPLOYEE WHERE emp_id = 'E0005'; 
-- 8.7. Kiểm thử Stored Procedure (Trường hợp FAILURE - Negative Testing) 
-- Kịch bản: Cố tình cấp quyền cho một nhân viên không tồn tại trong hệ thống ('E999')  
-- để kiểm tra tính năng ROLLBACK của Transaction Handler. 
CALL sp_Grant_Access_With_Auto_Account('E999', 'SVC-WMS-01', 'FailPass123!'); 
-- Expected Result: Hệ thống chặn đứng, trả về lỗi Custom SQLSTATE '45000'  
-- với thông báo: "Giao dịch thất bại do lỗi dữ liệu. Đã hủy bỏ thao tác cấp quyền."