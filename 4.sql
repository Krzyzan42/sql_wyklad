--Przygotuj zestawienie, w którym przeanalizujesz, ilu jest różnych klientów dla każdej płci
--w kolejnych miesiącach (05.2011 – 06.2024)? Jak procentowo rozkłada się ich udział
--w całkowitej wartości sprzedaży (Sales.SalesOrderHeader.TotalDue)?

-- Drugie PARTITION BY DO OPTYMALIZACJI przez CTE
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey')
SELECT SUM(s.TotalDue), COUNT(s.SalesOrderID), YEAR(s.OrderDate), MONTH(s.OrderDate), c.Gender
,SUM(SUM(s.TotalDue)) OVER(PARTITION BY YEAR(s.OrderDate), MONTH(s.OrderDate), c.Gender) / SUM(SUM(s.TotalDue)) OVER(PARTITION BY YEAR(s.OrderDate), MONTH(s.OrderDate)) AS Suma
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
