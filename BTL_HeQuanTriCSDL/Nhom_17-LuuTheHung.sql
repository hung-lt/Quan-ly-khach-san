-- Tạo cơ sở dữ liệu
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'HotelManagement')
BEGIN
    CREATE DATABASE HotelManagement;
    PRINT 'Database HotelManagement đã được tạo.';
END
ELSE
BEGIN
    PRINT 'Database HotelManagement đã tồn tại.';
END
GO

USE HotelManagement;
GO

--Tự động tìm và xóa tất cả ràng buộc khóa ngoại
DECLARE @sql NVARCHAR(MAX) = '';
-- Tạo lệnh xóa ràng buộc khóa ngoại cho từng bảng
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_NAME(parent_object_id)) + 
               ' DROP CONSTRAINT ' + QUOTENAME(name) + ';' + CHAR(13)
FROM sys.foreign_keys;
-- Thực thi lệnh xóa tất cả khóa ngoại
EXEC sp_executesql @sql;


-- Xóa bảng nếu đã tồn tại
DROP TABLE IF EXISTS InvoiceDetails, Payments, Employees, RoomHistory, Bookings, Services, Rooms, Customers;
GO

-- Tạo các bảng
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Phone NVARCHAR(15) UNIQUE NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    Address NVARCHAR(255),
    DateOfBirth DATE,
    Gender NCHAR(1) CHECK (Gender IN (N'M', N'F', N'O'))
);
GO

CREATE TABLE Rooms (
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomNumber NVARCHAR(10) UNIQUE NOT NULL,
    RoomType NVARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    Status NVARCHAR(20) DEFAULT N'Available'
);
GO

CREATE TABLE Services (
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0)
);
GO

CREATE TABLE Bookings (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    RoomID INT NOT NULL,
    CheckInDate DATETIME NOT NULL,
    CheckOutDate DATETIME NOT NULL,
    GuestCount INT NOT NULL CHECK (GuestCount > 0),
    Status NVARCHAR(20) DEFAULT N'Pending' CHECK (Status IN (N'Pending', N'Checked-In', N'Checked-Out', N'Cancelled')),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) ON DELETE CASCADE
);
GO

CREATE TABLE RoomHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    RoomID INT NOT NULL,
    BookingID INT NULL,
    Status NVARCHAR(50) NOT NULL,
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID) ON DELETE CASCADE,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE NO ACTION
);
GO

CREATE TABLE Employees (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) CHECK (Salary > 0),
    HireDate DATE DEFAULT GETDATE(),
    Shift NVARCHAR(20)
);
GO

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentMethod NVARCHAR(50) CHECK (PaymentMethod IN (N'Cash', N'Credit Card', N'Debit Card', N'Online')),
    PaymentDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID) ON DELETE CASCADE
);
GO

CREATE TABLE InvoiceDetails (
    InvoiceDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PaymentID INT NOT NULL,
    ServiceID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    TotalPrice AS (Quantity * UnitPrice),
    FOREIGN KEY (PaymentID) REFERENCES Payments(PaymentID) ON DELETE CASCADE,
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID) ON DELETE CASCADE
);
GO

-- Thêm dữ liệu mẫu
INSERT INTO Customers (FullName, Phone, Email, Address, DateOfBirth, Gender) VALUES
(N'Nguyễn Văn A', N'0987654321', N'nguyenvana@example.com', N'Hà Nội', '1990-05-12', N'M'),
(N'Trần Thị B', N'0976543210', N'tranthib@example.com', N'TP.HCM', '1995-09-23', N'F'),
(N'Lê Minh C', N'0912345678', N'leminhc@example.com', N'Đà Nẵng', '1985-03-15', N'M'),
(N'Phạm Thị D', N'0934567890', N'phamthid@example.com', N'Hải Phòng', '1992-11-30', N'F'),
(N'Hoàng Văn E', N'0901234567', N'hoangvane@example.com', N'Cần Thơ', '1988-07-25', N'M'),
(N'Vũ Thị F', N'0945678901', N'vuthif@example.com', N'Quảng Ninh', '1997-02-14', N'F'),
(N'Đặng Văn G', N'0967890123', N'dangvang@example.com', N'Nha Trang', '1993-08-09', N'M'),
(N'Bùi Thị H', N'0923456789', N'buithih@example.com', N'Huế', '1989-12-01', N'F'),
(N'Trương Văn I', N'0956789012', N'truongvani@example.com', N'Vũng Tàu', '1991-06-18', N'M'),
(N'Ngô Thị K', N'0998765432', N'ngothik@example.com', N'Bình Dương', '1994-04-22', N'F'),
(N'Lý Văn L', N'0887654321', N'lyvanl@example.com', N'Long An', '1987-10-05', N'M'),
(N'Mai Thị M', N'0876543219', N'maithim@example.com', N'Đồng Nai', '1996-01-17', N'F'),
(N'Đỗ Văn N', N'0865432198', N'dovann@example.com', N'Quy Nhơn', '1990-09-28', N'M');
GO

