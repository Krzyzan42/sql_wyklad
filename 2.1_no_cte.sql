SELECT
	AgeGroup AS "Grupa wiekowa",
	COUNT(*) AS "Liczba klientów z 1 zamówieniem"
FROM (
	SELECT 
		CustomerID,
		AgeGroup
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
			SOH.SalesOrderID
		FROM Sales.Customer AS C
		JOIN Person.Person AS P ON P.BusinessEntityID = C.PersonID
		JOIN Sales.SalesOrderHeader AS SOH ON SOH.CustomerID = C.CustomerID
		WHERE
			P.Demographics.exist(
				'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";
				 (//BirthDate)[1]'
			) = 1
	) AS Orders
	GROUP BY CustomerID, AgeGroup
	HAVING COUNT(SalesOrderID) = 1
) AS Grouped
GROUP BY AgeGroup
ORDER BY AgeGroup;
