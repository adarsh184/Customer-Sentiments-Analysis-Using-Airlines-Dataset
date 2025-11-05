use project1;

select * from safety_log1;
select * from reviews1;
select * from flights1;
select * from bookings1;
select * from customers3;


# ---------------------------------------------      CUSTOMER SENTIMENTS ANALYSIS           -----------------------------------------------------#


# QUES 1. WHICH AIRLINE IS MOST POPULAR AMONG ALL THE AIRLINES ?

select airline ,count(airline) as total_counts from flights1 group by airline order by total_counts desc;

# ANS -- SO AKASA AIR IS MOSTLY PREFFERED BY USERS WITH THE TOTAL COUNT OF 76 . The reason of using akasa airlines by users we will be finding in the upcoming questions .


# QUES 2 HOW MANY AIRLINES MET AN ACCIDENT AND WHAT WERE THE REASONS ?

select * from safety_log1;

select airline,count(airline) as total_count from safety_log1 where incident_type = 'Accident' group by airline order by total_count desc limit 1;

# ANS -- SO SPICEJET WAS THE AIRLINE WHICH MET HIGHEST ACCIDENT AMONG ALL OTHER AIRLINES...


# QUES 3. WHAT ARE THE PERCENTAFE OF PEOPLE TRUSTING THE SPECIFIC AIRLINES AND WHAT WERE ITS POSSIBLE REASONS ?

select airline,recommend,count(recommend) as total_count from reviews1 inner join flights1 using(flight_id) group by 1,2 order by total_count desc limit 1;

# ANS -- SO AKASA AIRLINE IS THE MOST RECOMMENDABLE HENCE TRUSTABLE AIRLINE AMONG ALL OTHER AIRLINES 
#         POSSIBLE REASONS FOR THE TRUST ON IT ARE :
#													1> affordable and comfortable tour
#													2> safety ratio is much higher than others
#                                                   3> dynamic availability across the globe and in the country


# QUES 4. WHAT ARE THE THINGS IN WHICH THE MAJORITY OF CUSTOMERS ARE UNSATISFIED AND IN WHICH AIRLINE IT IS MOST COMMON ?

select count(distinct(seat_comfort)),count(distinct(cabin_staff_service)),count(distinct(food_and_beverages)) from reviews1 
inner join bookings1 using(booking_id) inner join flights2 using(airline);



# QUES 5. WHICH CITY GENRATED MOST OF THE REVENUE ?

SELECT from_city,COUNT(*) AS total_bookings
FROM bookings1
GROUP BY from_city
ORDER BY total_bookings DESC;

# ANS -- So London genrated most of the revenue by being the highest booking city ..

# QUES 6. WHICH CUSTOMER HAS BOOKED MOST OF THE SEATS ?

SELECT c.customer_id, c.customer_name, SUM(b.total_seat_booked) AS total_seats
FROM bookings1 b
INNER JOIN customers3 c ON b.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_seats DESC
LIMIT 10;

# ANS -- customer with customer id 1308	Chakradev Nath has the highest booking with 19 seats .

# QUES 7. WHAT ARE THE PEAK BOOKINGS MONTH ?

SELECT 
    CONCAT(EXTRACT(YEAR FROM booking_date), '-', LPAD(EXTRACT(MONTH FROM booking_date), 2, '0')) AS booking_month,
    COUNT(*) AS total_bookings
FROM bookings1
GROUP BY booking_month
ORDER BY total_bookings DESC;

# ANS -- so february month has a highest booking .

# QUES 8. WHICH CUSTOMER AGE GROUP HAVE MOST OF THE BOOKINGS ?


SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    COUNT(*) AS total_bookings
FROM (
    SELECT 
        b.booking_id,
        YEAR(CURDATE()) - YEAR(c.date_of_birth) 
            - (DATE_FORMAT(CURDATE(), '%m%d') < DATE_FORMAT(c.date_of_birth, '%m%d')) AS age
    FROM 
        bookings1 b
    JOIN 
        customers3 c ON b.customer_id = c.customer_id
) AS derived
GROUP BY 
    age_group
