-- Przygotuj zestawienie, w którym możliwa będzie analiza regionalna z uwzględnieniem lokalnej
-- waluty (kwoty sprzedaży w zależności od waluty i regionu).

SELECT SUM(TotalDue) AS "Total order cost (USD)", ISNULL(c.ToCurrencyCode, 'USD') AS "Currency", t.Name, AVG(TotalDue) AS "Average order cost (USD)"
FROM Sales.SalesOrderHeader s
LEFT JOIN (
	SELECT ToCurrencyCode, CurrencyRateID
	FROM Sales.CurrencyRate
) c on s.CurrencyRateID = c.CurrencyRateID
LEFT JOIN (
	SELECT TerritoryID, Name, CountryRegionCode, "Group"
	FROM Sales.SalesTerritory
) t on s.TerritoryID = t.TerritoryID
GROUP BY t.Name, c.ToCurrencyCode
ORDER BY 1 DESC;