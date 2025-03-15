# Quản Lý Khách Sạn - HỆ Quản Lý Cơ Sở Dữ Liệu (DBMS)

## Giới Thiệu
Dự án **Quản lý Khách sạn** là một hệ thống giúp quản lý các hoạt động của khách sạn như đặt phòng, quản lý khách hàng, dịch vụ, thanh toán và báo cáo. Hệ thống được xây dựng dựa trên cơ sở dữ liệu quan hệ và sử dụng SQL để truy vấn dữ liệu.

## Tính Năng Chính
- Quản lý khách hàng: Thêm, sửa, xóa, tìm kiếm thông tin khách hàng.
- Quản lý đặt phòng: Đặt phòng, cập nhật trạng thái, hủy đặt phòng.
- Quản lý phòng: Danh sách phòng, loại phòng, giá cả.
- Quản lý dịch vụ: Danh mục dịch vụ, giá cả, thanh toán dịch vụ.
- Báo cáo: Thống kê doanh thu, công suất phòng.

## Công Nghệ Sử Dụng
- **Ngôn ngữ lập trình**: SQL 
- **Framework**: SQL Server Management Studio

## Hướng Dẫn Cài Đặt
1. Cài đặt MySQL/PostgreSQL.
2. Tạo cơ sở dữ liệu và nhập các bảng từ file `database.sql`.
3. Chạy ứng dụng bằng Python/PHP/Java.
4. Truy cập giao diện quản lý qua trình duyệt.

## Cấu Trúc Cơ Sở Dữ Liệu
```
- Customers (CustomerID, FullName, Phone, Email, Address, DateOfBirth, Gender)
- Rooms (RoomID, RoomType, RoomNumber, Price, Status)
- Bookings (BookingID, CustomerID, RoomID, CheckInDate, CheckOutDate, GuestCount Status, CreatedAt)
- Services (ServiceID, ServiceName, Price)
- Payments (PaymentID, BookingID, amount, PaymentMethod, PaymentDay)
- Employees (EmployeeID, FullName, Role, Salary, HireDate, Shift)
- InvoiceDetails (InvoiceDetailID, PaymentID, ServiceID)
- RoomHistory (HistoryID, RoomID, BookingID, Status, UpdateAt)
```

## Liên Hệ
Nếu bạn có bất kỳ câu hỏi nào, vui lòng liên hệ qua email: `hungh1255h@gmail.com`.