SELECT * FROM Customers;


INSERT INTO Rooms (RoomNumber, RoomType, Price, Status) VALUES
(N'101', N'Single', 500000, N'Available'),
(N'102', N'Double', 800000, N'Available'),
(N'201', N'Single', 550000, N'Available'),
(N'202', N'Double', 850000, N'Booked'),
(N'301', N'Suite', 1200000, N'Available'),
(N'302', N'Single', 600000, N'Occupied');
GO

SELECT * FROM Rooms;

INSERT INTO Services (ServiceName, Price) VALUES
(N'Bữa sáng', 100000),
(N'Giặt là', 50000),
(N'Dịch vụ phòng', 150000),
(N'Đưa đón sân bay', 300000),
(N'Massage', 250000);
GO

SELECT * FROM Services;

INSERT INTO Employees (FullName, Role, Salary, Shift) VALUES
(N'Nguyễn Văn H', N'Lễ tân', 8000000, N'Sáng'),
(N'Trần Thị I', N'Quản lý', 15000000, N'Chiều'),
(N'Lê Văn K', N'Bảo vệ', 6000000, N'Đêm'),
(N'Phạm Thị L', N'Buồng phòng', 7000000, N'Sáng'),
(N'Hoàng Văn M', N'Lễ tân', 8500000, N'Chiều');
GO

SELECT * FROM Employees;

INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, GuestCount, Status) VALUES
(1, 1, '2024-03-01 14:00:00', '2024-03-05 12:00:00', 1, N'Checked-In'),
(2, 2, '2024-03-02 15:00:00', '2024-03-06 11:00:00', 2, N'Checked-Out'),
(3, 3, '2024-03-04 13:00:00', '2024-03-07 10:00:00', 1, N'Pending'),
(4, 4, '2024-03-05 12:00:00', '2024-03-08 12:00:00', 3, N'Checked-In'),
(5, 5, '2024-03-06 16:00:00', '2024-03-09 11:00:00', 2, N'Cancelled');
GO

SELECT * FROM Bookings;


INSERT INTO Payments (BookingID, Amount, PaymentMethod, PaymentDate) VALUES
(1, 2000000, N'Credit Card', '2024-03-05 12:00:00'),
(2, 3200000, N'Cash', '2024-03-06 11:00:00'),
(3, 1800000, N'Online', '2024-03-07 10:00:00'),
(4, 2550000, N'Debit Card', '2024-03-08 12:00:00');
GO

SELECT * FROM Payments;

INSERT INTO InvoiceDetails (PaymentID, ServiceID, Quantity, UnitPrice) VALUES
(1, 1, 2, 100000), -- PaymentID = 1, ServiceID = 1 (Bữa sáng)
(2, 2, 3, 50000),  -- PaymentID = 2, ServiceID = 2 (Giặt là)
(3, 3, 1, 150000), -- PaymentID = 3, ServiceID = 3 (Dịch vụ phòng)
(4, 4, 1, 300000); -- PaymentID = 4, ServiceID = 4 (Đưa đón sân bay)
GO

SELECT * FROM InvoiceDetails;

INSERT INTO RoomHistory (RoomID, BookingID, Status, UpdatedAt) VALUES
(1, 1, N'Occupied', '2024-03-01 14:30:00'),
(2, 2, N'Cleaned', '2024-03-06 12:00:00'),
(3, 3, N'Pending', '2024-03-04 13:15:00'),
(4, 4, N'Occupied', '2024-03-05 12:20:00'),
(5, 5, N'Available', '2024-03-06 16:45:00');
GO

SELECT * FROM RoomHistory;


-- Tạo các chỉ mục
CREATE INDEX IX_Customers_Phone ON Customers(Phone);
CREATE INDEX IX_Rooms_RoomNumber ON Rooms(RoomNumber);
CREATE INDEX IX_Bookings_Status ON Bookings(Status);
CREATE INDEX IX_Payments_BookingID ON Payments(BookingID);
CREATE INDEX IX_InvoiceDetails_PaymentID ON InvoiceDetails(PaymentID);
CREATE INDEX IX_RoomHistory_BookingID ON RoomHistory(BookingID);
GO




-- Tạo các view

-- 1 Hiển thị danh sách các đặt phòng hiện tại
DROP VIEW IF EXISTS vw_CurrentBookings;
GO
CREATE VIEW vw_CurrentBookings AS
SELECT b.BookingID, c.FullName AS CustomerName, r.RoomNumber, b.CheckInDate, b.CheckOutDate, b.Status
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Rooms r ON b.RoomID = r.RoomID
WHERE b.Status IN (N'Pending', N'Checked-In');
GO

SELECT * FROM vw_CurrentBookings;


-- 2 Thống kê doanh thu từ các phòng
DROP VIEW IF EXISTS vw_RoomRevenue;
GO
CREATE VIEW vw_RoomRevenue AS
SELECT r.RoomNumber, r.RoomType, COUNT(b.BookingID) AS BookingCount, SUM(DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price) AS TotalRevenue
FROM Rooms r
LEFT JOIN Bookings b ON r.RoomID = b.RoomID
GROUP BY r.RoomNumber, r.RoomType;
GO

