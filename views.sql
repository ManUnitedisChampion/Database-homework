CREATE VIEW v_detail AS
SELECT
    b.booking_id,
    b.checkin_date,
    b.status,
    g.full_name AS guest_name,
    r.room_number,
    rt.name AS room_type_name,
    sb.total_charge AS stay_charge
FROM bookings b
JOIN guests g 
    ON b.guests_id = g.guests_id
JOIN rooms r
    ON b.room_id = r.room_id
JOIN room_types rt 
    ON r.type_id = rt.type_id
LEFT JOIN stay_bills sb 
    ON sb.booking_id = b.booking_id; -- v_detail: mỗi dòng là một lượt đặt phòng, gồm mã, ngày, trạng thái, tên khách lưu trú, số phòng và tên loại phòng và chi phí lưu trú. Giữ cả giao dịch chưa có kết quả, khi đó chi phí là NULL.

CREATE VIEW v_group_summary AS
SELECT
    rt.type_id,
    rt.name AS room_type_name,
    COUNT(b.booking_id) AS total_bookings,
    COUNT(CASE WHEN b.status = 'Completed' THEN 1 END) AS completed_bookings,
    COUNT(CASE WHEN b.status = 'Canceled' THEN 1 END) AS canceled_bookings,
    COALESCE(SUM(sb.total_charge), 0) AS total_stay_charge
FROM room_types rt
LEFT JOIN rooms r
    ON r.type_id = rt.type_id
LEFT JOIN bookings b
    ON b.room_id = r.room_id
LEFT JOIN stay_bills sb
    ON sb.booking_id = b.booking_id
GROUP BY
    rt.type_id,
    rt.name;

CREATE VIEW v_debt AS
SELECT
    g.guests_id,
    g.full_name,
    COALESCE(b_charge.total_charge, 0) AS total_stay_charge,
    COALESCE(p_pay.total_paid, 0) AS total_paid,
    (COALESCE(b_charge.total_charge, 0) - COALESCE(p_pay.total_paid, 0)) AS remaining_charge
FROM guests g
LEFT JOIN (
    SELECT 
        b.guests_id,
        SUM(sb.total_charge) AS total_charge
    FROM bookings b
    JOIN stay_bills sb
        ON sb.booking_id = b.booking_id
    GROUP BY
        b.guests_id
) b_charge ON g.guests_id = b_charge.guests_id
LEFT JOIN (
    SELECT 
        b.guests_id,
        SUM(p.amount) AS total_paid
    FROM bookings b
    JOIN payments p
        ON p.booking_id = b.booking_id
    GROUP BY
        b.guests_id
) p_pay ON g.guests_id = p_pay.guests_id;

SELECT * FROM v_debt