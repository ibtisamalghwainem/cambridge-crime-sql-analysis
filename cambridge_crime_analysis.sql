-- 1. النمط الأولي للجريمة في حي Cambridgeport
SELECT crime, COUNT(*) AS Total_Crimes, MAX(Date_of_Report) AS Last_Date 
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport'
GROUP BY crime
ORDER BY Last_Date DESC, Total_Crimes DESC;

-- 2. ربط الجريمة بالموقع (INNER JOIN)
SELECT crime.file_number, crime.crime, crime.Crime_Date_Time, Location.Location, Location.Neighborhood
FROM CambridgeCrimeData
INNER JOIN Location ON crime.file_number = Location.file_number
ORDER BY Location.Neighborhood, crime.Crime_Date_Time;

-- 2. الكشف عن البلاغات غير المكتملة (LEFT JOIN)
SELECT crimes.crime, Locations.Neighborhood  
FROM crimes  
LEFT JOIN Locations ON Crimes."File Number" = Locations."File Number"
WHERE Locations."File Number" IS NULL;

-- 3. تحليل البلاغات حسب التكرار والتواريخ
SELECT Crime, COUNT(*) AS Total_Count,
       MAX("Crime Date Time") AS Latest_Recording_Date,
       MIN("Crime Date Time") AS Earliest_Recording_Date
FROM Crimes
GROUP BY Crime
HAVING COUNT(*) > (
    SELECT AVG(Crime_Count)
    FROM (SELECT COUNT(*) AS Crime_Count FROM Crimes GROUP BY Crime) AS Avg_Counts
)
ORDER BY Total_Count DESC;

-- 4. الأيام الأكثر جرائم
SELECT EXTRACT(DAY FROM "Crime Date Time") AS Day_Of_Month,
       COUNT(*) AS Total_Crimes
FROM Crimes
GROUP BY Day_Of_Month
ORDER BY Total_Crimes DESC;

-- 4. الساعات الحرجة للجريمة
SELECT EXTRACT(HOUR FROM "Crime Date Time") AS Critical_Hour,
       COUNT(*) AS Total_Crimes
FROM crimes
WHERE EXTRACT(HOUR FROM "Crime Date Time") IN (23, 0, 1)
GROUP BY Critical_Hour
ORDER BY Total_Crimes DESC;

-- 5. خصائص المشتبه بهم المحتملين
SELECT crimes.crime, Locations.Neighborhood, Crimes."Crime Date Time"
FROM crimes  
INNER JOIN Locations ON Crimes."File Number" = Locations."File Number" 
WHERE Locations.Neighborhood IN ('Cambridgeport', 'East Cambridge', 'North Cambridge', 'Area 4')
  AND (EXTRACT(DAY FROM Crimes."Crime Date Time") BETWEEN 13 AND 15 
       OR EXTRACT(HOUR FROM Crimes."Crime Date Time") IN (23, 0, 1))
ORDER BY Locations.Neighborhood, Crimes."Crime Date Time" DESC;

-- 6. الترتيب النهائي للجرائم
SELECT crime, COUNT(*) AS Total_Crimes,
       DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Crime_DenseRank
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport'
GROUP BY crime;

-- 6. الجرائم الأخيرة
SELECT crime, Neighborhood, Date_of_Report,
       ROW_NUMBER() OVER (PARTITION BY Neighborhood ORDER BY Date_of_Report DESC) AS Recent_Crime_Order
FROM CambridgeCrimeData
WHERE Neighborhood = 'Cambridgeport';

-- 7. حجم وتأثير الجرائم التراكمي
SELECT COUNT(*) AS Total_Crimes_Analyzed,
       SUM(CASE WHEN Crime IN ('Larceny from MV', 'Larceny of Bicycle', 'Hit and Run') THEN 1 ELSE 0 END) AS Target_Crimes_Count,
       ROUND((CAST(SUM(CASE WHEN Crime IN ('Larceny from MV', 'Larceny of Bicycle', 'Hit and Run') THEN 1 ELSE 0 END) AS REAL) * 100.0) / COUNT(*), 2) AS Target_Crimes_Percentage
FROM crimes;