SELECT * FROM vw_RoomRevenue;


-- 3 Thống kê việc sử dụng dịch vụ
DROP VIEW IF EXISTS vw_ServiceUsage;
GO
CREATE VIEW vw_ServiceUsage AS
SELECT s.ServiceName, SUM(id.Quantity) AS TotalQuantity, SUM(id.TotalPrice) AS TotalServiceRevenue
FROM Services s
JOIN InvoiceDetails id ON s.ServiceID = id.ServiceID
GROUP BY s.ServiceName;
GO

SELECT * FROM vw_ServiceUsage;


-- 4 Hiển thị thông tin về nhân viên
DROP VIEW IF EXISTS vw_EmployeeShifts;
GO
CREATE VIEW vw_EmployeeShifts AS
SELECT EmployeeID, FullName, Role, Salary, Shift
FROM Employees;
GO

SELECT * FROM vw_EmployeeShifts;


-- 5 Hiển thị lịch sử sử dụng phòng trong vòng 1 tháng gần đây
DROP VIEW IF EXISTS vw_RecentRoomHistory;
GO
CREATE VIEW vw_RecentRoomHistory AS
SELECT rh.HistoryID, r.RoomNumber, b.BookingID, rh.Status, rh.UpdatedAt
FROM RoomHistory rh
JOIN Rooms r ON rh.RoomID = r.RoomID
JOIN Bookings b ON rh.BookingID = b.BookingID
WHERE rh.UpdatedAt >= DATEADD(MONTH, -1, GETDATE());
GO

SELECT * FROM vw_RecentRoomHistory;


-- 6 Hiển thị lịch sử đặt phòng
DROP VIEW IF EXISTS vw_CustomerBookingHistory;
GO
CREATE VIEW vw_CustomerBookingHistory AS
SELECT 
    c.CustomerID, 
    c.FullName AS CustomerName, 
    b.BookingID, 
    r.RoomNumber, 
    b.CheckInDate, 
    b.CheckOutDate, 
    b.Status
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Rooms r ON b.RoomID = r.RoomID;
GO

SELECT * FROM vw_CustomerBookingHistory;


-- 7 Thống kê các dịch vụ được sử dụng nhiều nhất
DROP VIEW IF EXISTS vw_TopServicesUsed;
GO
CREATE VIEW vw_TopServicesUsed AS
SELECT 
    s.ServiceID, 
    s.ServiceName, 
    COUNT(id.InvoiceDetailID) AS UsageCount, 
    SUM(id.TotalPrice) AS TotalRevenue
FROM InvoiceDetails id
JOIN Services s ON id.ServiceID = s.ServiceID
GROUP BY s.ServiceID, s.ServiceName
GO

SELECT * FROM vw_TopServicesUsed;


-- 8 Danh sách các phòng đặt chưa thanh toán đầy đủ
DROP VIEW IF EXISTS vw_UnpaidBookings;
GO
CREATE VIEW vw_UnpaidBookings AS
SELECT 
    b.BookingID, 
    c.FullName AS CustomerName, 
    r.RoomNumber, 
    SUM(p.Amount) AS TotalPaid, 
    DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price AS TotalCost,
    (DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price) - SUM(p.Amount) AS AmountDue
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Rooms r ON b.RoomID = r.RoomID
LEFT JOIN Payments p ON b.BookingID = p.BookingID
GROUP BY b.BookingID, c.FullName, r.RoomNumber, b.CheckInDate, b.CheckOutDate, r.Price
HAVING (DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price) > SUM(p.Amount);
GO

SELECT * FROM vw_UnpaidBookings;


-- 9 Báo cáo lương của nhân viên
DROP VIEW IF EXISTS vw_EmployeeSalaryReport;
GO
CREATE VIEW vw_EmployeeSalaryReport AS
SELECT 
    e.EmployeeID, 
    e.FullName, 
    e.Role, 
    e.Shift, 
    e.Salary, 
    e.Salary * 12 AS AnnualSalary
FROM Employees e;
GO

SELECT * FROM vw_EmployeeSalaryReport;


-- 10 Danh sách các phòng còn trống
DROP VIEW IF EXISTS vw_AvailableRooms;
GO
CREATE VIEW vw_AvailableRooms AS
SELECT 
    r.RoomID, 
    r.RoomNumber, 
    r.RoomType, 
    r.Price, 
    r.Status
FROM Rooms r
WHERE r.Status = N'Available';
GO

SELECT * FROM vw_AvailableRooms;





-- Tạo các stored procedure
-- 1 Thêm dặt phòng
DROP PROCEDURE IF EXISTS sp_AddBooking;
GO
CREATE PROCEDURE sp_AddBooking
    @CustomerID INT, @RoomID INT, @CheckInDate DATETIME, @CheckOutDate DATETIME, @GuestCount INT
