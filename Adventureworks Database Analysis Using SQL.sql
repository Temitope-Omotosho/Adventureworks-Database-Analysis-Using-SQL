/* 1. You’ve been asked to extract the data on products from the Product table where there exists a product subcategory, 
and also include the name of the ProductSubcategory.*/
SELECT product.ProductID,
       product.Name,
       product.ProductNumber,
       product.Size,
       product.Color,
       product.ProductSubcategoryID,
       subcategory.Name as Subcategory_name
--joined the two tables required to solved this task
FROM `adwentureworks_db.product` as product
JOIN `adwentureworks_db.productsubcategory` as subcategory
ON product.ProductSubcategoryID = subcategory.ProductSubcategoryID
-- sorting by the subcategories
ORDER BY Subcategory_name;


-- 2. Include the product category name in the first query result
SELECT product.ProductID,
       product.Name,
       product.ProductNumber,
       product.Size,
       product.Color,
       product.ProductSubcategoryID,
       subcategory.Name as Subcategory,
       category.Name as Category
--joined the three tables required to solved this task
FROM `adwentureworks_db.product` as product
JOIN `adwentureworks_db.productsubcategory` as subcategory
ON product.ProductSubcategoryID = subcategory.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` as category
ON category.ProductCategoryID = subcategory.ProductCategoryID
--sorted by categories
ORDER BY Category;


/* 3. Use the established query to select the most expensive (price listed over 2000) bikes that are still actively sold 
(does not have a sales end date) */
SELECT product.ProductID,
       product.Name,
       product.ProductNumber,
       product.Size,
       product.Color,
       product.ProductSubcategoryID,
       subcategory.Name as Subcategory,
       category.Name as Category
--joined the three tables required to solved this task
FROM `adwentureworks_db.product` as product
JOIN `adwentureworks_db.productsubcategory` as subcategory
ON product.ProductSubcategoryID = subcategory.ProductSubcategoryID
JOIN `adwentureworks_db.productcategory` as category
ON category.ProductCategoryID = subcategory.ProductCategoryID
--filtered based on some conditions
WHERE product.ListPrice > 2000 
      AND product.SellEndDate IS NULL
      AND category.Name = 'Bikes'
--sorted in descending order by ListPrice
ORDER BY product.ListPrice DESC;


/* 4. Create an aggregated query to select the:
Number of unique work orders.
Number of unique products.
Total actual cost.
For each location Id from the 'workoderrouting' table for orders in January 2004*/
SELECT worder.LocationId, 
       COUNT(DISTINCT WorkOrderID) as No_of_work_orders, 
       COUNT(DISTINCT ProductID) as No_of_products, 
       SUM(ActualCost) as total_actual_cost
FROM `adwentureworks_db.workorderrouting` as worder
--filtered for January 2004
WHERE ActualStartDate BETWEEN '2004-01-01' AND '2004-01-31'
--aggregated by location ID
GROUP BY worder.LocationID
--sorted by locaion ID
ORDER BY total_actual_cost DESC;


/* 5. Update the query above by adding the name of the location and also add the average days amount between actual 
start date and actual end date per each location.*/
SELECT worder.LocationId, 
       loc.Name, 
       COUNT(DISTINCT WorkOrderID) as No_of_work_orders, 
       COUNT(DISTINCT ProductID) as No_of_products, 
       SUM(ActualCost) as Total_actual_cost,
       ROUND(AVG(DATE_DIFF(ActualEndDate, ActualStartDate,DAY)),2) as Avg_days
--joined the required tables
FROM `adwentureworks_db.workorderrouting` as worder
JOIN `adwentureworks_db.location` as loc
ON worder.LocationID = loc.LocationID
--filtered for January 2004
WHERE ActualStartDate BETWEEN '2004-01-01' AND '2004-01-31'
--aggregated by location ID and location Name
GROUP BY worder.LocationID, loc.Name
ORDER BY Avg_days DESC;


/* 6. Select all the expensive work Orders (above 300 actual cost) that happened throught January 2004*/

SELECT WorkOrderID, 
       SUM(ActualCost) as ActualCost
FROM `adwentureworks_db.workorderrouting`
WHERE ActualStartDate BETWEEN '2004-01-01' AND '2004-01-31'
GROUP BY WorkOrderID
--filtering after aggregation based on a condition
HAVING ActualCost > 300;


/* 7. Find the list of orders connected to special offers.*/
SELECT sales_detail.SalesOrderId
      ,sales_detail.OrderQty
      ,sales_detail.UnitPrice
      ,sales_detail.LineTotal
      ,sales_detail.ProductId
      ,sales_detail.SpecialOfferID
      ,spec_offer_product.ModifiedDate
      ,spec_offer.Category
      ,spec_offer.Description

FROM `tc-da-1.adwentureworks_db.salesorderdetail`  as sales_detail
left join `tc-da-1.adwentureworks_db.specialofferproduct` as spec_offer_product
on sales_detail.productId = spec_offer_product.ProductID AND sales_detail.SpecialOfferID = spec_offer_product.SpecialOfferID
left join `tc-da-1.adwentureworks_db.specialoffer` as spec_offer
on sales_detail.SpecialOfferID = spec_offer.SpecialOfferID
order by LineTotal desc;


-- 8. Write a query to collect the basic Vendor information. Kindly note that the required information are in seperate tables

--select required columns that are aliased properly
SELECT vendor.VendorId as Id,
       vendor_contact.ContactId, 
       vendor_contact.ContactTypeId, 
       vendor.Name, 
       vendor.CreditRating, 
       vendor.ActiveFlag, 
       vendor_address.AddressId,
       address.City

FROM `tc-da-1.adwentureworks_db.vendor` as vendor
left join `tc-da-1.adwentureworks_db.vendorcontact` as vendor_contact 
on vendor.VendorId = vendor_contact.VendorId 
left join `tc-da-1.adwentureworks_db.vendoraddress` as vendor_address 
on vendor.VendorId = vendor_address.VendorId
left join `tc-da-1.adwentureworks_db.address` as address 
on vendor_address.AddressId = address.AddressID;


/* 9. You’ve been tasked to create a detailed overview of all individual customers (these are defined by customerType = ‘I’ 
and/or stored in an individual table). 
Write a query that provides:
Identity information : CustomerId, Firstname, Last Name, FullName (First Name & Last Name).
An Extra column called addressing_title i.e. (Mr. Achong), if the title is missing - Dear Achong.
Contact information : Email, phone, account number, CustomerType.
Location information : City, State & Country, address.
Sales: number of orders, total amount (with Tax), date of the last order.
Copy only the top 200 rows from your written select ordered by total amount (with tax).*/

SELECT customer.CustomerID,
       contact.Firstname as FirstName,
       contact.LastName,
       CONCAT(contact.Firstname,' ',contact.LastName) as FullName,
       CASE WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title,' ',contact.LastName)
            ELSE CONCAT('Dear',' ',contact.LastName) END as AddressingTitle,
       contact.Emailaddress as EmailAddress,
       contact.Phone,
       customer.AccountNumber,
       customer.CustomerType,
       address.City,
       address.AddressLine1,
       address.AddressLine2,
       state.Name as StateName,
       country.Name as CountryName,
       COUNT(SalesOrderID) as Number_of_Orders,
       ROUND(SUM(TotalDue),3) as Total_Amount,
       MAX(OrderDate) as Last_Order_Date

FROM `adwentureworks_db.customer` as customer
LEFT JOIN `adwentureworks_db.individual` as individual
ON customer.CustomerID = individual.CustomerID
LEFT JOIN `adwentureworks_db.contact` as contact
ON individual.ContactID = contact.ContactId
LEFT JOIN `adwentureworks_db.customeraddress` as customer_address
ON customer.CustomerID = customer_address.CustomerID
LEFT JOIN `adwentureworks_db.address` as address
ON customer_address.AddressID = address.AddressID
LEFT JOIN `adwentureworks_db.stateprovince` as state
ON state.StateProvinceID = address.StateProvinceID
LEFT JOIN `adwentureworks_db.countryregion` as country
ON state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN `adwentureworks_db.salesorderheader` as sales
ON sales.CustomerID = customer.CustomerID

WHERE CustomerType = 'I' 
      AND customer_address.AddressID = 
      (SELECT MAX(AddressId) FROM `adwentureworks_db.customeraddress` customer_address2
      WHERE customer_address2.CustomerID = customer.CustomerID )

GROUP BY ALL 

ORDER BY Total_Amount DESC
LIMIT 200;


/* 10. Business finds the original query valuable to analyze customers and now want to get the data from the first query
for the top 200 customers with the highest total amount (with tax) who have not ordered for the last 365 days.*/

WITH customer_analysis AS (
SELECT customer.CustomerID,
       contact.Firstname as FirstName,
       contact.LastName,
       CONCAT(contact.Firstname,' ',contact.LastName) as FullName,
       CASE WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title,' ',contact.LastName)
            ELSE CONCAT('Dear',' ',contact.LastName) END as AddressingTitle,
       contact.Emailaddress as EmailAddress,
       contact.Phone,
       customer.AccountNumber,
       customer.CustomerType,
       address.City,
       address.AddressLine1,
       address.AddressLine2,
       state.Name as StateName,
       country.Name as CountryName,
       COUNT(SalesOrderID) as Number_of_Orders,
       ROUND(SUM(TotalDue),3) as Total_Amount,
       MAX(OrderDate) as Last_Order_Date

FROM `adwentureworks_db.customer` as customer
LEFT JOIN `adwentureworks_db.individual` as individual
ON customer.CustomerID = individual.CustomerID
LEFT JOIN `adwentureworks_db.contact` as contact
ON individual.ContactID = contact.ContactId
LEFT JOIN `adwentureworks_db.customeraddress` as customer_address
ON customer.CustomerID = customer_address.CustomerID
LEFT JOIN `adwentureworks_db.address` as address
ON customer_address.AddressID = address.AddressID
LEFT JOIN `adwentureworks_db.stateprovince` as state
ON state.StateProvinceID = address.StateProvinceID
LEFT JOIN `adwentureworks_db.countryregion` as country
ON state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN `adwentureworks_db.salesorderheader` as sales
ON sales.CustomerID = customer.CustomerID

WHERE CustomerType = 'I' 
      AND customer_address.AddressID = 
      (SELECT MAX(AddressId) FROM `adwentureworks_db.customeraddress` customer_address2
      WHERE customer_address2.CustomerID = customer.CustomerID )

GROUP BY ALL    

ORDER BY Total_Amount DESC
)

SELECT *
FROM customer_analysis 
WHERE last_order_date < DATE_SUB((SELECT MAX(last_order_date) FROM customer_analysis), INTERVAL 365 DAY)
ORDER BY Total_Amount DESC
LIMIT 200;


/* 11. Enrich your original question 9 by creating a new column in the view that marks active & inactive customers 
based on whether they have ordered anything during the last 365 days.
Copy only the top 500 rows from your written select ordered by CustomerId desc.*/
WITH customer_status AS (
  SELECT customer.CustomerID,
       contact.Firstname as FirstName,
       contact.LastName,
       CONCAT(contact.Firstname,' ',contact.LastName) as FullName,
       CASE WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title,' ',contact.LastName)
            ELSE CONCAT('Dear',' ',contact.LastName) END as AddressingTitle,
       contact.Emailaddress as EmailAddress,
       contact.Phone,
       customer.AccountNumber,
       customer.CustomerType,
       address.City,
       address.AddressLine1,
       address.AddressLine2,
       state.Name as StateName,
       country.Name as CountryName,
       COUNT(SalesOrderID) as Number_of_Orders,
       ROUND(SUM(TotalDue),3) as Total_Amount,
       MAX(OrderDate) as Last_Order_Date

FROM `adwentureworks_db.customer` as customer
LEFT JOIN `adwentureworks_db.individual` as individual
ON customer.CustomerID = individual.CustomerID
LEFT JOIN `adwentureworks_db.contact` as contact
ON individual.ContactID = contact.ContactId
LEFT JOIN `adwentureworks_db.customeraddress` as customer_address
ON customer.CustomerID = customer_address.CustomerID
LEFT JOIN `adwentureworks_db.address` as address
ON customer_address.AddressID = address.AddressID
LEFT JOIN `adwentureworks_db.stateprovince` as state
ON state.StateProvinceID = address.StateProvinceID
LEFT JOIN `adwentureworks_db.countryregion` as country
ON state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN `adwentureworks_db.salesorderheader` as sales
ON sales.CustomerID = customer.CustomerID

WHERE CustomerType = 'I' 
      AND customer_address.AddressID = 
      (SELECT MAX(AddressId) FROM `adwentureworks_db.customeraddress` customer_address2
      WHERE customer_address2.CustomerID = customer.CustomerID )

GROUP BY ALL

ORDER BY Total_Amount DESC
)

SELECT *, 
       CASE WHEN last_order_date < DATE_SUB((SELECT MAX(OrderDate) FROM `adwentureworks_db.salesorderheader`),INTERVAL 365 DAY) THEN 'Inactive'
            ELSE 'Active' END as CustomerStatus
FROM customer_status
ORDER BY CustomerID DESC
LIMIT 500;


/* 12. Business would like to extract data on all active customers from North America. Only customers that have either 
ordered no less than 2500 in total amount (with Tax) or ordered 5 + times should be presented.
In the output for these customers divide their address line into two columns, i.e.:
   AddressLine1     |   address_no  |   Address_st
'8603 Elmhurst Lane'|     8603	 | Elmhurst Lane

Order the output by country, state and date_last_order.*/

WITH customer_status_new AS (
  SELECT customer.CustomerID,
       contact.Firstname as FirstName,
       contact.LastName,
       CONCAT(contact.Firstname,' ',contact.LastName) as FullName,
       CASE WHEN contact.Title IS NOT NULL THEN CONCAT(contact.Title,' ',contact.LastName)
            ELSE CONCAT('Dear',' ',contact.LastName) END as AddressingTitle,
       contact.Emailaddress as EmailAddress,
       contact.Phone,
       customer.AccountNumber,
       customer.CustomerType,
       address.City,
       address.AddressLine1,
       address.AddressLine2,
       state.Name as StateName,
       country.Name as CountryName,
       territory.Group as TerritoryName,
       COUNT(SalesOrderID) as Number_of_Orders,
       ROUND(SUM(TotalDue),3) as Total_Amount,
       MAX(OrderDate) as Last_Order_Date

FROM `adwentureworks_db.customer` as customer
LEFT JOIN `adwentureworks_db.individual` as individual
ON customer.CustomerID = individual.CustomerID
LEFT JOIN `adwentureworks_db.contact` as contact
ON individual.ContactID = contact.ContactId
LEFT JOIN `adwentureworks_db.customeraddress` as customer_address
ON customer.CustomerID = customer_address.CustomerID
LEFT JOIN `adwentureworks_db.address` as address
ON customer_address.AddressID = address.AddressID
LEFT JOIN `adwentureworks_db.stateprovince` as state
ON state.StateProvinceID = address.StateProvinceID
LEFT JOIN `adwentureworks_db.countryregion` as country
ON state.CountryRegionCode = country.CountryRegionCode
LEFT JOIN `adwentureworks_db.salesorderheader` as sales
ON sales.CustomerID = customer.CustomerID
LEFT JOIN `adwentureworks_db.salesterritory` as territory
ON customer.TerritoryID = territory.TerritoryID

WHERE CustomerType = 'I' 
      AND customer_address.AddressID = 
      (SELECT MAX(AddressId) FROM `adwentureworks_db.customeraddress` customer_address2
      WHERE customer_address2.CustomerID = customer.CustomerID )
GROUP BY ALL
ORDER BY Total_Amount DESC
),

known_customer_status AS (
  SELECT *, 
       LEFT(AddressLine1,STRPOS(AddressLine1,' ')-1) as AddressNo,
       RIGHT(AddressLine1,LENGTH(AddressLine1) - STRPOS(AddressLine1,' ')) as AddressStreet,
       CASE WHEN last_order_date < DATE_SUB((SELECT MAX(OrderDate) FROM `adwentureworks_db.salesorderheader`),INTERVAL 365 DAY) THEN 'Inactive'
            ELSE 'Active' END as CustomerStatus
FROM customer_status_new
ORDER BY CustomerID DESC
)

SELECT CustomerID,
       FirstName,
       LastName,
       AddressingTitle,
       EmailAddress,
       Phone,
       AccountNumber,
       CustomerType,
       City,
       AddressLine1,
       AddressNo, 
       AddressStreet,
       AddressLine2,
       StateName,
       CountryName,  
       Number_of_Orders,
       Total_Amount,
       Last_Order_Date

FROM known_customer_status
WHERE CustomerStatus = 'Active' 
      AND TerritoryName ='North America'
      AND (Number_of_Orders > 5 OR Total_Amount >= 2500)
ORDER BY CountryName,StateName,Last_Order_Date;


/* 13. Create a query of monthly sales numbers in each Country & region. Include in the query a number of orders, customers
and sales persons in each month with a total amount with tax earned. Sales numbers from all types of customers are required.*/
SELECT LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH) as OrderMonth,
       territory.CountryRegionCode,
       territory.Name as Region,
       COUNT(SalesOrderID) as Number_of_Orders,
       COUNT(DISTINCT CustomerID) as Number_of_Customers,
       COUNT(DISTINCT SalesPersonID) as Number_of_Salespersons,
       CAST(SUM(TotalDue) AS INTEGER) as Total_w_tax

FROM `adwentureworks_db.salesorderheader` as sales
LEFT JOIN `adwentureworks_db.salesterritory` as territory
ON sales.TerritoryID = territory.TerritoryID

GROUP BY LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH),
         territory.CountryRegionCode,
         territory.Name;


/* 14. Enrich the query above with the cumulative_sum of the total amount with tax earned per country & region.*/         
WITH cum_sum AS (
  SELECT LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH) as OrderMonth,
       territory.CountryRegionCode,
       territory.Name as Region,
       COUNT(SalesOrderID) as Number_of_Orders,
       COUNT(DISTINCT CustomerID) as Number_of_Customers,
       COUNT(DISTINCT SalesPersonID) as Number_of_Salespersons,
       CAST(SUM(TotalDue) AS INTEGER) as Total_w_tax

FROM `adwentureworks_db.salesorderheader` as sales
LEFT JOIN `adwentureworks_db.salesterritory` as territory
ON sales.TerritoryID = territory.TerritoryID

GROUP BY LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH),
         territory.CountryRegionCode,
         territory.Name
)

SELECT *,
       SUM(Total_w_tax) OVER(PARTITION BY CountryRegionCode ORDER BY OrderMonth) as CumulativeSum
FROM cum_sum;


/* 15. In the query above add a ‘sales_rank’ column that ranks rows from best to worst for each country based on 
total amount with tax earned each month. I.e. the month where the (US, Southwest) region made the highest total amount 
with tax earned will be ranked 1 for that region and vice versa.*/
WITH cum_sum AS (
   SELECT LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH) as OrderMonth,
       territory.CountryRegionCode,
       territory.Name as Region,
       COUNT(SalesOrderID) as Number_of_Orders,
       COUNT(DISTINCT CustomerID) as Number_of_Customers,
       COUNT(DISTINCT SalesPersonID) as Number_of_Salespersons,
       CAST(SUM(TotalDue) AS INTEGER) as Total_w_tax

FROM `adwentureworks_db.salesorderheader` as sales
LEFT JOIN `adwentureworks_db.salesterritory` as territory
ON sales.TerritoryID = territory.TerritoryID

GROUP BY LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH),
         territory.CountryRegionCode,
         territory.Name
)

SELECT *,
       SUM(Total_w_tax) OVER(PARTITION BY CountryRegionCode,Region ORDER BY OrderMonth) as CumulativeSum,
       RANK() OVER(PARTITION BY CountryRegionCode ORDER BY Total_w_tax DESC) as CountrySalesRank
FROM cum_sum;


/* 16. Update the query 15 by adding taxes on a country level:
As taxes can vary in country based on province, the needed column is ‘mean_tax_rate’ -> average tax rate in a country.
Also, as not all regions have data on taxes, you also want to be transparent and show the ‘perc_provinces_w_tax’ -> a 
column representing the percentage of provinces with available tax rates for each country (i.e. If US has 53 provinces, 
and 10 of them have tax rates, then for US it should show 0,19) */
WITH cum_sum AS (
 SELECT LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH) as OrderMonth,
       territory.CountryRegionCode,
       territory.Name as Region,
       COUNT(SalesOrderID) as Number_of_Orders,
       COUNT(DISTINCT CustomerID) as Number_of_Customers,
       COUNT(DISTINCT SalesPersonID) as Number_of_Salespersons,
       CAST(SUM(TotalDue) AS INTEGER) as Total_w_tax

FROM `adwentureworks_db.salesorderheader` as sales
LEFT JOIN `adwentureworks_db.salesterritory` as territory
ON sales.TerritoryID = territory.TerritoryID

GROUP BY LAST_DAY(CAST(sales.OrderDate AS DATETIME), MONTH),
         territory.CountryRegionCode,
         territory.Name
),

cum_sum_rank as (SELECT *,
       SUM(Total_w_tax) OVER(PARTITION BY CountryRegionCode,Region ORDER BY OrderMonth) as CumulativeSum,
       RANK() OVER(PARTITION BY CountryRegionCode ORDER BY Total_w_tax DESC) as CountrySalesRank
FROM cum_sum),

tax_info AS (
     SELECT CountryRegionCode, 
            province.StateProvinceID,
            ROUND(MAX(TaxRate),1) as MaxTaxRate
     FROM `adwentureworks_db.salestaxrate` as tax
     RIGHT JOIN `adwentureworks_db.stateprovince` as province
     ON tax.StateProvinceID = province.StateProvinceID
     GROUP BY CountryRegionCode,
              StateProvinceID
),

tax_info_avg AS (
     SELECT CountryRegionCode, 
            ROUND(AVG(MaxTaxRate),1) as MeanTaxRate,
            ROUND((SUM(CASE WHEN MaxTaxRate IS NOT NULL THEN 1
                     ELSE 0 END)/COUNT(*)),2) as Perc_provinces_w_tax
     FROM tax_info
     GROUP BY CountryRegionCode
)

SELECT OrderMonth,
     csr.CountryRegionCode,
     Region,
     Number_of_Orders,
     Number_of_Customers,
     Number_of_Salespersons,
     Total_w_tax,
     CountrySalesRank,
     CumulativeSum,
     MeanTaxRate,
     Perc_provinces_w_tax

FROM cum_sum_rank as csr
LEFT JOIN tax_info_avg as tax
ON csr.CountryRegionCode = tax.CountryRegionCode