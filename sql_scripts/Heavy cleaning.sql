SELECT 'Drivers' AS TableName, COUNT(*) AS TotalRows FROM drivers -- 1. ROW COUNT AUDIT
UNION ALL SELECT 'Trucks', COUNT(*) FROM trucks
UNION ALL SELECT 'Trailers', COUNT(*) FROM trailers
UNION ALL SELECT 'Customers', COUNT(*) FROM customers
UNION ALL SELECT 'Facilities', COUNT(*) FROM facilities
UNION ALL SELECT 'Routes', COUNT(*) FROM routes
UNION ALL SELECT 'Loads', COUNT(*) FROM loads
UNION ALL SELECT 'Trips', COUNT(*) FROM trips
UNION ALL SELECT 'Fuel_Purchases', COUNT(*) FROM fuel_purchases
UNION ALL SELECT 'Maintenance', COUNT(*) FROM maintenance_records
UNION ALL SELECT 'Delivery_Events', COUNT(*) FROM delivery_events
UNION ALL SELECT 'Safety', COUNT(*) FROM safety_incidents
UNION ALL SELECT 'Driver_Monthly', COUNT(*) FROM driver_monthly_metrics
UNION ALL SELECT 'Truck_Monthly', COUNT(*) FROM truck_utilization_metrics

-- 2 Checked for Trips without a valid Driver
SELECT 'Orphan Trips (No Driver)' AS Issue, COUNT(*) AS Count 
FROM trips
LEFT JOIN drivers ON trips.driver_id = drivers.driver_id
WHERE drivers.driver_id IS NULL

UNION ALL

SELECT 'Orphan Trips (No Truck)' AS Issue, COUNT(*) AS Count 
FROM trips
LEFT JOIN trucks ON trips.truck_id = trucks.truck_id
WHERE trucks.truck_id IS NULL;

-- NO 2&4 FIX
-- Adding a 'Default' entry to the master tables so the "orphans data" have a parent
INSERT INTO drivers (driver_id, first_name, last_name) VALUES ('DRV99999', 'Unknown', 'Driver');
INSERT INTO trucks (truck_id, make) VALUES ('TRK99999', 'Unknown');

-- Explanation: We create these '99999' IDs so that every record in the database 
-- has a valid connection. This is a standard practice in Data Warehousing.

-- Fixed the Orphan Trips (Trips IDs without a valid driver and truck)
UPDATE trips 
SET driver_id = 'DRV99999' 
WHERE driver_id NOT IN (SELECT driver_id FROM drivers)

UPDATE trips 
SET truck_id = 'TRK99999' 
WHERE truck_id NOT IN (SELECT truck_id FROM trucks)

select*
from fuel_purchases

-- NO 3 Checked for Loads without a valid Route
SELECT 'No Trips' AS Issue, Count(*) 
FROM loads
LEFT JOIN routes ON loads.route_id = routes.route_id
Where routes.route_id IS NULL

-- Fixed Driver IDs that had blank spaces that came with the original data
UPDATE fuel_purchases
SET driver_id = NULL
WHERE TRIM(driver_id) = '';

-- Fixed Truck IDs that had blank spaces that came with the original data
UPDATE fuel_purchases
SET truck_id = NULL
WHERE TRIM(truck_id) = ''

-- 4. CRITICAL NULL CHECK (Confirming The "NULLS" in Fuel_PURCHASE)
SELECT 'Fuel Records Missing Truck ID' AS Issue, COUNT(*) AS 'Count' 
FROM fuel_purchases 
WHERE truck_id IS NULL
UNION ALL
SELECT 'Fuel Records Missing Driver ID', COUNT(*) 
FROM fuel_purchases 
WHERE driver_id IS NULL

-- Fixed Orphan Data
UPDATE fuel_purchases SET truck_id = 'TRK99999' WHERE truck_id IS NULL;
UPDATE fuel_purchases SET driver_id = 'DRV99999' WHERE driver_id IS NULL;

-- 5 checked if the Trucks and Driver ids are also missing from other tables
SELECT 'Orphan MaintRecord (No truck)' AS Issue, COUNT(*) AS Count 
FROM maintenance_records
LEFT JOIN trucks ON maintenance_records.truck_id = trucks.truck_id
WHERE trucks.truck_id IS NULL

UNION ALL

SELECT 'Orphan Incident (No Truck)' AS Issue, COUNT(*) AS Count 
FROM safety_incidents
LEFT JOIN trucks ON safety_incidents.truck_id = trucks.truck_id
WHERE trucks.truck_id IS NULL;

SELECT 'Orphan Incident (No driver)' AS Issue, COUNT(*) AS Count 
FROM safety_incidents
LEFT JOIN drivers ON safety_incidents.driver_id = drivers.driver_id
WHERE drivers.driver_id IS NULL;

SELECT 'Orphan DMM (No driver)' AS Issue, COUNT(*) AS Count 
FROM driver_monthly_metrics
LEFT JOIN drivers ON driver_monthly_metrics.driver_id = drivers.driver_id
WHERE drivers.driver_id IS NULL;

SELECT 'Orphan TUM (No Truck)' AS Issue, COUNT(*) AS Count 
FROM truck_utilization_metrics
LEFT JOIN trucks ON truck_utilization_metrics.truck_id = trucks.truck_id
WHERE trucks.truck_id IS NULL;

SELECT load_id, weight_lbs, revenue 
FROM loads 
WHERE weight_lbs < 0 OR revenue <= 0;

SELECT maintenance_id, labor_cost, parts_cost, total_cost, 
      (labor_cost + parts_cost) AS calculated_total
FROM maintenance_records
WHERE ABS((labor_cost + parts_cost) - total_cost) > 1.00;

-- 5 Explanation: Finds records where a truck arrived before it left (impossible).
SELECT p.trip_id, p.actual_datetime AS Pickup, d.actual_datetime AS Delivery
FROM delivery_events p
JOIN delivery_events d ON p.trip_id = d.trip_id
WHERE p.event_type = 'Pickup' AND d.event_type = 'Delivery'
AND d.actual_datetime < p.actual_datetime;
-- FIX
-- STEP 1: Update the delivery events table by joining it with the trips table 
-- and adding the precise trip duration to the pickup timestamp.
WITH TimeFix AS (
    SELECT 
        d_ev.event_id AS DeliveryEventID,
        p_ev.actual_datetime AS PickupTime,
        t.actual_duration_hours AS Duration
    FROM delivery_events d_ev
    INNER JOIN delivery_events p_ev ON d_ev.trip_id = p_ev.trip_id
    INNER JOIN trips t ON d_ev.trip_id = t.trip_id
    WHERE p_ev.event_type = 'Pickup' 
      AND d_ev.event_type = 'Delivery'
      AND d_ev.actual_datetime < p_ev.actual_datetime
)
UPDATE de
SET de.actual_datetime = DATEADD(MINUTE, CAST(tf.Duration * 60 AS INT), tf.PickupTime)
FROM delivery_events de
INNER JOIN TimeFix tf ON de.event_id = tf.DeliveryEventID;





