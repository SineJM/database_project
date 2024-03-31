-- Drop
DROP TABLE IF EXISTS database_project.Venues CASCADE;
DROP TABLE IF EXISTS database_project.customers CASCADE;
DROP TABLE IF EXISTS database_project.events CASCADE;
DROP TABLE IF EXISTS database_project.Reservations CASCADE;
DROP TABLE IF EXISTS database_project.Event_host CASCADE;
DROP TABLE IF EXISTS database_project.seats;
DROP TABLE IF EXISTS database_project.payments;
DROP TABLE IF EXISTS database_project.ShowTimes;


-- Create Venues table
CREATE TABLE database_project.Venues (
   VenueID SERIAL PRIMARY KEY,
   Name VARCHAR(255) NOT NULL,
   Location VARCHAR(255) NOT NULL,
   Capacity INTEGER NOT NULL,
   GoogleMapsLink VARCHAR(255)
);


-- Insert sample data into Venues table
INSERT INTO database_project.Venues (Name, Location, Capacity,GoogleMapsLink)
VALUES
   ('Impact Muang Thong Thani', 'Bangkok', 10000, 'https://www.google.com/maps?q=Impact+Muang+Thong+Thani'),
   ('Impact Challenger Hall 1', 'Bangkok', 8000, 'https://www.google.com/maps?q=Impact+Challenger+Hall+1'),
   ('Thunder Dome', 'Bangkok', 12000, 'https://www.google.com/maps?q=Thunder+Dome'),
   ('Queen Sirikit National Convention Center', 'Bangkok', 15000, 'https://www.google.com/maps?q=Queen+Sirikit+National+Convention+Center'),
   ('BITEC Bangna', 'Bangkok', 15000, 'https://www.google.com/maps?q=BITEC+Bangna'),
   ('Chang Arena', 'Buriram', 30000, 'https://www.google.com/maps?q=Chang+Arena'),
   ('CentralPlaza WestGate', 'Nonthaburi', 20000, 'https://www.google.com/maps?q=CentralPlaza+WestGate'),
   ('CentralPlaza Lardprao', 'Bangkok', 25000, 'https://www.google.com/maps?q=CentralPlaza+Lardprao');


-- Create Sellers table
CREATE TABLE database_project.Event_host(
   HostID SERIAL PRIMARY KEY,
   FirstName VARCHAR(100) NOT NULL,
   LastName VARCHAR(100) NOT NULL,
   Email VARCHAR(255) NOT NULL UNIQUE,
   Phone VARCHAR(20) NOT NULL,
   CompanyName VARCHAR(255),
   Address TEXT,
   TotalTicketsSold INTEGER DEFAULT 0,
   TotalRevenue DECIMAL(10, 2) DEFAULT 0.00
);


-- Insert sample data into Sellers table
INSERT INTO database_project.Event_host (FirstName, LastName, Email, Phone, CompanyName, Address)
VALUES
   ('John', 'Doe', 'john.doe@example.com', '+1234567890', 'XYZ Productions', '123 Main St, City'),
   ('Jane', 'Smith', 'jane.smith@example.com', '+1987654321', 'ABC Events', '456 Elm St, Town'),
   ('Tan', 'Bun', 'tan.bun@example.com', '+1234567890', 'XYZ Productions', '123 Main St, City'),
   ('San', 'Sum', 'san.sum@example.com', '+1987654321', 'ABC Events', '456 Elm St, Town'),
   ('Michael', 'Brown', 'michael.brown@example.com', '+1122334455', 'EFG Productions', '789 Oak St, City'),
   ('Emma', 'Garcia', 'emma.garcia@example.com', '+9988776655', 'LMN Events', '321 Maple Ave, Town');


