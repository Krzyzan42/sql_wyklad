--Przygotuj zestawienie, w którym przeanalizujesz, ilu jest różnych klientów dla każdej płci
--w kolejnych miesiącach (05.2011 – 06.2024)? Jak procentowo rozkłada się ich udział
--w całkowitej wartości sprzedaży (Sales.SalesOrderHeader.TotalDue)?

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey'),
GenderSales AS (
	SELECT 
	SUM(s.TotalDue) as GenderMonthSum, 
	COUNT(s.SalesOrderID) as SalesCount, 
	YEAR(s.OrderDate) as OrderYear, 
	MONTH(s.OrderDate) as OrderMonth,
	c.Gender as Gender,
	COUNT(DISTINCT c.CustomerID) AS CustomerCount
	FROM Sales.SalesOrderHeader s
	INNER JOIN (
		SELECT c.CustomerID, c.PersonID, p.Gender
		FROM Sales.Customer c
		INNER JOIN ( -- Nie wszyscy customers mają person?
			SELECT BusinessEntityID, Demographics.value('(//Gender)[1]', 'CHAR(1)') AS Gender  
			FROM Person.Person
			WHERE Demographics.exist('(//Gender)[1]') = 1
		) p ON p.BusinessEntityID = c.PersonID
	) c ON c.CustomerID = s.CustomerID  -- Czy p.BusinessEntityID = c.PersonID to dobre prownanie? Chyba tak
	WHERE s.OrderDate BETWEEN '2011-05-01' AND '2024-06-30'
	GROUP BY c.Gender, YEAR(s.OrderDate), MONTH(s.OrderDate)
)
SELECT
	GenderMonthSum as "Monthly sum",
	SalesCount as "Number of sales",
	OrderYear as "Year",
	OrderMonth as "Month",
	Gender,
	CustomerCount as "Number of cunstomers",
	FORMAT(100 * GenderMonthSum / SUM(GenderMonthSum) OVER(PARTITION BY OrderYear, OrderMonth), '0.00') + '%' AS "Gender share" 
FROM GenderSales
ORDER BY OrderYear DESC, OrderMonth DESC, Gender;
