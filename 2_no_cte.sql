SELECT
	AgeGroup AS "Grupa wiekowa",
	OrderYear AS "Rok",
	OrderMonth AS "Miesi¹c",
	COUNT(DISTINCT CustomerID) AS "Liczba unikalnych klientów"
FROM (
	SELECT 
		C.CustomerID,
		NTILE(3) OVER(ORDER BY YEAR(GETDATE()) - YEAR(
			P.Demographics.value(
				'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
				 (//BirthDate)[1]', 
				'DATE'
			)
		)) AS AgeGroup,
		YEAR(SOH.OrderDate) AS OrderYear,
		MONTH(SOH.OrderDate) AS OrderMonth
	FROM Sales.Customer AS C
	JOIN Person.Person AS P ON P.BusinessEntityID = C.PersonID
	JOIN Sales.SalesOrderHeader AS SOH ON SOH.CustomerID = C.CustomerID
	WHERE
		P.Demographics.exist(
			'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
			 (//BirthDate)[1]'
		) = 1
) AS Sub
GROUP BY AgeGroup, OrderYear, OrderMonth
ORDER BY OrderYear, OrderMonth, AgeGroup;
