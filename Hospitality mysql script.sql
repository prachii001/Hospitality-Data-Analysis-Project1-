# total revenue
SELECT SUM(revenue_realized) AS Total_Revenue
FROM fact_bookings;

#Occupancy rate
SELECT SUM(successful_bookings) * 100.0 / SUM(capacity) AS Occupancy_Rate
FROM fact_aggregated_bookings;

#Cancellation Rate
SELECT COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_bookings) AS Cancellation_Rate
FROM fact_bookings
WHERE booking_status = 'Cancelled';

#Total Bookings
SELECT COUNT(*) AS Total_Bookings
FROM fact_bookings;

#Utilized Capacity
SELECT SUM(successful_bookings) AS Utilized_Capacity,
SUM(capacity) AS Total_Capacity,
SUM(successful_bookings) * 100.0 / SUM(capacity) AS Utilization_Percentage
FROM fact_aggregated_bookings;

#Trend Analysis (Daily Revenue)
SELECT booking_date, SUM(revenue_realized) AS Daily_Revenue
FROM fact_bookings
GROUP BY booking_date
ORDER BY booking_date;

#Weekday & Weekend Revenue and Bookings
SELECT 
    CASE 
        WHEN DAYOFWEEK(check_in_date) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(revenue_realized) AS Revenue,
    COUNT(*) AS Total_Bookings
FROM fact_bookings
GROUP BY Day_Type;

#Revenue by State & Hotel
SELECT 
    h.city, h.property_name, SUM(b.revenue_realized) AS Revenue
FROM fact_bookings b
JOIN dim_hotels h ON b.property_id = h.property_id
GROUP BY h.city, h.property_name
ORDER BY h.city, Revenue DESC;

#Class-Wise Revenue
SELECT 
    room_category, SUM(revenue_realized) AS Revenue
FROM fact_bookings
GROUP BY room_category
ORDER BY Revenue DESC;

#Checked Out, Cancelled, No-Show Counts
SELECT 
    booking_status, COUNT(*) AS Count
FROM fact_bookings
GROUP BY booking_status;

#Weekly Trends (Revenue, Bookings, Occupancy)
SELECT 
    STR_TO_DATE(b.check_in_date, '%d-%m-%Y') AS Date,
    YEAR(STR_TO_DATE(b.check_in_date, '%d-%m-%Y')) AS Year, 
    WEEK(STR_TO_DATE(b.check_in_date, '%d-%m-%Y'), 1) AS Week_Number,  
    SUM(b.revenue_realized) AS Weekly_Revenue, 
    COUNT(b.booking_id) AS Weekly_Bookings,  
    ROUND(SUM(a.successful_bookings) * 100.0 / NULLIF(SUM(a.capacity), 0), 2) AS Weekly_Occupancy  
FROM fact_bookings b
JOIN fact_aggregated_bookings a 
    ON b.property_id = a.property_id 
    AND STR_TO_DATE(b.check_in_date, '%d-%m-%Y') = STR_TO_DATE(a.check_in_date, '%d-%m-%Y') 
GROUP BY Year, Week_Number, Date
ORDER BY Year, Week_Number;




