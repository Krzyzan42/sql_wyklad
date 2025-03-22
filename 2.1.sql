-- Zaproponuj podzia³ klientów na 3 roz³¹czne grupy wiekowe. Ilu ró¿nych klientów dokona³o zakupów
-- w kolejnych miesi¹cach roku w ka¿dej z grup? Ilu klientów w poszczególnych grupach wykona³o
-- zakup dok³adnie jeden raz?


WITH CustomerOrders AS (
	SELECT 
		C.CustomerID,
		NTILE(3) OVER(ORDER BY YEAR(GETDATE()) - YEAR(
			P.Demographics.value(
				'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
				 (//BirthDate)[1]', 
				'DATE'
			)
		)) AS AgeGroup,
		SOH.SalesOrderID,
		MONTH(SOH.OrderDate) AS OrderMonth,
		YEAR(SOH.OrderDate) AS OrderYear
	FROM Sales.Customer AS C
	JOIN Person.Person AS P ON P.BusinessEntityID = C.PersonID
	JOIN Sales.SalesOrderHeader AS SOH ON SOH.CustomerID = C.CustomerID
	WHERE
		P.Demographics.exist(
			'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
			 (//BirthDate)[1]'
		) = 1
),
CustomersWithOneTransaction AS (
	SELECT 
		CustomerID,
		AgeGroup
	FROM CustomerOrders
	GROUP BY CustomerID, AgeGroup
	HAVING COUNT(*) = 1
)
SELECT
	AgeGroup AS "Grupa wiekowa",
	COUNT(DISTINCT CustomerID) AS "Liczba klientów z 1 zamówieniem"
FROM CustomersWithOneTransaction
GROUP BY AgeGroup
ORDER BY AgeGroup
