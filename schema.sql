create DATABASE hotel_mini;

use hotel_mini;
CREATE TABLE room_types (
    type_id VARCHAR(5) PRIMARY KEY,
    name VARCHAR(20) NOT NULL
);

CREATE TABLE rooms (
    room_id VARCHAR(4) PRIMARY KEY,
    room_number INT NOT NULL,
    floor INT,
    capacity INT,
    type_id VARCHAR(5),
    FOREIGN KEY (type_id) REFERENCES room_types(type_id)
);

CREATE TABLE guests (
    guests_id VARCHAR(4) PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    identity_number VARCHAR(50) NOT NULL
);

CREATE TABLE bookings (
    booking_id VARCHAR(4) PRIMARY KEY,
    guests_id VARCHAR(4),
    room_id VARCHAR(4),

    checkin_date DATETIME NOT NULL,
    status VARCHAR(50),
    planned_checkout DATETIME NOT NULL,

    FOREIGN KEY (guests_id) REFERENCES guests(guests_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id)
);

CREATE TABLE stay_bills (
    bill_id VARCHAR(5) PRIMARY KEY,
    booking_id VARCHAR(4),
    checkout_date DATETIME NOT NULL,
    room_charge FLOAT NOT NULL,
    extra_charge FLOAT,
    total_charge FLOAT NOT NULL,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

CREATE TABLE payments (
    payment_id VARCHAR(4) PRIMARY KEY,
    booking_id VARCHAR(4),
    amount INT,
    payment_date DATETIME NOT NULL,
    method VARCHAR(50),

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
);