ORDER BY 
    total_bookings DESC;
    
    
# ANS -- AGE 50+ have most of the bookings.



# QUES 9. WHICH AIRPORT PAIRS ARE MOST FREQUENTLY BOOKED?

SELECT from_city,to_city,
COUNT(*) AS route_count
FROM bookings1
GROUP BY from_city, to_city
ORDER BY route_count DESC
LIMIT 10;

# ANS -- DELHI KOLKATA ROUTE IS MOST FREQUTNLY BOOKED.

# QUES 10. which airlines recieves the highest overall ratings ?

SELECT f.airline,
ROUND(AVG(r.overall_rating), 2) AS avg_rating
FROM reviews1 r
INNER JOIN flights1 f ON r.flight_id = f.flight_id
GROUP BY f.airline
ORDER BY avg_rating DESC;
    
# ANS -- AIR INDIA HAS HIGHEST AVERAGE RATING.


# QUES 11. WHICH FLIGHT CLASSES SCORES HIGHEST IN CABIN STAFF SERVICE ? 

SELECT f.class,
ROUND(AVG(r.cabin_staff_service), 2) AS avg_staff_score
FROM reviews1 r
INNER JOIN flights1 f ON r.flight_id = f.flight_id
GROUP BY f.class
ORDER BY avg_staff_score DESC;

# ANS --BUSINESS CLASS SCORES HIGHEST WITH 8.08 RATING IN CABIN STAFF SERVICE.

# QUES 12. WHAT PERCENTAGE OF CUSTOMERS RECOMMEND EACH AIRLINE ?


SELECT f.airline,
ROUND(SUM(CASE WHEN LOWER(r.recommend) = 'yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS recommend_pct
FROM reviews1 r
INNER JOIN flights1 f ON r.flight_id = f.flight_id
GROUP BY f.airline
ORDER BY recommend_pct DESC;

# ANS -- AIR INDIA with almost 60% rating is mostly recommended . 


# QUES 13. WHICH AIRLINES HAVE THE MOST UNRESOLVED SAFETY INCIDENTS ?

SELECT airline,COUNT(*) AS unresolved_incidents
FROM safety_log1
WHERE resolved = FALSE
GROUP BY airline
ORDER BY unresolved_incidents DESC;


# ANS -- SPICE JET with 67 unresolved incidents is on the top . 

# QUES 14. WHAT ARE THE MOST COMMON TYPES OF INCIDENTS AND THEIR SEVERITY LEVEL?


SELECT incident_type,
COUNT(*) AS total_incidents,
ROUND(AVG(severity_level), 2) AS avg_severity
FROM safety_log1
GROUP BY incident_type
ORDER BY total_incidents DESC;


# QUES 15. WHICH FLIGHTS HAVE RECURRING SAFETY ISSUES ?


SELECT flight_id,COUNT(*) AS incident_count
FROM safety_log1
GROUP BY flight_id
HAVING COUNT(*) > 1
ORDER BY incident_count DESC;
    
    
# QUES 16  IS THERE A CORREALTION BETWEEN DELAYS AND NEGATIVE REVIEWS ?

SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(MINUTE, f.dep_time, f.arr_time) > 72 THEN 'Delayed'
        ELSE 'On Time'
    END AS delay_status,
    ROUND(AVG(r.overall_rating), 2) AS avg_rating
FROM reviews1 r
INNER JOIN flights1 f ON r.flight_id = f.flight_id
WHERE f.dep_time IS NOT NULL AND f.arr_time IS NOT NULL
GROUP BY delay_status;

# QUES 17. DO SAFETY INCIDENTS IMPACT CUSTOMER RATINGS ?

SELECT s.flight_id,f.airline,
ROUND(AVG(r.overall_rating), 2) AS avg_rating
FROM safety_log1 s
INNER JOIN reviews1 r ON s.flight_id = r.flight_id
INNER JOIN flights1 f ON r.flight_id = f.flight_id
GROUP BY s.flight_id, f.airline
ORDER BY avg_rating ASC
LIMIT 10;