AS
BEGIN
    INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, GuestCount, Status)
    VALUES (@CustomerID, @RoomID, @CheckInDate, @CheckOutDate, @GuestCount, N'Pending');
    SELECT SCOPE_IDENTITY() AS NewBookingID;
    UPDATE Rooms SET Status = N'Booked' WHERE RoomID = @RoomID;
END;
GO

-- Test sp_AddBooking
SELECT * FROM Bookings; 
EXEC sp_AddBooking 3, 5, '2024-04-01 14:00:00', '2024-04-05 12:00:00', 2;
GO
SELECT * FROM Bookings; 

-- 2 Thêm tính hóa đơn
DROP PROCEDURE IF EXISTS sp_CalculateInvoice;
GO
CREATE PROCEDURE sp_CalculateInvoice
    @BookingID INT
AS
BEGIN
    SELECT b.BookingID, SUM(DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price) AS RoomCost,
           COALESCE(SUM(id.TotalPrice), 0) AS ServiceCost,
           SUM(DATEDIFF(DAY, b.CheckInDate, b.CheckOutDate) * r.Price) + COALESCE(SUM(id.TotalPrice), 0) AS TotalCost
    FROM Bookings b
    JOIN Rooms r ON b.RoomID = r.RoomID
    LEFT JOIN Payments p ON b.BookingID = p.BookingID
    LEFT JOIN InvoiceDetails id ON p.PaymentID = id.PaymentID
    WHERE b.BookingID = @BookingID
    GROUP BY b.BookingID, b.CheckInDate, b.CheckOutDate, r.Price;
END;
GO

-- Test sp_CalculateInvoice
SELECT * FROM Bookings;
EXEC sp_CalculateInvoice 1;
GO

-- 3 Thêm phương thức thanh toán
DROP PROCEDURE IF EXISTS sp_ProcessPayment;
GO
CREATE PROCEDURE sp_ProcessPayment
    @BookingID INT, @Amount DECIMAL(10,2), @PaymentMethod NVARCHAR(50)
AS
BEGIN
    INSERT INTO Payments (BookingID, Amount, PaymentMethod, PaymentDate)
    VALUES (@BookingID, @Amount, @PaymentMethod, GETDATE());
    SELECT SCOPE_IDENTITY() AS NewPaymentID;
END;
GO

-- Test sp_ProcessPayment
SELECT * FROM Payments;
EXEC sp_ProcessPayment 1, 2000000, N'Credit Card';
GO
SELECT * FROM Payments;

-- 4 Thêm khách hàng mới
DROP PROCEDURE IF EXISTS sp_AddCustomer;
GO
CREATE PROCEDURE sp_AddCustomer
    @FullName NVARCHAR(100), @Phone NVARCHAR(15), @Email NVARCHAR(100), @Address NVARCHAR(255), @DateOfBirth DATE, @Gender NCHAR(1)
AS
BEGIN
    INSERT INTO Customers (FullName, Phone, Email, Address, DateOfBirth, Gender)
    VALUES (@FullName, @Phone, @Email, @Address, @DateOfBirth, @Gender);
    SELECT SCOPE_IDENTITY() AS NewCustomerID;
END;
GO

-- Test sp_AddCustomer
SELECT * FROM Customers;
EXEC sp_AddCustomer N'Trần Văn B', N'0981234567', N'tranvanb@example.com', N'Hà Nội', '1990-06-15', N'M';
GO
SELECT * FROM Customers;

-- 5 Cập nhật thông tin khách hàng
DROP PROCEDURE IF EXISTS sp_UpdateCustomer;
GO
CREATE PROCEDURE sp_UpdateCustomer
    @CustomerID INT, @FullName NVARCHAR(100), @Phone NVARCHAR(15), @Email NVARCHAR(100), @Address NVARCHAR(255), @DateOfBirth DATE, @Gender NCHAR(1)
AS
BEGIN
    UPDATE Customers
    SET FullName = @FullName, Phone = @Phone, Email = @Email, Address = @Address, DateOfBirth = @DateOfBirth, Gender = @Gender
    WHERE CustomerID = @CustomerID;
END;
GO

-- Test sp_UpdateCustomer
SELECT * FROM Customers
EXEC sp_UpdateCustomer 1, N'Nguyễn Văn A Updated', N'0987654321', N'nguyenvanaupdated@example.com', N'Hà Nội', '1990-05-12', N'M';
GO
SELECT * FROM Customers

-- 6 Xóa khách hàng
DROP PROCEDURE IF EXISTS sp_DeleteCustomer;
GO
CREATE PROCEDURE sp_DeleteCustomer
    @CustomerID INT
AS
BEGIN
    DELETE FROM Customers WHERE CustomerID = @CustomerID;
END;
GO

-- Test sp_DeleteCustomer
SELECT * FROM Customers
EXEC sp_DeleteCustomer 6;
GO
SELECT * FROM Customers

-- 7 Thêm dịch vụ mới
DROP PROCEDURE IF EXISTS sp_AddService;
GO
CREATE PROCEDURE sp_AddService
    @ServiceName NVARCHAR(100), @Price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Services (ServiceName, Price)
    VALUES (@ServiceName, @Price);
    SELECT SCOPE_IDENTITY() AS NewServiceID;
