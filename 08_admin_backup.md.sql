-- 1. Thiết kế phân quyền tối thiểu (Least-Privilege Design) 
-- Tạo tài khoản chuyên trách chỉ làm nhiệm vụ giám sát an ninh mạng (Security Auditor) 
CREATE USER 'skylog_sec_auditor'@'localhost' IDENTIFIED BY 'AuditSecurePass2026!'; 
 
-- Chỉ cấp quyền xem thông tin thiết bị di động và lịch sử cấp phép kết nối mạng 
GRANT SELECT ON SkyLog_SmartWarehouse.MOBILE_DEVICE TO 'skylog_sec_auditor'@'localhost'; 
GRANT SELECT, UPDATE ON SkyLog_SmartWarehouse.DEVICE_SERVER_APPROVAL TO 'skylog_sec_auditor'@'localhost'; 
FLUSH PRIVILEGES; 
 
-- 2. Kế hoạch Sao lưu và Phục hồi dữ liệu (Backup & Restore Plan) 
-- Lệnh thực thi trên Terminal/Command Prompt của hệ điều hành (Lab-environment) 
-- Sao lưu toàn bộ Database ra file script: 
-- mysqldump -u root -p SkyLog_SmartWarehouse > /backups/skylog_backup_20260705.sql 
-- Phục hồi dữ liệu từ file backup vào database rỗng: 
-- mysql -u root -p SkyLog_SmartWarehouse < /backups/skylog_backup_20260705.sql