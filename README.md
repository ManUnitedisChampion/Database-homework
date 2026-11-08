# Đề 04: Cơ Sở Dữ Liệu Quản Lý Lưu Trú Tại Khách Sạn (`hotel_mini`)

**Học phần:** Nhập môn Cơ sở dữ liệu — Introduction to Database (`[Mã lớp học phần]`)  
**Đơn vị:** Khoa Khoa học Dữ liệu và Trí tuệ Nhân tạo (Faculty of DS & AI) — Trường Công nghệ, Đại học Kinh tế Quốc dân (NEU)  
**Giảng viên hướng dẫn:** `[Điền tên Giảng viên hướng dẫn]`  
**Sinh viên thực hiện:**
* Đặng Nguyễn Ngọc Hải (`11252770`)
* `Trần Huy Hoàng` (`11253240`)
* `Đinh Viết Sang` (`11257344`)

## 1. Giới thiệu bài toán

Dự án xây dựng và khai thác cơ sở dữ liệu quan hệ **`hotel_mini`** trên hệ quản trị cơ sở dữ liệu **MySQL** nhằm quản lý quy trình lưu trú tại khách sạn. Hệ thống bao quát các nghiệp vụ cốt lõi:

* **Quản lý danh mục loại phòng và phòng vật lý:** Mỗi loại phòng (`room_types`) có nhiều phòng (`rooms`); mỗi phòng chỉ thuộc một loại phòng duy nhất, có số phòng (`room_number`) duy nhất và sức chứa (`capacity > 0`).
* **Quản lý khách lưu trú và đặt phòng:** Mỗi lượt đặt phòng (`bookings`) gắn với một khách đại diện (`guests`) và một phòng cụ thể, ghi nhận ngày nhận phòng (`checkin_date`), ngày dự kiến trả phòng (`planned_checkout > checkin_date`) và trạng thái (`Pending`, `Completed`, `Cancelled`).
* **Quyết toán chi phí lưu trú:** Chỉ những lượt đặt phòng ở trạng thái `Completed` mới lập phiếu quyết toán (`stay_bills`, quan hệ `1 - 0..1` với `bookings`). Tổng chi phí lưu trú thỏa mãn công thức `total_charge = room_charge + extra_charge`.
* **Quản lý thu tiền và theo dõi công nợ:** Một lượt đặt phòng có thể thanh toán thành nhiều đợt (`payments`) qua các phương thức `Cash`, `BankTransfer`, `Card` với tổng số tiền thu không vượt quá chi phí đã xác nhận. Công nợ được tính chính xác bằng tổng chi phí xác nhận trừ tổng tiền thực thu, đảm bảo không bị cộng lặp chi phí khi nối dữ liệu một-nhiều.

## 2. Cấu trúc thư mục dự án

Thứ tự các tệp mã nguồn SQL và tài liệu báo cáo trong kho lưu trữ (repository):

| Tên tệp | Vai trò và nội dung chính | Thứ tự chạy |
| :--- | :--- | :---: |
| `schema.sql` | Khởi tạo CSDL `hotel_mini`, tạo 6 bảng dữ liệu cùng các ràng buộc khóa chính (`PRIMARY KEY`), khóa ngoại (`FOREIGN KEY`) và `NOT NULL`. | 1 |
| `seed.sql` | Nạp bộ dữ liệu mẫu bao phủ các kịch bản kiểm thử (giao dịch Quý I/2025, ngoài Quý I/2025, năm 2024; đủ 3 trạng thái; trả nhiều lần; còn nợ; chưa thanh toán). | 2 |
| `queries.sql` | Chứa 10 câu truy vấn SQL độc lập phục vụ thống kê, lọc dữ liệu và phân tích nghiệp vụ theo yêu cầu Đề 04. | 3 |
| `views.sql` | Khởi tạo 3 khung nhìn (`v_detail`, `v_group_summary`, `v_debt`) tổng hợp chi tiết đặt phòng, doanh thu theo loại phòng và công nợ khách hàng. | 4 |
| `De_4_Database.pdf` | Tài liệu đặc tả yêu cầu kỹ thuật và nghiệp vụ của Đề thực hành số 04. | Tài liệu |
| `Bao_cao_Nhap_mon_CSDL_De_04.docx` | Báo cáo chi tiết phân tích thiết kế lược đồ, dữ liệu mẫu, giải thích truy vấn và kết quả thực thi. | Báo cáo |

## 3. Thiết kế lược đồ cơ sở dữ liệu (`schema.sql`)

Cơ sở dữ liệu `hotel_mini` gồm 6 bảng quan hệ với cấu trúc chi tiết như sau:

| Tên bảng | Khóa chính (PK) | Khóa ngoại (FK) | Các trường thông tin và mô tả |
| :--- | :--- | :--- | :--- |
| `room_types` | `type_id` `VARCHAR(5)` | *Không có* | `name` `VARCHAR(20) NOT NULL`: Tên loại phòng (`Standard`, `Superior`, `Deluxe`, `Family Suite`, `Presidential`). |
| `rooms` | `room_id` `VARCHAR(4)` | `type_id` &rarr; `room_types(type_id)` | `room_number` `INT NOT NULL` (số phòng), `floor` `INT` (tầng), `capacity` `INT` (sức chứa). |
| `guests` | `guests_id` `VARCHAR(4)` | *Không có* | `full_name` `VARCHAR(50) NOT NULL`, `phone` `VARCHAR(20)`, `identity_number` `VARCHAR(50) NOT NULL` (CCCD/Hộ chiếu). |
| `bookings` | `booking_id` `VARCHAR(4)` | `guests_id` &rarr; `guests(guests_id)`<br>`room_id` &rarr; `rooms(room_id)` | `checkin_date` `DATETIME NOT NULL`, `status` `VARCHAR(50)` (`Pending`, `Completed`, `Cancelled`), `planned_checkout` `DATETIME NOT NULL`. |
| `stay_bills` | `bill_id` `VARCHAR(5)` | `booking_id` &rarr; `bookings(booking_id)` | `checkout_date` `DATETIME NOT NULL`, `room_charge` `FLOAT NOT NULL`, `extra_charge` `FLOAT`, `total_charge` `FLOAT NOT NULL`. |
| `payments` | `payment_id` `VARCHAR(4)` | `booking_id` &rarr; `bookings(booking_id)` | `amount` `INT`, `payment_date` `DATETIME NOT NULL`, `method` `VARCHAR(50)` (`Cash`, `BankTransfer`, `Card`). |

## 4. Tóm tắt bộ dữ liệu mẫu (`seed.sql`)

Bộ dữ liệu mẫu được thiết kế để kiểm chứng toàn diện các điều kiện biên của bài toán:

* **Danh mục loại phòng & phòng (`room_types`, `rooms`):** 5 phân hạng phòng (`RT001` đến `RT006`) và 6 phòng vật lý (`R001` đến `R006` từ tầng 1 đến tầng 4). Trong đó phòng `R006` (loại `RT005 - Family Suite`) chỉ có giao dịch trong năm 2024 (`B009`), không phát sinh giao dịch trong Quý I/2025 cũng như cả năm 2025.
* **Danh mục khách lưu trú (`guests`):** 10 khách hàng (`G001` đến `G010`), bao gồm khách có hơn 3 giao dịch hoàn tất năm 2025 (`G001 - Bruno Fernades` với 4 đơn `B001, B003, B005, B007`), khách có lịch sử giao dịch nhưng chưa thanh toán (`G006 - Cristiano Ronaldo`, `G003`, `G004`, `G005`, `G007`), khách chỉ có giao dịch `Pending` (`G008`), khách chỉ có giao dịch `Cancelled` (`G009`) và khách chưa từng đặt phòng (`G010 - Harry Maguire`).
* **Lượt đặt phòng, quyết toán và thanh toán (`bookings`, `stay_bills`, `payments`):** 13 lượt đặt phòng (`B001`–`B013`), 10 phiếu quyết toán (`SB001`–`SB010`) cho 10 đơn `Completed`, cùng các đợt thanh toán minh họa giao dịch trả nhiều lần (`B001` gồm `P001` và `P002`) và giao dịch trả một phần còn nợ (`B002` mới trả `P003`).

## 5. Danh mục 10 truy vấn (`queries.sql`) và 3 khung nhìn (`views.sql`)

### 5.1. Danh sách 10 truy vấn khai thác dữ liệu (`queries.sql`)

