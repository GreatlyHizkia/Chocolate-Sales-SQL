SELECT * FROM Chocolate_Sales


-- Data Cleaning convert column date from '2022-01-04 00:00:00.0000000' to '2022-01-04'
ALTER TABLE Chocolate_Sales
ALTER COLUMN [Date] DATE;

-- Check null values
SELECT * FROM Chocolate_Sales
	WHERE 
	Sales_Person is null 
	or Country is null or 
	Product is null or 
	DATE is null 
	or Amount is null or 
	Boxes_Shipped is null

-- 1. What is the total sales (total revenue) overall?
SELECT SUM(Amount) as total_revenue FROM Chocolate_Sales

-- 2. Which TOP 5 product sold the most (based on the number of boxes)?
SELECT TOP 5 Product, 
    SUM(Boxes_Shipped) AS Total_Boxes 
    FROM Chocolate_Sales 
    GROUP BY Product 
    ORDER BY Total_Boxes DESC

-- 3. Who are the top 5 sales staff based on sales value, total boxes shipped, and number of transactions?
SELECT Top 5 Sales_Person,
    SUM(Amount) AS Total_Sales,
    SUM(Boxes_Shipped) AS Total_boxes_shipped,
    COUNT(*) AS Total_Transactions
    FROM Chocolate_Sales
    GROUP BY Sales_Person
    ORDER BY 2 DESC

-- 4. What is the average sales per transaction in each country?
SELECT Country,
    ROUND(AVG(Amount),2) as avg_revenue,
    COUNT(*) AS Total_Transactions
    From Chocolate_Sales
    GROUP BY Country
    ORDER BY 2 DESC

-- 5. Which Products generated the most average revenue
SELECT Product,
    AVG(Amount) as Avg_Revenue,
    COUNT(*) as Total_Transactions
    From Chocolate_Sales
    GROUP BY Product
    ORDER BY 2 DESC 

-- 6. Which country has the highest percentage of `Peanut Butter Cubes` transactions?
SELECT Country, 
    CAST(SUM(CASE WHEN Product = 'Peanut Butter Cubes' THEN 1 ELSE 0 END) AS REAL) * 100 / COUNT(*) AS Percentage_PeanutButterCubes 
    FROM Chocolate_Sales 
    GROUP BY Country 
    ORDER BY 2 DESC;

-- 7. Total Revenue each Product
SELECT Product,
    SUM(Amount) as Total_Revenue,
    COUNT(*) as Total_transactions
    From Chocolate_Sales
    GROUP BY Product
    ORDER BY 2 DESC 

-- 8. Total Transactions each product
SELECT Product, 
    COUNT(*) as total_transactions 
    Chocolate_Sales
    GROUP BY Product
    ORDER BY 2 DESC

-- 9. What is the average order value (AOV) per product?
SELECT Product, 
    AVG(Amount) AS AOV 
    FROM Chocolate_Sales
    GROUP BY Product
    ORDER BY 2 DESC;

-- 10. Calculate the average unit price (selling price per box) of each product.
SELECT Product, 
    SUM(Amount) / SUM(Boxes_Shipped) AS Avg_Unit_Price 
    FROM Chocolate_Sales 
    GROUP BY Product
    ORDER BY 2 DESC;


-- 11. What are the monthly sales trends (Month-over-Month) in each country ?
 WITH MonthlySales AS (
    -- CTE 1: Calculating total sales per month per country
    SELECT
        Country,
        FORMAT([Date], 'yyyy-MM') AS Sales_Month,
        SUM(Amount) AS Monthly_Revenue
    FROM
       Chocolate_Sales                    
    GROUP BY
        Country,                                   
        FORMAT([Date], 'yyyy-MM')
),
MoMTrend AS (
    -- CTE 2: Calculating the MoM ratio
    SELECT
        Country,
        Sales_Month,
        Monthly_Revenue,
        -- Using PARTITION BY Country:
        -- LAG() will take the previous month's value ONLY in the same PARTITION (country).
        LAG(Monthly_Revenue, 1, 0) OVER (PARTITION BY Country ORDER BY Sales_Month) AS Previous_Month_Revenue
    FROM
        MonthlySales
)
-- Query Final: Displaying MoM trend results
SELECT
    Country,
    Sales_Month,
    Monthly_Revenue,
    Previous_Month_Revenue,
    -- Calculating Percentage Change (MoM Growth)
    CASE
        WHEN Previous_Month_Revenue = 0 THEN NULL
        ELSE ((Monthly_Revenue - Previous_Month_Revenue) / Previous_Month_Revenue) * 100
    END AS MoM_Growth_Percentage
FROM
    MoMTrend
ORDER BY
    Country,
    Sales_Month;



