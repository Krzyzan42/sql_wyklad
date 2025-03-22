-- Jaka była łączna suma transakcji (SalesOrderHeader.SubTotal) w poszczególnych latach dla
-- kolejnych dni tygodnia?

SET DATEFIRST 1;

SELECT 
	SUM(SubTotal) AS "Suma",
	DATENAME(DW, OrderDate) AS "Dzień tygodnia",
	DATEPART(YEAR, OrderDate) AS "Rok"
FROM Sales.SalesOrderHeader
GROUP BY DATENAME(DW, OrderDate), DATEPART(YEAR, OrderDate), DATEPART(DW, OrderDate)
ORDER BY DATEPART(YEAR, OrderDate), DATEPART(DW, OrderDate)