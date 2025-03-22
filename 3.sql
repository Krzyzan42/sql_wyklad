-- Przygotuj zestawienie produktów, których sprzedaje się miesięcznie min. 20 sztuk. Dla każdego
-- produktu podaj jego kategorię.

SELECT pd.Name, COUNT(s.SalesOrderID) AS "Items Sold",  MAX(pd.CategoryName) as "Category", YEAR(s.OrderDate) AS "Year", MONTH(s.OrderDate) AS "Month"
FROM Sales.SalesOrderHeader s
LEFT JOIN 
(
	SELECT s.ProductID, p.CategoryName, s.SalesOrderID, p.Name
	FROM Sales.SalesOrderDetail s
	LEFT JOIN 
	(
		SELECT p.ProductID, ps.CategoryName, p.Name FROM Production.Product p
		LEFT JOIN 
		(
			SELECT psc.ProductSubcategoryID, pc.Name AS CategoryName FROM Production.ProductSubcategory psc
			LEFT JOIN Production.ProductCategory pc
			ON psc.ProductCategoryID = pc.ProductCategoryID
		) ps ON ps.ProductSubcategoryID = p.ProductSubcategoryID 
	) p on p.ProductID = s.ProductID
) pd ON pd.SalesOrderID = s.SalesOrderID

GROUP BY YEAR(s.OrderDate), MONTH(s.OrderDate), pd.Name
HAVING COUNT(s.SalesOrderID) >= 20
ORDER BY YEAR(s.OrderDate) DESC, Month(s.OrderDate) DESC, COUNT(s.SalesOrderID) DESC;