| Câu | Nội dung yêu cầu truy vấn | Kỹ thuật SQL sử dụng |
| :---: | :--- | :--- |
| **1** | Liệt kê các lượt đặt phòng `Completed` trong tháng 01/2025 kèm khách lưu trú, phòng và `checkin_date`. | `INNER JOIN` 3 bảng (`bookings`, `guests`, `rooms`), lọc khoảng ngày tháng 01/2025. |
| **2** | Đếm tổng số lượt đặt phòng theo từng loại phòng trong Quý I/2025 (mọi trạng thái, hiển thị cả nhóm bằng 0). | `LEFT JOIN` từ `room_types` sang `rooms` và `bookings` (đặt điều kiện ngày trong `ON`), `GROUP BY`. |
| **3** | Liệt kê các khách lưu trú có ít nhất một lượt đặt phòng chưa có phiếu quyết toán, loại trừ `Cancelled`. | `LEFT JOIN stay_bills`, lọc `sb.bill_id IS NULL` và loại trừ trạng thái hủy. |
| **4** | Tính chi phí lưu trú trung bình trên một giao dịch `Completed` của từng loại phòng (chỉ lấy nhóm có chi phí). | `INNER JOIN` 4 bảng từ `room_types` đến `stay_bills`, hàm tổng hợp `AVG(sb.total_charge)`. |
| **5** | Liệt kê 3 phòng có nhiều lượt đặt phòng `Completed` nhất trong năm 2025 (ưu tiên `room_id` tăng dần). | `GROUP BY r.room_id`, sắp xếp `ORDER BY booking_count DESC, r.room_id ASC` và `LIMIT 3`. |
| **6** | Tính tổng số tiền từng khách lưu trú đã thanh toán trong năm 2025 theo `payment_date` (hiển thị cả tổng bằng 0). | `LEFT JOIN bookings` và `LEFT JOIN payments` (lọc năm 2025 trong `ON`), `COALESCE(SUM(p.amount), 0)`. |
| **7** | Liệt kê các khách lưu trú chưa có bất kỳ bản ghi thanh toán nào trong toàn bộ dữ liệu (kể cả chưa giao dịch). | `LEFT JOIN` từ `guests` đến `payments`, lọc nhóm bằng `HAVING COUNT(p.payment_id) = 0`. |
| **8** | Liệt kê toàn bộ khách lưu trú theo tổng chi phí lưu trú đã xác nhận giảm dần (nếu bằng nhau sắp mã tăng dần). | `LEFT JOIN` và `GROUP BY g.guests_id`, dùng `COALESCE` và `ORDER BY ... DESC, g.guests_id ASC`. |
| **9** | Tính tỷ lệ hủy (`%`) của từng phòng trong năm 2025, làm tròn 2 chữ số thập phân (trả `NULL` nếu tổng bằng 0). | Biểu thức `ROUND(CASE WHEN COUNT(b.booking_id) = 0 THEN NULL ELSE ... END, 2)`. |
| **10** | Liệt kê các khách lưu trú có hơn 3 lượt đặt phòng `Completed` trong năm 2025 kèm số lần giảm dần. | Lọc năm 2025 và `status = 'Completed'`, gom nhóm với `HAVING COUNT(b.booking_id) > 3`. |

### 5.2. Hệ thống 3 khung nhìn tổng hợp (`views.sql`)

* **`v_detail`:** Hiển thị chi tiết từng lượt đặt phòng gồm mã đặt phòng, ngày nhận phòng, trạng thái, tên khách lưu trú, số phòng, tên loại phòng và chi phí lưu trú (`LEFT JOIN stay_bills` để giữ cả giao dịch chưa quyết toán với chi phí là `NULL`).
* **`v_group_summary`:** Thống kê theo từng loại phòng gồm mã loại, tên loại, tổng số giao dịch, số giao dịch `Completed`, số giao dịch hủy và tổng chi phí lưu trú (`COALESCE(SUM(sb.total_charge), 0)`), giữ cả nhóm chưa phát sinh giao dịch.
* **`v_debt`:** Theo dõi công nợ của từng khách lưu trú gồm mã khách, họ tên, tổng chi phí đã xác nhận (`total_stay_charge`), tổng tiền đã trả (`total_paid`) và số tiền còn nợ (`remaining_charge`). Sử dụng 2 bảng dẫn xuất (subquery `b_charge` và `p_pay`) độc lập trước khi `LEFT JOIN` với `guests` để ngăn chặn triệt để hiện tượng cộng lặp chi phí khi một đơn đặt phòng có nhiều lần thanh toán.

## 6. Hướng dẫn cài đặt và chạy mã nguồn

Yêu cầu hệ thống: **MySQL Server 8.0+** (hoặc MariaDB tương đương) và công cụ quản trị như MySQL Workbench, DBeaver hoặc MySQL CLI.

Chạy tuần tự 4 tệp mã nguồn theo đúng thứ tự quy định bằng dòng lệnh (CLI):

```bash
mysql -u root -p < schema.sql
mysql -u root -p hotel_mini < seed.sql
mysql -u root -p hotel_mini < queries.sql
mysql -u root -p hotel_mini < views.sql
```

Hoặc mở trực tiếp trong **MySQL Workbench / DBeaver** và thực thi lần lượt từng tệp theo thứ tự:
1. Chạy `schema.sql` để khởi tạo CSDL `hotel_mini` và các bảng.
2. Chạy `seed.sql` để nạp dữ liệu mẫu.
3. Chạy `queries.sql` để kiểm tra kết quả của 10 câu truy vấn.
4. Chạy `views.sql` để tạo và truy xuất 3 khung nhìn `v_detail`, `v_group_summary`, `v_debt`.