END;
GO

-- Test sp_AddService
SELECT * FROM Services;
EXEC sp_AddService N'Spa', 500000;
GO
SELECT * FROM Services;

-- 8 Cập nhật thông tin dịch vụ
DROP PROCEDURE IF EXISTS sp_UpdateService;
GO
CREATE PROCEDURE sp_UpdateService
    @ServiceID INT, @ServiceName NVARCHAR(100), @Price DECIMAL(10,2)
AS
BEGIN
    UPDATE Services
    SET ServiceName = @ServiceName, Price = @Price
    WHERE ServiceID = @ServiceID;
END;
GO

-- Test sp_UpdateService
SELECT * FROM Services;
EXEC sp_UpdateService 1, N'Luxury Spa', 600000;
GO
SELECT * FROM Services;

-- 9 Xóa dịch vụ
DROP PROCEDURE IF EXISTS sp_DeleteService;
GO
CREATE PROCEDURE sp_DeleteService
    @ServiceID INT
AS
BEGIN
    DELETE FROM Services WHERE ServiceID = @ServiceID;
END;
GO

-- Test sp_DeleteService
SELECT * FROM Services;
EXEC sp_DeleteService 2;
GO
SELECT * FROM Services;

-- 10 Lấy danh sách các phòng trống
DROP PROCEDURE IF EXISTS sp_GetAvailableRooms;
GO
CREATE PROCEDURE sp_GetAvailableRooms
AS
BEGIN
    SELECT RoomID, RoomNumber, RoomType, Price, Status
    FROM Rooms
    WHERE Status = N'Available';
END;
GO

-- Test sp_GetAvailableRooms
SELECT * FROM Rooms;
EXEC sp_GetAvailableRooms;
GO




-- Tạo các trigger

-- 1 Chèn thêm Booking
DROP TRIGGER IF EXISTS tr_BookingInsert;
GO
CREATE OR ALTER TRIGGER tr_BookingInsert 
ON Bookings AFTER INSERT 
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO RoomHistory (RoomID, BookingID, Status, UpdatedAt)
    SELECT i.RoomID, i.BookingID, N'Booked', GETDATE()
    FROM inserted i
    WHERE EXISTS (SELECT 1 FROM Rooms r WHERE r.RoomID = i.RoomID) -- Kiểm tra xem RoomID có tồn tại
    AND NOT EXISTS (SELECT 1 FROM RoomHistory rh WHERE rh.BookingID = i.BookingID);

    SELECT * FROM RoomHistory WHERE BookingID IN (SELECT BookingID FROM inserted);
END;
GO

-- Test
EXEC sp_AddBooking 
    @CustomerID = 2, 
    @RoomID = 2, 
    @CheckInDate = '2025-03-09', 
    @CheckOutDate = '2025-03-11', 
    @GuestCount = 3;
GO

SELECT * FROM Bookings; -- Kiểm tra BookingID
SELECT * FROM RoomHistory;
SELECT * FROM Customers WHERE CustomerID = 2;
GO


-- 2 Cật nhật trạng thái Booking
DROP TRIGGER IF EXISTS tr_BookingStatusUpdate;
GO
CREATE OR ALTER TRIGGER tr_BookingStatusUpdate 
ON Bookings AFTER UPDATE 
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Status)
    BEGIN
        UPDATE Rooms
        SET Status = CASE 
            WHEN i.Status = N'Checked-In' THEN N'Occupied'
            WHEN i.Status IN (N'Checked-Out', N'Cancelled') THEN N'Available'
            ELSE N'Booked' 
        END
        FROM Rooms r 
        JOIN inserted i ON r.RoomID = i.RoomID
        WHERE EXISTS (SELECT 1 FROM Rooms WHERE RoomID = i.RoomID); -- Kiểm tra tồn tại

        SELECT r.RoomNumber, r.Status, i.Status AS BookingStatus
        FROM Rooms r 
        JOIN inserted i ON r.RoomID = i.RoomID;
    END
END;
GO

-- Test
UPDATE Bookings
SET Status = N'Checked-In'
WHERE BookingID = (SELECT MAX(BookingID) FROM Bookings);
GO

SELECT * FROM Rooms WHERE RoomID = 2;
SELECT * FROM Customers WHERE CustomerID = 2;
GO

UPDATE Bookings
SET Status = N'Checked-Out'
WHERE BookingID = (SELECT MAX(BookingID) FROM Bookings);
GO

SELECT * FROM Rooms WHERE RoomID = 2;
GO

UPDATE Bookings
SET Status = N'Cancelled'
WHERE BookingID = (SELECT MAX(BookingID) FROM Bookings);
GO

SELECT * FROM Rooms WHERE RoomID = 2;
GO