-- Create Events table
CREATE TABLE database_project.Events (
   EventID SERIAL PRIMARY KEY,
   Name VARCHAR(255) NOT NULL,
   VenueID INTEGER NOT NULL REFERENCES database_project.Venues(VenueID),
   HostID INTEGER NOT NULL REFERENCES database_project.Event_host(HostID),
   Date DATE NOT NULL CHECK (Date > CURRENT_DATE),  -- Date should be in the future
   Time TIME NOT NULL,
   AvailableSeats INTEGER NOT NULL CHECK (AvailableSeats >= 0),
   PricePerTicket DECIMAL(10, 2) NOT NULL CHECK (PricePerTicket >= 0),
   CONSTRAINT unique_event UNIQUE (EventID, Date, Time) -- Unique combination of EventID, Date, and Time
);


-- Insert sample data into Events table
INSERT INTO database_project.Events (Name, VenueID, HostID, Date, Time, AvailableSeats, PricePerTicket)
VALUES
   ('Summer Sonic Bangkok', 1, 1, '2024-08-24', '16:00', 2000, 5000),
   ('IU concert H.E.R. World Tour', 2, 2, '2024-06-29', '17:00', 8000, 2500),
   ('Ed Sheeran: Divide Tour', 3, 3, '2024-11-20', '19:00', 10000, 1800),
   ('Blackpink: The Show', 4, 4, '2024-10-05', '20:00', 12000, 2500),
   ('Justin Bieber: Purpose Tour', 1, 5, '2024-09-15', '18:00', 5000, 2000),
   ('Coldplay: A Head Full of Dreams Tour', 2, 6, '2024-07-10', '19:30', 15000, 3000),
   ('Bruno Mars: 24K Magic World Tour', 7, 1, '2024-12-01', '20:30', 10000, 3500),
   ('Ariana Grande: Sweetener World Tour', 8, 2, '2024-07-25', '19:00', 12000, 2800);


-- Create Customers table
CREATE TABLE database_project.Customers (
   CustomerID SERIAL PRIMARY KEY,
   FirstName VARCHAR(100) NOT NULL,
   LastName VARCHAR(100) NOT NULL,
   Gender VARCHAR(10) DEFAULT 'Unknown',
   Birthday DATE,
   Email VARCHAR(255) NOT NULL UNIQUE,
   Phone VARCHAR(20) NOT NULL,
   Address TEXT
);


-- Create Reservations table
CREATE TABLE database_project.Reservations (
   ReservationID SERIAL PRIMARY KEY,
   CustomerID INTEGER NOT NULL REFERENCES database_project.Customers(CustomerID),
   HostID INTEGER NOT NULL REFERENCES database_project.Event_host(HostID),
   EventID INTEGER NOT NULL REFERENCES database_project.Events(EventID),
   NumTickets INTEGER NOT NULL CHECK (NumTickets > 0),
   TotalPrice DECIMAL(10, 2) NOT NULL CHECK (TotalPrice >= 0),
   ReservationDate DATE NOT NULL DEFAULT CURRENT_DATE
);


-- Create Seats table
CREATE TABLE database_project.Seats (
   SeatID SERIAL PRIMARY KEY,
   EventID INTEGER REFERENCES database_project.Events(EventID),
   SeatNumber VARCHAR(20) NOT NULL,
   Status VARCHAR(20) NOT NULL
);


-- Create Payments table
CREATE TABLE database_project.Payments (
   PaymentID SERIAL PRIMARY KEY,
   ReservationID INTEGER REFERENCES database_project.Reservations(ReservationID),
   Amount DECIMAL(10, 2) NOT NULL,
   PaymentDate DATE NOT NULL DEFAULT CURRENT_DATE,
   PaymentMethod VARCHAR(50) NOT NULL,
   TransactionID VARCHAR(100) UNIQUE,
   Status VARCHAR(20) NOT NULL
);


-- Create ShowTimes table
CREATE TABLE database_project.ShowTimes (
   ShowtimeID SERIAL PRIMARY KEY,
   EventID INTEGER REFERENCES database_project.Events(EventID),
   Date DATE NOT NULL,
   Time TIME NOT NULL,
   Capacity INTEGER NOT NULL,
   FOREIGN KEY (EventID, Date, Time) REFERENCES database_project.Events(EventID, Date, Time)
);


