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

INSERT INTO Rooms (RoomNumber, RoomType, Price, Status) VALUES
(N'101', N'Single', 500000, N'Available'),
(N'102', N'Double', 800000, N'Available'),
(N'201', N'Single', 550000, N'Available'),
(N'202', N'Double', 850000, N'Booked'),
(N'301', N'Suite', 1200000, N'Available'),
(N'302', N'Single', 600000, N'Occupied');
GO

INSERT INTO Services (ServiceName, Price) VALUES
(N'Bữa sáng', 100000),
(N'Giặt là', 50000),
(N'Dịch vụ phòng', 150000),
(N'Đưa đón sân bay', 300000),
(N'Massage', 250000);
GO

INSERT INTO Employees (FullName, Role, Salary, Shift) VALUES
(N'Nguyễn Văn H', N'Lễ tân', 8000000, N'Sáng'),
(N'Trần Thị I', N'Quản lý', 15000000, N'Chiều'),
(N'Lê Văn K', N'Bảo vệ', 6000000, N'Đêm'),
(N'Phạm Thị L', N'Buồng phòng', 7000000, N'Sáng'),
(N'Hoàng Văn M', N'Lễ tân', 8500000, N'Chiều');
GO

INSERT INTO Bookings (CustomerID, RoomID, CheckInDate, CheckOutDate, GuestCount, Status) VALUES
(1, 1, '2024-03-01 14:00:00', '2024-03-05 12:00:00', 1, N'Checked-In'),
(2, 2, '2024-03-02 15:00:00', '2024-03-06 11:00:00', 2, N'Checked-Out'),
(3, 3, '2024-03-04 13:00:00', '2024-03-07 10:00:00', 1, N'Pending'),
(4, 4, '2024-03-05 12:00:00', '2024-03-08 12:00:00', 3, N'Checked-In'),
(5, 5, '2024-03-06 16:00:00', '2024-03-09 11:00:00', 2, N'Cancelled');
GO

INSERT INTO Payments (BookingID, Amount, PaymentMethod, PaymentDate) VALUES
(1, 2000000, N'Credit Card', '2024-03-05 12:00:00'),
(2, 3200000, N'Cash', '2024-03-06 11:00:00'),
(3, 1800000, N'Online', '2024-03-07 10:00:00'),
(4, 2550000, N'Debit Card', '2024-03-08 12:00:00');
GO

INSERT INTO InvoiceDetails (PaymentID, ServiceID, Quantity, UnitPrice) VALUES
(1, 1, 2, 100000), -- PaymentID = 1, ServiceID = 1 (Bữa sáng)
(2, 2, 3, 50000),  -- PaymentID = 2, ServiceID = 2 (Giặt là)
(3, 3, 1, 150000), -- PaymentID = 3, ServiceID = 3 (Dịch vụ phòng)
(4, 4, 1, 300000); -- PaymentID = 4, ServiceID = 4 (Đưa đón sân bay)
GO

INSERT INTO RoomHistory (RoomID, BookingID, Status, UpdatedAt) VALUES
(1, 1, N'Occupied', '2024-03-01 14:30:00'),
(2, 2, N'Cleaned', '2024-03-06 12:00:00'),
(3, 3, N'Pending', '2024-03-04 13:15:00'),
(4, 4, N'Occupied', '2024-03-05 12:20:00'),
(5, 5, N'Available', '2024-03-06 16:45:00');
GO

SELECT * FROM Customers;
SELECT * FROM Rooms;
SELECT * FROM Services;
SELECT * FROM Employees;
SELECT * FROM Bookings;
SELECT * FROM Payments;
SELECT * FROM InvoiceDetails;
SELECT * FROM RoomHistory;
