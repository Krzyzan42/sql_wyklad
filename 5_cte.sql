-- Przeanalizuj udział sprzedanych produktów w poszczególnych podkategoriach w stosunku do całych
-- kategorii (zarówno pod względem liczbowym jak i wartościowym).

WITH ProductCategories AS (
	SELECT 
		CategoryName, 
		SubcategoryName,
		SUM(s.QuantitySold) AS QuantitySold,
		SUM(s.ValueSold) AS ValueSold
	FROM Production.Product p
	INNER JOIN
	(
		Select Name AS SubcategoryName, CategoryName, ProductSubcategoryID
		FROM Production.ProductSubcategory psc
		INNER JOIN 
		(
			SELECT Name AS CategoryName, ProductCategoryID 
			FROM Production.ProductCategory
		) pc ON pc.ProductCategoryID = psc.ProductCategoryID
	) psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
	INNER JOIN 
	(
		SELECT ProductID, SUM(OrderQty) AS QuantitySold, SUM(LineTotal) AS ValueSold
		FROM Sales.SalesOrderDetail
		GROUP BY ProductID
	) s ON s.ProductID = p.ProductID
	GROUP BY CategoryName, SubcategoryName
)
SELECT 
	CategoryName,
	SubcategoryName,
	QuantitySold,
	FORMAT(ValueSold, '0.00') AS "Value sold",
	FORMAT(100.0 * QuantitySold / SUM(QuantitySold) OVER(PARTITION BY CategoryName), '0.00') + '%' AS "Quantity share",
	FORMAT(100.0 * ValueSold / SUM(ValueSold) OVER(PARTITION BY CategoryName), '0.00') + '%' AS "Value share"
FROM ProductCategories;
