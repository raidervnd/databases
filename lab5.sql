/* 1. �������� ������� �����. */
ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_booking_id_booking
FOREIGN KEY(id_booking) REFERENCES booking(id_booking)

ALTER TABLE room_in_booking
ADD CONSTRAINT fk_room_in_booking_room_id_room
FOREIGN KEY(id_room) REFERENCES room(id_room)

ALTER TABLE booking
ADD CONSTRAINT fk_booking_client_id_client
FOREIGN KEY(id_client) REFERENCES client(id_client)

ALTER TABLE room
ADD CONSTRAINT fk_room_hotel_id_hotel
FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel)

ALTER TABLE room
ADD CONSTRAINT fk_room_room_category_id_room_category
FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category)


/* 2. ������ ���������� � �������� ��������� �������, ����������� � ������� ��������� ����� �� 1 ������ 2019�. */
SELECT client.name,
       room_in_booking.checkin_date,
	   room_in_booking.checkout_date
FROM room_in_booking 
JOIN room ON room_in_booking.id_room = room.id_room
JOIN room_category ON room.id_room_category = room_category.id_room_category
JOIN hotel ON room.id_hotel = hotel.id_hotel
JOIN booking ON room_in_booking.id_booking = booking.id_booking
JOIN client ON booking.id_client = client.id_client
WHERE room_in_booking.checkin_date <= '2019-04-01' 
      and room_in_booking.checkout_date >= '2019-04-01'
	  and room_category.name = '����'
	  and hotel.name = '������' 

/* 3. ���� ������ ��������� ������� ���� �������� �� 22 ������. */
SELECT room_in_booking.id_room_in_booking, room.number, hotel.name 
FROM room_in_booking
RIGHT JOIN room ON room_in_booking.id_room = room.id_room
LEFT JOIN hotel ON room.id_hotel = hotel.id_hotel
WHERE (room_in_booking.id_room IS NULL) OR (room_in_booking.checkin_date > '2019-04-22') or (room_in_booking.checkout_date <= '2019-04-22')
ORDER BY hotel.name


/* 4. ���� ���������� ����������� � ��������� ������� �� 23 ����� �� ������ ��������� ������� */
SELECT room_category.name, count(room_in_booking.id_room_in_booking) as clients
FROM room_in_booking
JOIN room ON room_in_booking.id_room = room.id_room
JOIN room_category ON room.id_room_category = room_category.id_room_category
JOIN hotel ON room.id_hotel = hotel.id_hotel
WHERE (hotel.name = '������') and (room_in_booking.checkin_date <= '2019-03-23') and (room_in_booking.checkout_date > '2019-03-23')
GROUP BY room_category.name

/* 5. ���� ������ ��������� ����������� �������� �� ���� �������� ��������� �������, ��������� � ������ � ��������� ���� ������. */
SELECT distinct tableLastClient.id_room, tableLastClient.checkout_date, client.name
FROM room
RIGHT JOIN (SELECT room_in_booking.id_room, MAX(room_in_booking.checkout_date) checkout_date
           FROM room_in_booking
		   JOIN room ON room_in_booking.id_room = room.id_room
		   JOIN hotel ON room.id_hotel = hotel.id_hotel
		   WHERE hotel.id_hotel = 1 AND MONTH(room_in_booking.checkout_date) = 4
           GROUP BY room_in_booking.id_room
           ) AS tableLastClient ON room.id_room = tableLastClient.id_room 
LEFT JOIN room_in_booking ON room_in_booking.id_room = tableLastClient.id_room AND room_in_booking.checkout_date = tableLastClient.checkout_date
LEFT JOIN booking ON room_in_booking.id_booking = booking.id_booking 
LEFT JOIN client ON client.id_client = booking.id_client

/* 6. �������� �� 2 ��� ���� ���������� � ��������� "������" ���� �������� ������ ��������� �������, ������� ���������� 10 ���. */
UPDATE
    room_in_booking
SET room_in_booking.checkout_date = DATEADD(DAY, 2, room_in_booking.checkout_date)
FROM room_in_booking
JOIN room ON room_in_booking.id_room = room.id_room
JOIN room_category ON room.id_room_category = room_category.id_room_category
JOIN hotel ON room.id_hotel = hotel.id_hotel
WHERE (hotel.id_hotel = 1 and room_category.name = '������') and (room_in_booking.checkout_date = '2019-05-10')

/* 7. ����� ��� "��������������" �������� ����������. */

SELECT * FROM room_in_booking r1
INNER JOIN room_in_booking r2 ON r1.id_room = r2.id_room 
WHERE (r1.checkin_date BETWEEN r2.checkin_date and r2.checkout_date) and (r1.checkout_date < r2.checkout_date) 
      and (r1.id_room_in_booking != r2.id_room_in_booking)

/* 8. ������� ������������ � ���������� */
BEGIN TRANSACTION

INSERT INTO client(name, phone)
VALUES ('������� �����', 89600931881)
INSERT INTO booking
VALUES ((SELECT TOP 1 client.id_client FROM client WHERE client.name = '������� �����'), GETDATE())

/*SELECT * from booking where booking.id_client = (SELECT client.id_client from client where client.name = '������� �����')*/
INSERT INTO room_in_booking
VALUES ((SELECT TOP 1 booking.id_booking FROM booking WHERE booking.id_client = 
		   (SELECT top 1 client.id_client from client where client.name = '������� �����')), 88, GETDATE(), DATEADD(DAY, 4, GETDATE()))
/*select * from room_in_booking where room_in_booking.id_booking = 2005*/
COMMIT;

/* 9. ������� ������� */
CREATE INDEX room_category_name_idx
ON room_category(name)

CREATE INDEX room_in_booking_checkin_date_idx
ON room_in_booking(checkin_date)

CREATE INDEX room_in_booking_id_room_idx
ON room_in_booking(id_room)

CREATE INDEX booking_id_client_idx
ON booking(id_client)
