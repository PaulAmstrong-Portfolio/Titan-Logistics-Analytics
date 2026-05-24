CREATE DATABASE "TITAN_LOGISTICS DB"

CREATE TABLE drivers (
    driver_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    hire_date VARCHAR(50),
    termination_date VARCHAR(50),
    license_number VARCHAR(50),
    license_state CHAR(2),
    date_of_birth VARCHAR(50),
    home_terminal VARCHAR(100),
    employment_status VARCHAR(20),
    cdl_class CHAR(1),
    years_experience INT
);

Select*
From drivers

ALTER TABLE DRIVERS
ALTER COLUMN  hire_date date /* Altering these column because SQL Import wizard failed to import these dates
from my original data into the Date data type, so i made the data type VARCHAR first to make importation
easy, then i altered it to a DATE data type once it was successfully imported*/

ALTER TABLE DRIVERS
ALTER COLUMN  hire_date date

ALTER TABLE DRIVERS
ALTER COLUMN  hire_date date

Update drivers
Set termination_date = null
Where termination_date = '1900-01-01'

CREATE TABLE trucks (
    truck_id VARCHAR(20) PRIMARY KEY,
    unit_number INT,
    make VARCHAR(50),
    model_year INT,
    vin VARCHAR(20),
    acquisition_date DATE,
    acquisition_mileage INT,
    fuel_type VARCHAR(20),
    tank_capacity_gallons INT,
    status VARCHAR(20),
    home_terminal VARCHAR(100)
    )

    CREATE TABLE trailers (
    trailer_id VARCHAR(20) PRIMARY KEY,
    trailer_number INT,
    trailer_type VARCHAR(50),
    length_feet INT,
    model_year INT,
    vin VARCHAR(20),
    acquisition_date DATE,
    status VARCHAR(20),
    current_location VARCHAR(100)
);

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_type VARCHAR(50),
    credit_terms_days INT,
    primary_freight_type VARCHAR(50),
    account_status VARCHAR(20),
    contract_start_date DATE,
    annual_revenue_potential DECIMAL(18, 2)
);

CREATE TABLE facilities (
    facility_id VARCHAR(20) PRIMARY KEY,
    facility_name VARCHAR(100),
    facility_type VARCHAR(50),
    city VARCHAR(50),
    state CHAR(2),
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    dock_doors INT,
    operating_hours VARCHAR(50) -- Kept as text for ranges like '24/7'
    )

    CREATE TABLE routes (
    route_id VARCHAR(20) PRIMARY KEY,
    origin_city VARCHAR(50),
    origin_state CHAR(2),
    destination_city VARCHAR(50),
    destination_state CHAR(2),
    typical_distance_miles INT,
    base_rate_per_mile DECIMAL(10, 2),
    fuel_surcharge_rate DECIMAL(10, 2),
    typical_transit_days INT
);

CREATE TABLE loads (
    load_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    route_id VARCHAR(20),
    load_date DATE,
    load_type VARCHAR(50),
    weight_lbs INT,
    pieces INT,
    revenue DECIMAL(18, 2),
    fuel_surcharge DECIMAL(18, 2),
    accessorial_charges DECIMAL(18, 2),
    load_status VARCHAR(20),
    booking_type VARCHAR(20)
);

CREATE TABLE trips (
    trip_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    driver_id VARCHAR(20),
    truck_id VARCHAR(20),
    trailer_id VARCHAR(20),
    dispatch_date DATE,
    actual_distance_miles INT,
    actual_duration_hours DECIMAL(10, 2),
    fuel_gallons_used DECIMAL(10, 2),
    average_mpg DECIMAL(10, 2),
    idle_time_hours DECIMAL(10, 2),
    trip_status VARCHAR(20)
);

CREATE TABLE fuel_purchases (
    fuel_purchase_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    purchase_date DATETIME,
    location_city VARCHAR(50),
    location_state CHAR(2),
    gallons DECIMAL(10, 2),
    price_per_gallon DECIMAL(10, 3),
    total_cost DECIMAL(18, 2),
    fuel_card_number VARCHAR(50)
);

CREATE TABLE maintenance_records (
    maintenance_id VARCHAR(20) PRIMARY KEY,
    truck_id VARCHAR(20),
    maintenance_date DATE,
    maintenance_type VARCHAR(50),
    odometer_reading INT,
    labor_hours DECIMAL(10, 2),
    labor_cost DECIMAL(18, 2),
    parts_cost DECIMAL(18, 2),
    total_cost DECIMAL(18, 2),
    facility_location VARCHAR(100),
    downtime_hours DECIMAL(10, 2),
    service_description VARCHAR(MAX)
);

CREATE TABLE delivery_events (
    event_id VARCHAR(20) PRIMARY KEY,
    load_id VARCHAR(20),
    trip_id VARCHAR(20),
    event_type VARCHAR(20),
    facility_id VARCHAR(20),
    scheduled_datetime DATETIME,
    actual_datetime DATETIME,
    detention_minutes INT,
    on_time_flag BIT, -- SQL BIT (1 for True, 0 for False)
    location_city VARCHAR(50),
    location_state CHAR(2)
    )

    CREATE TABLE safety_incidents (
    incident_id VARCHAR(20) PRIMARY KEY,
    trip_id VARCHAR(20),
    truck_id VARCHAR(20),
    driver_id VARCHAR(20),
    incident_date DATETIME,
    incident_type VARCHAR(50),
    location_city VARCHAR(50),
    location_state CHAR(2),
    at_fault_flag VARCHAR(50),
    injury_flag VARCHAR(50),
    vehicle_damage_cost DECIMAL(18, 2),
    cargo_damage_cost DECIMAL(18, 2),
    claim_amount DECIMAL(18, 2),
    preventable_flag VARCHAR(50),
    description VARCHAR(MAX)
    )


    CREATE TABLE driver_monthly_metrics (
    driver_id VARCHAR(20),
    "month" DATE,
    trips_completed INT,
    total_miles INT,
    total_revenue DECIMAL(18, 2),
    average_mpg DECIMAL(10, 2),
    total_fuel_gallons DECIMAL(10, 2),
    on_time_delivery_rate DECIMAL(5, 4),
    average_idle_hours DECIMAL(10, 2),
    PRIMARY KEY (driver_id, month)
);

CREATE TABLE truck_utilization_metrics (
    truck_id VARCHAR(20),
    month DATE,
    trips_completed INT,
    total_miles INT,
    total_revenue DECIMAL(18, 2),
    average_mpg DECIMAL(10, 2),
    maintenance_events INT,
    maintenance_cost DECIMAL(18, 2),
    downtime_hours DECIMAL(10, 2),
    utilization_rate DECIMAL(5, 4),
    PRIMARY KEY (truck_id, month)
);


