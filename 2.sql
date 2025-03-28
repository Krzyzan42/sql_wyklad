-- Zaproponuj podzia� klient�w na 3 roz��czne grupy wiekowe. Ilu r�nych klient�w dokona�o zakup�w
-- w kolejnych miesi�cach roku w ka�dej z grup? Ilu klient�w w poszczeg�lnych grupach wykona�o
-- zakup dok�adnie jeden raz?

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
)

SELECT
	AgeGroup AS "Grupa wiekowa", 
	OrderYear AS "Rok",
	OrderMonth AS "Miesi�c",
	COUNT(DISTINCT CustomerID) AS "Liczba unikalnych klient�w"
FROM CustomerOrders
GROUP BY AgeGroup, OrderYear, OrderMonth
ORDER BY OrderYear, OrderMonth, AgeGroup;