-- 3 Cập nhật trạng thái Room
DROP TRIGGER IF EXISTS tr_RoomStatusUpdate;
GO
CREATE OR ALTER TRIGGER tr_RoomStatusUpdate 
ON Rooms AFTER UPDATE 
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(Status)
    BEGIN
        INSERT INTO RoomHistory (RoomID, BookingID, Status, UpdatedAt)
        SELECT i.RoomID, COALESCE(b.BookingID, 0), i.Status, GETDATE()
        FROM inserted i
        LEFT JOIN Bookings b 
        ON i.RoomID = b.RoomID AND b.Status IN (N'Pending', N'Checked-In');

        SELECT * FROM RoomHistory WHERE RoomID IN (SELECT RoomID FROM inserted);
    END
END;
GO

-- Test
-- Cập nhật trạng thái phòng
UPDATE Rooms SET Status = N'Occupied' WHERE RoomID = 3;
SELECT * FROM RoomHistory WHERE RoomID = 3;

-- Cập nhật phòng sang Available
UPDATE Rooms SET Status = N'Available' WHERE RoomID = 3;
SELECT * FROM RoomHistory WHERE RoomID = 3;


-- 4 Ngăn xóa khách hàng nếu họ có Booking đang hoạt động
DROP TRIGGER IF EXISTS tr_CustomerDelete_CheckBookings;
GO
CREATE OR ALTER TRIGGER tr_CustomerDelete_CheckBookings
ON Customers INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Bookings WHERE CustomerID IN (SELECT CustomerID FROM deleted))
    BEGIN
        RAISERROR (N'Không thể xóa khách hàng vì họ có đặt phòng chưa hoàn thành!', 16, 1);
        RETURN;
    END
    DELETE FROM Customers WHERE CustomerID IN (SELECT CustomerID FROM deleted);
END;
GO

 -- Test
DELETE FROM Customers WHERE CustomerID = 1; -- Lệnh này phải bị từ chối
SELECT * FROM Customers;


-- 5 Tự động cập nhật trạng thái Checked-Out nếu ngày trả phòng đã qua
DROP TRIGGER IF EXISTS tr_AutoCheckOut_ExpiredBookings;
GO

CREATE OR ALTER TRIGGER tr_AutoCheckOut_ExpiredBookings
ON Bookings AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Bookings
    SET Status = N'Checked-Out'
    WHERE CheckOutDate < GETDATE() AND Status = N'Checked-In';
END;
GO

-- Test
-- Tạo một booking đã hết hạn
INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, GuestCount, Status)
VALUES (1, 3, '2024-03-01 12:00:00', '2024-03-03 12:00:00', 2, N'Checked-In');

-- Kiểm tra xem trigger đã tự động cập nhật chưa
SELECT * FROM Bookings WHERE RoomID = 3;


-- 6  Lưu nhật ký khi cập nhật dịch vụ
DROP TRIGGER IF EXISTS trg_LogServiceUpdate;
GO
CREATE TRIGGER trg_LogServiceUpdate
ON Services
AFTER UPDATE
AS
BEGIN
    INSERT INTO ServiceLogs (ServiceID, OldPrice, NewPrice, UpdatedAt)
    SELECT d.ServiceID, d.Price, i.Price, GETDATE()
    FROM deleted d
    JOIN inserted i ON d.ServiceID = i.ServiceID;
END;
GO

--Test
-- Cập nhật giá dịch vụ
UPDATE Services SET Price = 750000 WHERE ServiceID = 1;  

-- Kiểm tra bảng nhật ký dịch vụ
SELECT * FROM Services WHERE ServiceID = 1;  


-- 7 Ngăn xóa dịch vụ nếu dịch vụ đã từng được sử dụng trong hóa đơn
DROP TRIGGER IF EXISTS tr_Service_Delete_CheckInvoice;
GO
CREATE OR ALTER TRIGGER tr_Service_Delete_CheckInvoice
ON Services INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM InvoiceDetails WHERE ServiceID IN (SELECT ServiceID FROM deleted))
    BEGIN
        RAISERROR (N'Không thể xóa dịch vụ vì nó đã được sử dụng trong hóa đơn!', 16, 1);
        RETURN;
    END
    DELETE FROM Services WHERE ServiceID IN (SELECT ServiceID FROM deleted);
END;
GO

-- Test
DELETE FROM Services WHERE ServiceID = 1; -- Lệnh này phải bị từ chối
SELECT * FROM Services;


-- 8 Ghi lại lịch sử thay đổi giá phòng vào bảng RoomPriceHistory
DROP TABLE IF EXISTS RoomPriceHistory;
GO
CREATE TABLE RoomPriceHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    RoomID INT NOT NULL,
    OldPrice DECIMAL(10,2),
    NewPrice DECIMAL(10,2),
    ChangedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

DROP TRIGGER IF EXISTS tr_UpdateRoomPrice_LogChange;
GO
CREATE TRIGGER tr_UpdateRoomPrice_LogChange
ON Rooms AFTER UPDATE
AS
BEGIN
    IF UPDATE(Price)
    BEGIN
        INSERT INTO RoomPriceHistory (RoomID, OldPrice, NewPrice, ChangedAt)
        SELECT i.RoomID, d.Price, i.Price, GETDATE()
        FROM inserted i
        JOIN deleted d ON i.RoomID = d.RoomID;
    END
