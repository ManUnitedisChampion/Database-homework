USE hotel_mini;

INSERT INTO room_types (type_id, name) VALUES
('RT001', 'Standard'),
('RT002', 'Superior'),
('RT004', 'Deluxe'),
('RT005', 'Family Suite'),
('RT006', 'Presidential');

INSERT INTO rooms (room_id, room_number, floor, capacity, type_id) VALUES
('R001', 101, 1, 2, 'RT001'),
('R002', 102, 1, 2, 'RT001'),
('R003', 201, 2, 2, 'RT002'),
('R004', 202, 2, 3, 'RT006'),
('R005', 301, 3, 4, 'RT004'),
('R006', 401, 4, 4, 'RT005'); 

INSERT INTO guests (guests_id, full_name, phone, identity_number) VALUES
('G001', 'Bruno Fernades', '0901000001', '001099000001'),   -- Có > 3 GD Completed năm 2025
('G002', 'Matheus Cunha', '0901000002', '001099000002'),   -- Giao dịch còn nợ 1 phần
('G003', 'Mbeumo', '0901000003', '001099000003'),
('G004', 'Amad Dialo', '0901000004', '001099000004'),
('G005', 'Lammens', '0901000005', '001099000005'),
('G006', 'Cristiano Ronaldo', '0901000006', '001099000006'),   -- Có lịch sử GD nhưng chưa thanh toán
('G007', 'Đặng Nguyễn Ngọc Hải', '0901000007', '001099000007'),  -- Có GD năm 2024
('G008', 'Michael Carrick', '0901000008', '001099000008'),   -- Chỉ có GD Pending
('G009', 'Lisandro Martinez', '0901000009', '001099000009'),  -- Chỉ có GD Cancelled
('G010', 'Harry Maguire', '0901000010', '001099000010');   -- Khách chưa có bất kỳ giao dịch nào


INSERT INTO bookings (booking_id, guests_id, room_id, checkin_date, status, planned_checkout) VALUES
-- Giao dịch trong tháng 01/2025 (Completed)
('B001', 'G001', 'R001', '2025-01-05', 'Completed', '2025-01-08'),
('B002', 'G002', 'R003', '2025-01-15', 'Completed', '2025-01-18'),

('B003', 'G001', 'R001', '2025-02-10', 'Completed', '2025-02-12'),
('B004', 'G003', 'R004', '2025-02-20', 'Completed', '2025-02-23'),
('B005', 'G001', 'R002', '2025-03-05', 'Completed', '2025-03-07'),
('B006', 'G004', 'R005', '2025-03-18', 'Completed', '2025-03-21'),

('B007', 'G001', 'R001', '2025-05-10', 'Completed', '2025-05-13'), -- Giúp G001 đạt 4 GD Completed năm 2025
('B008', 'G006', 'R004', '2025-06-01', 'Completed', '2025-06-04'), -- G006 có GD nhưng chưa thanh toán

('B009', 'G005', 'R006', '2024-11-10', 'Completed', '2024-11-13'), -- R006 & T05 chỉ có GD năm 2024
('B010', 'G007', 'R002', '2024-12-20', 'Completed', '2024-12-23'),

('B011', 'G008', 'R003', '2025-01-25', 'Pending',   '2025-01-28'), -- Quý I/2025 (Pending)
('B012', 'G003', 'R005', '2025-07-10', 'Pending',   '2025-07-15'), -- Ngoài Quý I/2025 (Pending)
('B013', 'G009', 'R001', '2025-04-02', 'Canceled', '2025-04-05'); -- Năm 2025 (Cancelled)


INSERT INTO stay_bills (bill_id, booking_id, checkout_date, room_charge, extra_charge, total_charge) VALUES
('SB001', 'B001', '2025-01-08', 1500000.00, 200000.00, 1700000.00),
('SB002', 'B002', '2025-01-18', 2100000.00, 300000.00, 2400000.00),
('SB003', 'B003', '2025-02-12', 1000000.00,      0.00, 1000000.00),
('SB004', 'B004', '2025-02-23', 3000000.00, 500000.00, 3500000.00),
('SB005', 'B005', '2025-03-07', 1000000.00, 150000.00, 1150000.00),
('SB006', 'B006', '2025-03-21', 4500000.00, 500000.00, 5000000.00),
('SB007', 'B007', '2025-05-13', 1500000.00, 100000.00, 1600000.00),
('SB008', 'B008', '2025-06-04', 3000000.00, 200000.00, 3200000.00), -- Chưa có thanh toán nào (Nợ 3.200.000)
('SB009', 'B009', '2024-11-13', 9000000.00, 1000000.00, 10000000.00),
('SB010', 'B010', '2024-12-23', 1500000.00,      0.00, 1500000.00);

INSERT INTO payments (payment_id, booking_id, amount, payment_date, method) VALUES
('P001', 'B001', 1000000.00, '2025-01-06', 'Cash'),
('P002', 'B001',  700000.00, '2025-01-08', 'BankTransfer'),
('P003', 'B002', 1000000.00, '2025-01-18', 'Card'),
('P004', 'B003', 1000000.00, '2025-02-12', 'Cash');

INSERT INTO payments (payment_id, booking_id, amount, payment_date, method) VALUES
('P005', 'B003',  500000.00, '2025-02-14', 'BankTransfer'),
('P006', 'B004', 1200000.00, '2025-02-20', 'Card'),
('P007', 'B004',  800000.00, '2025-02-25', 'Cash'),
('P008', 'B005', 1500000.00, '2025-03-03', 'BankTransfer'),
('P009', 'B006',  900000.00, '2025-03-10', 'Card'),
('P010', 'B006',  600000.00, '2025-03-15', 'Cash');

