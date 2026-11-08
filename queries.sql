SELECT b.booking_id, b.checkin_date, b.status, g.guests_id, g.full_name, r.room_id, r.room_number
FROM
    bookings b
    JOIN guests g ON b.guests_id = g.guests_id
    JOIN rooms r ON b.room_id = r.room_id
WHERE
    b.status = 'Completed'
    AND b.checkin_date >= '2025-01-01'
    AND b.checkin_date <= '2025-01-31'
ORDER BY b.checkin_date ASC, b.booking_id ASC;
-- 1. Liệt kê các lượt đặt phòng Completed trong tháng 01/2025, kèm khách lưu trú, phòng và ngày nghiệp vụ checkin_date

SELECT
    rt.type_id,
    rt.name AS room_type_name,
    COUNT(b.booking_id) AS total_bookings
FROM
    room_types rt
    LEFT JOIN rooms r ON r.type_id = rt.type_id
    LEFT JOIN bookings b ON b.room_id = r.room_id
    AND b.checkin_date >= '2025-01-01'
    AND b.checkin_date <= '2025-03-31'
GROUP BY
    rt.type_id,
    rt.name
ORDER BY total_bookings DESC, rt.type_id ASC;
-- 2. Đếm tổng số lượt đặt phòng theo từng loại phòng trong quý I/2025, tính mọi trạng thái; hiển thị cả nhóm có số lượng bằng 0

SELECT g.guests_id, g.full_name
FROM
    guests g
    JOIN bookings b ON b.guests_id = g.guests_id
    LEFT JOIN stay_bills sb ON sb.booking_id = b.booking_id
WHERE
    sb.bill_id IS NULL
    AND b.status <> 'Canceled'
ORDER BY g.full_name ASC;
-- 3. Liệt kê các khách lưu trú có ít nhất một lượt đặt phòng chưa có phiếu quyết toán, loại trừ Cancelled. Mỗi người chỉ xuất hiện một lần.

SELECT rt.type_id, rt.name, AVG(sb.total_charge) AS avg_total_charge
FROM
    room_types rt
    JOIN rooms r ON r.type_id = rt.type_id
    JOIN bookings b ON b.room_id = r.room_id
    JOIN stay_bills sb ON sb.booking_id = b.booking_id
WHERE
    b.status = 'Completed'
GROUP BY
    rt.type_id,
    rt.name
ORDER BY rt.name ASC, rt.type_id ASC;
-- 4. Tính chi phí lưu trú trung bình trên một giao dịch Completed của từng loại phòng, xét toàn bộ thời gian; chỉ lấy nhóm đã phát sinh chi phí.

SELECT r.room_id, rt.name, COUNT(b.booking_id) AS booking_count
FROM
    rooms r
    JOIN room_types rt ON r.type_id = rt.type_id
    JOIN bookings b ON b.room_id = r.room_id
WHERE
    b.status = 'Completed'
    AND b.checkin_date >= '2025-01-01'
    AND b.checkin_date <= '2025-12-31'
GROUP BY
    r.room_id
ORDER BY booking_count DESC
LIMIT 3;
-- 5. Liệt kê 3 phòng có nhiều lượt đặt phòng Completed nhất trong năm 2025. Nếu bằng nhau, ưu tiên mã room_id tăng dần; chỉ lấy đối tượng có giao dịch.

SELECT g.guests_id, g.full_name, COALESCE(SUM(p.amount), 0) AS total_paid_2025
FROM
    guests g
    LEFT JOIN bookings b ON b.guests_id = g.guests_id
    LEFT JOIN payments p ON p.booking_id = b.booking_id
    AND p.payment_date >= '2025-01-01'
    AND p.payment_date <= '2025-12-31'
GROUP BY
    g.guests_id,
    g.full_name
ORDER BY g.full_name ASC; -- 6. Tính tổng số tiền từng khách lưu trú đã thanh toán trong năm 2025 theo payment_date; hiển thị cả người chưa trả tiền với tổng bằng 0.

SELECT g.guests_id, g.full_name
FROM
    guests g
    LEFT JOIN bookings b ON b.guests_id = g.guests_id
    LEFT JOIN payments p ON p.booking_id = b.booking_id
GROUP BY
    g.guests_id,
    g.full_name
HAVING
    COUNT(p.payment_id) = 0
ORDER BY g.full_name ASC;
-- 7. Liệt kê các khách lưu trú chưa có bất kỳ bản ghi thanh toán nào trong toàn bộ dữ liệu, kể cả người chưa có giao dịch

SELECT g.guests_id, g.full_name, COALESCE(SUM(p.amount), 0) AS total_paid
FROM
    guests g
    LEFT JOIN bookings b ON b.guests_id = g.guests_id
    LEFT JOIN payments p ON p.booking_id = b.booking_id
GROUP BY
    g.guests_id,
    g.full_name
ORDER BY total_paid DESC, g.guests_id ASC;
-- 8. Liệt kê toàn bộ khách lưu trú theo tổng chi phí lưu trú đã xác nhận giảm dần, không phụ thuộc đã thanh toán hay chưa; nếu bằng nhau, sắp theo mã tăng dần.

SELECT r.room_id, r.room_number, ROUND(
        CASE
            WHEN COUNT(b.booking_id) = 0 THEN NULL
            ELSE COUNT(
                CASE
                    WHEN b.status = 'Canceled' THEN 1
                END
            ) * 100.0 / COUNT(b.booking_id)
        END, 2
    ) AS cancelation_rate
FROM rooms r
    JOIN bookings b ON b.room_id = r.room_id
    AND b.checkin_date >= '2025-01-01'
    AND b.checkin_date <= '2025-12-31'
GROUP BY
    r.room_id,
    r.room_number
ORDER BY cancelation_rate DESC, r.room_id ASC; -- 9. Tính tỷ lệ hủy của từng phòng trong năm 2025: số lượt đặt phòng Cancelled chia tổng số lượt đặt phòng của năm, nhân 100. Làm tròn 2 chữ số thập phân; trả NULL nếu tổng bằng 0.

SELECT g.guests_id, g.full_name, COUNT(b.booking_id) as booking_count
FROM guests g
    JOIN bookings b ON b.guests_id = g.guests_id
    AND b.checkin_date >= '2025-01-01'
    AND b.checkin_date <= '2025-12-31'
WHERE
    b.status = 'Completed'
GROUP BY
    g.guests_id,
    g.full_name
HAVING
    COUNT(b.booking_id) > 3
ORDER BY booking_count DESC; -- 10. Liệt kê các khách lưu trú có hơn 3 lượt đặt phòng Completed trong năm 2025, kèm số lần; sắp số lần giảm dần