END;
GO

-- Test
-- Cập nhật giá phòng
UPDATE Rooms SET Price = 800000 WHERE RoomID = 3;

-- Kiểm tra lịch sử giá phòng
SELECT * FROM RoomPriceHistory WHERE RoomID = 3;


-- 9 Tự động cập nhật trạng thái phòng khi đặt phòng
DROP TRIGGER IF EXISTS tr_UpdateRoomStatusOnBooking ;
GO
CREATE OR ALTER TRIGGER tr_UpdateRoomStatusOnBooking 
ON Bookings
AFTER INSERT
AS
BEGIN
    UPDATE Rooms
    SET Status = N'Booked'
    WHERE RoomID IN (SELECT RoomID FROM inserted);
END;
GO

-- Test
EXEC sp_AddBooking 3, 5, '2025-04-01 14:00:00', '2025-04-03', 2;
SELECT * FROM Rooms WHERE RoomID = 5; -- Kiểm tra trạng thái phòng có là 'Booked' hay không



-- 10 Ngăn chặn việc xóa phòng khi đang có khách ở
DROP TRIGGER IF EXISTS tr_PreventRoomDelete;
GO
CREATE TRIGGER tr_PreventRoomDelete
ON Rooms
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT 1 FROM deleted WHERE Status = 'Booked')
    BEGIN
        RAISERROR('Không thể xóa phòng đang được đặt!', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        DELETE FROM Rooms WHERE RoomID IN (SELECT RoomID FROM deleted);
    END
END;
GO

-- Test
-- Thử xóa phòng đang có khách
SELECT * FROM Rooms;
DELETE FROM Rooms WHERE RoomID = 1; 
SELECT * FROM Rooms;




-- === BAT DAU SCRIPT ===

-- === PHAN BAO MAT ===

-- Tao va xoa login (dam bao xac thuc tai cap server)
-- Phan nay tao login ManagerLogin va ReceptionistLogin voi mat khau
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ManagerLogin')
BEGIN
    DROP LOGIN ManagerLogin;
    PRINT 'Da xoa login ManagerLogin.';
END
CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager123!';
PRINT 'Da tao login ManagerLogin.';

IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'ReceptionistLogin')
BEGIN
    DROP LOGIN ReceptionistLogin;
    PRINT 'Da xoa login ReceptionistLogin.';
END
CREATE LOGIN ReceptionistLogin WITH PASSWORD = 'Reception123!';
PRINT 'Da tao login ReceptionistLogin.';

-- Tao va xoa vai tro (quan ly quyen tap trung)
-- Phan nay tao vai tro HotelManager va xoa neu da ton tai
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'HotelManager' AND type = 'R')
BEGIN
    IF EXISTS (SELECT * FROM sys.database_role_members rm 
               JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id 
               WHERE rm.role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'HotelManager'))
    BEGIN
        DECLARE @MemberName NVARCHAR(128);
        DECLARE @SqlCommand NVARCHAR(256);
        DECLARE member_cursor CURSOR FOR 
            SELECT dp.name 
            FROM sys.database_role_members rm 
            JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id
            WHERE rm.role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'HotelManager');
        OPEN member_cursor;
        FETCH NEXT FROM member_cursor INTO @MemberName;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SqlCommand = N'ALTER ROLE HotelManager DROP MEMBER ' + QUOTENAME(@MemberName);
            EXEC sp_executesql @SqlCommand;
            PRINT 'Da xoa thanh vien ' + @MemberName + ' khoi vai tro HotelManager.';
            FETCH NEXT FROM member_cursor INTO @MemberName;
        END
        CLOSE member_cursor;
        DEALLOCATE member_cursor;
    END
    DROP ROLE HotelManager;
    PRINT 'Da xoa vai tro HotelManager.';
END
CREATE ROLE HotelManager;
PRINT 'Da tao vai tro HotelManager.';

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Receptionist' AND type = 'R')
BEGIN
    IF EXISTS (SELECT * FROM sys.database_role_members rm 
               JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id 
               WHERE rm.role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Receptionist'))
    BEGIN
        DECLARE @MemberName2 NVARCHAR(128);
        DECLARE @SqlCommand2 NVARCHAR(256);
        DECLARE member_cursor2 CURSOR FOR 
            SELECT dp.name 
            FROM sys.database_role_members rm 
            JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id
            WHERE rm.role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'Receptionist');
        OPEN member_cursor2;
        FETCH NEXT FROM member_cursor2 INTO @MemberName2;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SqlCommand2 = N'ALTER ROLE Receptionist DROP MEMBER ' + QUOTENAME(@MemberName2);
            EXEC sp_executesql @SqlCommand2;
            PRINT 'Da xoa thanh vien ' + @MemberName2 + ' khoi vai tro Receptionist.';
            FETCH NEXT FROM member_cursor2 INTO @MemberName2;
        END
        CLOSE member_cursor2;
        DEALLOCATE member_cursor2;
    END
    DROP ROLE Receptionist;
    PRINT 'Da xoa vai tro Receptionist.';
