-- Przeanalizuj udział sprzedanych produktów w poszczególnych podkategoriach w stosunku do całych
-- kategorii (zarówno pod względem liczbowym jak i wartościowym).

SELECT 
	CategoryName, 
	SubcategoryName,
	SUM(s.QuantitySold) AS QuantitySold,
	SUM(s.ValueSold) AS ValueSold,
	FORMAT(100.0 * SUM(s.QuantitySold) / SUM(SUM(s.QuantitySold)) OVER(PARTITION BY CategoryName), '0.00') + '%' AS "Quantity share",
	FORMAT(100.0 * SUM(s.ValueSold) / SUM(SUM(s.ValueSold)) OVER(PARTITION BY CategoryName), '0.00') + '%' AS "Value share"
FROM Production.Product p
INNER JOIN  -- Product categories
(
	Select Name AS SubcategoryName, CategoryName, ProductSubcategoryID
	FROM Production.ProductSubcategory psc
	INNER JOIN 
	(
		SELECT Name AS CategoryName, ProductCategoryID 
		FROM Production.ProductCategory
	) pc ON pc.ProductCategoryID = psc.ProductCategoryID
) psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
INNER JOIN -- Quantity
(
	SELECT ProductID, SUM(OrderQty) AS QuantitySold, SUM(LineTotal) AS ValueSold
	FROM Sales.SalesOrderDetail
	GROUP BY ProductID
) s ON s.ProductID = p.ProductID
GROUP BY CategoryName, SubcategoryName;