-- SQL Function to reserve tickets
CREATE OR REPLACE FUNCTION reserve_tickets(p_customer_id INTEGER, p_event_id INTEGER, p_num_tickets INTEGER)
RETURNS VOID AS $$
DECLARE
   v_price DECIMAL(10, 2);
   v_host_id INTEGER;
BEGIN
   -- Check if the provided event ID exists and get the seller ID
   SELECT PricePerTicket, HostID INTO v_price, v_host_id
   FROM database_project.Events WHERE EventID = p_event_id;

   IF NOT FOUND THEN
       RAISE EXCEPTION 'Event with ID % does not exist', p_event_id;
   END IF;

   -- Decrease available seats for the event
   UPDATE database_project.Events
   SET AvailableSeats = AvailableSeats - p_num_tickets
   WHERE EventID = p_event_id;

   -- Calculate total price
   INSERT INTO database_project.Reservations (CustomerID, HostID, EventID, NumTickets, TotalPrice, ReservationDate)
   VALUES (p_customer_id, v_host_id, p_event_id, p_num_tickets, p_num_tickets * v_price, CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;


-- SQL Function to cancel reservation
CREATE OR REPLACE FUNCTION cancel_reservation(p_reservation_id INTEGER)
RETURNS VOID AS $$
DECLARE
   v_event_id INTEGER; v_num_tickets INTEGER;
BEGIN
   -- Get event ID and number of tickets for the reservation
   SELECT EventID, NumTickets INTO v_event_id, v_num_tickets
   FROM database_project.Reservations
   WHERE ReservationID = p_reservation_id;
   IF NOT FOUND THEN RAISE EXCEPTION 'Reservation with ID % does not exist', p_reservation_id; END IF;

   -- Increase available seats for the event
   UPDATE database_project.Events
   SET AvailableSeats = AvailableSeats + v_num_tickets
   WHERE EventID = v_event_id;

   -- Delete reservation
   DELETE FROM database_project.Reservations
   WHERE ReservationID = p_reservation_id;
END;
$$ LANGUAGE plpgsql;


-- Insert sample data into Customers table
INSERT INTO database_project.Customers (FirstName, LastName, Gender, Birthday, Email, Phone, Address)
VALUES
   ('Peter', 'Parker', 'Male', '1990-05-10', 'peter.parker@example.com', '+1234567890', '123 Main St, City'),
   ('Jane', 'Smith', 'Female', '1985-08-20', 'jane.smith@example.com', '+1987654321', '456 Silom St, Town'),
   ('Alice', 'Johnson', 'Female', '1992-03-15', 'alice.johnson@example.com', '+1122334455', '789 Chatuchak St, City'),
   ('Bob', 'Williams', 'Male', '1978-11-25', 'bob.williams@example.com', '+9988776655', '321 Ratchada Ave, Town'),
   ('Sarah', 'Davis', 'Female', '1989-12-05', 'sarah.davis@example.com', '+1234567890', '123 Silom St, City'),
   ('Chris', 'Martinez', 'Male', '1995-07-18', 'chris.martinez@example.com', '+1987654321', '456 Sukhumvit Ave, Town'),
   ('James', 'Bone', 'Male', '1982-04-06', 'james.bone@example.com', '+1987334321', '729 Sukhumvit St, City'),
   ('Frank', 'Jones', 'Male', '1988-10-22', 'frank.jones@example.com', '+9456876655', '321 Chatuchak Ave, Town'),
   ('Rose', 'Mary', 'Female', '1989-12-05', 'rose.mary@example.com', '+1234852890', '123 Ratchaprasong St, City'),
   ('Paul', 'Mars', 'Male', '1995-07-18', 'paul.mars@example.com', '+1984854321', '456 Thonglor Ave, Town');


-- Insert sample data into Reservations table
INSERT INTO database_project.Reservations (CustomerID, EventID, HostID, NumTickets, TotalPrice, ReservationDate)
VALUES
   (1, 1, 1, 2, 100.00, '2024-03-27'),
   (2, 2, 2, 3, 30.00, '2024-03-28'),
   (3, 3, 3, 4, 6000.00, '2024-03-29'),
   (4, 4, 4, 2, 4000.00, '2024-03-30'),
   (5, 5, 5, 3, 6000.00,- '2024-04-01'),
   (6, 6, 6, 4, 12000.00, '2024-04-02'),
   (1, 7, 1, 2, 7000.00, '2024-04-03'),
   (2, 8, 2, 3, 8400.00, '2024-04-04');


-- Insert sample data into Seats table
INSERT INTO database_project.Seats (EventID, SeatNumber, Status)
VALUES
   (1, 'A1', 'Available'),
   (1, 'A2', 'Available'),
   (1, 'B1', 'Reserved'),
   (2, 'C1', 'Available'),
   (2, 'C2', 'Available'),
   (2, 'D1', 'Reserved'),
   (3, 'A1', 'Available'),
   (3, 'A2', 'Available'),
   (3, 'B1', 'Available'),
   (3, 'B2', 'Available'),
   (4, 'C1', 'Reserved'),
   (4, 'C2', 'Reserved'),
   (5, 'A1', 'Available'),
   (5, 'A2', 'Reserved'),
   (5, 'B1', 'Available'),
   (5, 'B2', 'Available'),
   (6, 'A1', 'Available'),
   (6, 'A2', 'Reserved'),
   (6, 'B1', 'Available'),
   (6, 'B2', 'Available'),
   (7, 'A1', 'Available'),
   (7, 'A2', 'Available'),
   (7, 'B1', 'Reserved'),
   (8, 'C1', 'Available'),
   (8, 'C2', 'Available'),
   (8, 'D1', 'Reserved');


-- Insert sample data into Payments table
INSERT INTO database_project.Payments (ReservationID, Amount, PaymentDate, PaymentMethod, TransactionID, Status)
VALUES
   (1, 100.00, '2024-03-27', 'Credit Card', 'TXN123456', 'Completed'),
   (2, 30.00, '2024-03-28', 'PayPal', 'TXN789012', 'Completed'),
   (3, 6000.00, '2024-03-29', 'Credit Card', 'TXN246810', 'Completed'),
   (4, 4000.00, '2024-03-30', 'PayPal', 'TXN3691215', 'Completed'),
   (5, 6000.00, '2024-04-01', 'Credit Card', 'TXN567890', 'Completed'),
   (6, 12000.00, '2024-04-02', 'PayPal', 'TXN678901', 'Completed'),
   (7, 7000.00, '2024-04-03', 'Credit Card', 'TXN910111', 'Completed'),
   (8, 8400.00, '2024-04-04', 'PayPal', 'TXN121314', 'Completed');


-- Insert sample data into ShowTimes table
INSERT INTO database_project.ShowTimes (EventID, Date, Time, Capacity)
VALUES
   (1, '2024-08-24', '16:00', 2000),
   (2, '2024-06-29', '17:00', 8000),
   (3, '2024-11-20', '19:00', 10000),
   (4, '2024-10-05', '20:00', 12000),
   (5, '2024-09-15', '18:00', 5000),
   (6, '2024-07-10', '19:30', 15000),
   (7, '2024-12-01', '20:30', 10000),
   (8, '2024-07-25', '19:00', 12000);


-- Update TotalTicketsSold and TotalRevenue for each Event Host!
UPDATE database_project.Event_host AS eh
SET TotalTicketsSold = (
        SELECT COALESCE(SUM(r.NumTickets), 0)
        FROM database_project.Reservations AS r
        WHERE r.HostID = eh.HostID
    ),
    TotalRevenue = (
        SELECT COALESCE(SUM(r.TotalPrice), 0)
        FROM database_project.Reservations AS r
        WHERE r.HostID = eh.HostID
    )
WHERE eh.HostID IN (
        SELECT DISTINCT HostID
        FROM database_project.Reservations
    );