END
CREATE ROLE Receptionist;
PRINT 'Da tao vai tro Receptionist.';

-- Tao va xoa user, gan vao vai tro (lien ket login voi database)
-- Phan nay tao user va gan vao vai tro de quan ly quyen
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ManagerUser')
BEGIN
    DROP USER ManagerUser;
    PRINT 'Da xoa user ManagerUser.';
END
CREATE USER ManagerUser FOR LOGIN ManagerLogin;
ALTER ROLE HotelManager ADD MEMBER ManagerUser;
PRINT 'Da tao user ManagerUser va them vao vai tro HotelManager.';

IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ReceptionistUser')
BEGIN
    DROP USER ReceptionistUser;
    PRINT 'Da xoa user ReceptionistUser.';
END
CREATE USER ReceptionistUser FOR LOGIN ReceptionistLogin;
ALTER ROLE Receptionist ADD MEMBER ReceptionistUser;
PRINT 'Da tao user ReceptionistUser va them vao vai tro Receptionist.';

-- === PHAN PHAN QUYEN ===

-- Phan quyen cho vai tro Receptionist
-- Phan nay gan quyen gioi han cho vai tro Receptionist
GRANT SELECT, INSERT, UPDATE ON Customers TO Receptionist;
GRANT SELECT ON Rooms TO Receptionist;
GRANT SELECT, INSERT, UPDATE ON Bookings TO Receptionist;
GRANT EXECUTE ON sp_AddBooking TO Receptionist;
GRANT EXECUTE ON sp_UpdateRoomStatus TO Receptionist;
GRANT SELECT ON vw_CurrentBookings TO Receptionist;
PRINT 'Da phan quyen cho vai tro Receptionist.';

-- Phan quyen cho vai tro HotelManager
-- Phan nay gan quyen day du cho vai tro HotelManager
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO HotelManager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Rooms TO HotelManager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Bookings TO HotelManager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Payments TO HotelManager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Employees TO HotelManager;
GRANT EXECUTE ON sp_AddBooking TO HotelManager;
GRANT EXECUTE ON sp_UpdateRoomStatus TO HotelManager;
GRANT EXECUTE ON sp_CalculateInvoice TO HotelManager;
GRANT SELECT ON vw_RoomRevenue TO HotelManager;
GRANT SELECT ON vw_ServiceUsage TO HotelManager;
PRINT 'Da phan quyen cho vai tro HotelManager.';

-- === HIEN THI KET QUA BAO MAT VA PHAN QUYEN ===

-- Hien thi thong tin bao mat voi tieu de ro rang
PRINT '=== BANG BAO MAT ===';
PRINT 'Danh sach Login:';
SELECT name AS LoginName, type_desc AS LoginType 
FROM sys.server_principals 
WHERE name IN ('ManagerLogin', 'ReceptionistLogin');

PRINT 'Danh sach User va Vai tro:';
SELECT 
    r.name AS RoleName, 
    m.name AS MemberName
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
WHERE r.name IN ('HotelManager', 'Receptionist');

-- Hien thi thong tin phan quyen voi tieu de ro rang
PRINT '=== BANG PHAN QUYEN ===';
PRINT 'Quyen cua vai tro Receptionist:';
SELECT 
    p.name AS PrincipalName, 
    p.type_desc AS PrincipalType,
    COALESCE(o.name, OBJECT_NAME(major_id), 'N/A') AS ObjectName,
    dp.permission_name AS Permission
FROM sys.database_permissions dp
JOIN sys.database_principals p ON dp.grantee_principal_id = p.principal_id
LEFT JOIN sys.objects o ON dp.major_id = o.object_id
WHERE p.name = 'Receptionist';

PRINT 'Quyen cua vai tro HotelManager:';
SELECT 
    p.name AS PrincipalName, 
    p.type_desc AS PrincipalType,
    COALESCE(o.name, OBJECT_NAME(major_id), 'N/A') AS ObjectName,
    dp.permission_name AS Permission
FROM sys.database_permissions dp
JOIN sys.database_principals p ON dp.grantee_principal_id = p.principal_id
LEFT JOIN sys.objects o ON dp.major_id = o.object_id
WHERE p.name = 'HotelManager';



-- === KET THUC SCRIPT ===


-- Sao lưu cơ sở dữ liệu
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'HotelManagement')
BEGIN
    BACKUP DATABASE HotelManagement
    TO DISK = 'D:\Backup\HotelManagement_FullBackup.bak'
    WITH FORMAT, INIT, NAME = 'Full Backup of HotelManagement';
    PRINT 'Sao lưu cơ sở dữ liệu HotelManagement thành công.';
END
ELSE
BEGIN
    RAISERROR ('Cơ sở dữ liệu HotelManagement không tồn tại. Không thể sao lưu.', 16, 1);
END
GO

-- Xem dữ liệu
SELECT * FROM Customers;
GO