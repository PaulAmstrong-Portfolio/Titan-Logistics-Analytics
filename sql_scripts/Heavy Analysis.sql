
/* 1. The Route Profitability Engine: Which transportation lanes are making the most money, 
and which ones are losing money once we factor in variable operational costs like fuel?*/
SELECT 
    r.route_id,
    r.origin_city + ', ' + r.origin_state AS Origin,
    r.destination_city + ', ' + r.destination_state AS Destination,
    COUNT(DISTINCT t.trip_id) AS Total_Trips_Completed,
    SUM(l.revenue + ISNULL(l.fuel_surcharge, 0) + ISNULL(l.accessorial_charges, 0)) AS Gross_Revenue,
    SUM(ISNULL(f.Total_Fuel_Cost, 0)) AS Total_Fuel_Cost,
    -- Net Profit = Gross Revenue - Fuel Cost
    SUM(l.revenue + ISNULL(l.fuel_surcharge, 0) + ISNULL(l.accessorial_charges, 0)) - SUM(ISNULL(f.Total_Fuel_Cost, 0)) AS Net_Profit,
    -- Profit per Mile
    (SUM(l.revenue + ISNULL(l.fuel_surcharge, 0) + ISNULL(l.accessorial_charges, 0)) - SUM(ISNULL(f.Total_Fuel_Cost, 0))) / NULLIF(SUM(t.actual_distance_miles), 0) AS Net_Profit_Per_Mile
FROM routes r
INNER JOIN loads l ON r.route_id = l.route_id
INNER JOIN trips t ON l.load_id = t.load_id
LEFT JOIN (
    SELECT trip_id, SUM(total_cost) AS Total_Fuel_Cost
    FROM fuel_purchases
    GROUP BY trip_id
) f ON t.trip_id = f.trip_id
WHERE t.trip_status = 'Completed'
GROUP BY r.route_id, r.origin_city, r.origin_state, r.destination_city, r.destination_state
ORDER BY Net_Profit_Per_Mile DESC;

/* 2. The Business Problem: Which truck manufacturing makes or specific models cost more 
to maintain than the revenue they bring in?*/
SELECT 
    tr.make + '-' + CAST(tr.model_year AS VARCHAR(10)) AS Group_UID, -- The unique ID for Power BI relationships!
    tr.make AS Truck_Brand,
    tr.model_year AS Model_Year,
    COUNT(DISTINCT tr.truck_id) AS Active_Fleet_Count,
    SUM(DISTINCT u.total_revenue) AS Total_Revenue_Generated,
    SUM(m.total_cost) AS Total_Maintenance_Cost,
    SUM(m.downtime_hours) AS Total_Downtime_Hours,
    -- Maintenance Cost Ratio
    (SUM(m.total_cost) / NULLIF(SUM(DISTINCT u.total_revenue), 0)) * 100 AS Maintenance_To_Revenue_Percent
FROM trucks tr
LEFT JOIN maintenance_records m ON tr.truck_id = m.truck_id
LEFT JOIN truck_utilization_metrics u ON tr.truck_id = u.truck_id
GROUP BY tr.make, tr.model_year
ORDER BY Maintenance_To_Revenue_Percent DESC;

/*Question 3: The Operational Efficiency (OTD) Tracker
The Business Problem: What is our true On-Time Delivery (OTD) percentage across different logistics hubs 
and facilities, and where are the primary bottlenecks?*/
SELECT 
    f.facility_id,
    f.facility_name AS Hub_Name,
    f.facility_type AS Hub_Type,
    COUNT(de.event_id) AS Total_Handled_Events,
    SUM(de.detention_minutes) AS Total_Detention_Minutes,
    -- Calculate OTD Rate
    AVG(CAST(de.on_time_flag AS FLOAT)) * 100 AS On_Time_Delivery_Rate
FROM facilities f
INNER JOIN delivery_events de ON f.facility_id = de.facility_id
WHERE de.event_type = 'Delivery'
GROUP BY f.facility_id, f.facility_name, f.facility_type
ORDER BY Total_Handled_Events ASC; -- Shows worst performing facilities first



Select*
FRom delivery_events

/* 4. The Business Problem: Are certain states or seasons inherently more dangerous to operate in, 
resulting in higher crash or insurance damage claims? */
SELECT 
    location_state AS Accident_State,
    YEAR(incident_date) AS Operating_Year,
    COUNT(incident_id) AS Incident_Count,
    SUM(CAST(at_fault_flag AS INT)) AS At_Fault_Count,
    SUM(vehicle_damage_cost) AS Vehicle_Damage_Overhead,
    SUM(cargo_damage_cost) AS Cargo_Loss_Overhead,
    SUM(claim_amount) AS Total_Insurance_Claims
FROM safety_incidents
GROUP BY location_state, YEAR(incident_date)
ORDER BY Total_Insurance_Claims DESC;

SELECT 
    location_state + '-' + CAST(YEAR(incident_date) AS VARCHAR(10)) AS Risk_UID, -- Your unique group ID for Power BI!
    location_state AS Accident_State,
    YEAR(incident_date) AS Operating_Year,
    COUNT(incident_id) AS Incident_Count,
    SUM(CASE WHEN at_fault_flag = 'True' THEN 1 ELSE 0 END) AS At_Fault_Count, -- Handled bit/string flag conversions cleanly
    SUM(vehicle_damage_cost) AS Vehicle_Damage_Overhead,
    SUM(cargo_damage_cost) AS Cargo_Loss_Overhead,
    SUM(claim_amount) AS Total_Insurance_Claims
FROM safety_incidents
GROUP BY location_state, YEAR(incident_date)
ORDER BY Total_Insurance_Claims DESC;