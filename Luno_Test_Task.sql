-- Average Monthly Income Grouped by Job Type

SELECT job_type, AVG(monthly_income) avg_m
FROM LunoTask.Luno
GROUP BY job_type
ORDER BY avg_m DESC;

--Mean number of times people were contacted in the previous campaign and grouped according to their Job Type

SELECT job_type, AVG(contacted_previous_campaign) avg_c
FROM LunoTask.Luno
GROUP BY job_type
ORDER BY avg_c DESC; 

--Mean number of times a person was contacted and grouped accoring to their contact type

SELECT AVG(contacted_current_campaign), contact_information_type
FROM LunoTask.Luno
GROUP BY contact_information_type;

--Calculating whether someone who bought the current campaign is correlated to the duration of a call 

SELECT CORR(durations, CAST(did_buy_current_campaign AS int64))
FROM LunoTask.Luno; -- Correlation = 0.37

SELECT AVG(durations)
FROM LunoTask.Luno
WHERE did_buy_current_campaign = true; -- Average duration of a call that was succesfull was 511.88

SELECT AVG(durations)
FROM LunoTask.Luno
WHERE did_buy_current_campaign = false; -- Average duration of a call that was unsuccesfull was 227.53

--Analyzing whether number of times being contacted has any impact on the success of the current campaign

SELECT did_buy_current_campaign, AVG(contacted_current_campaign) avg_ccc
FROM LunoTask.Luno
GROUP BY did_buy_current_campaign; -- Average ccc for True = 2.11, Average ccc for False = 2.75

SELECT CORR(CAST(did_buy_current_campaign AS int64), contacted_current_campaign)
FROM LunoTask.Luno; -- Correlation between contacted and bought = -0.08, my conclussion is there is not a relationship between the two

--Calculating to see if there is any Correlation between the age of a customer and being contacted more than 30 times

SELECT age, contacted_previous_campaign
FROM LunoTask.Luno
WHERE contacted_previous_campaign >= 30; -- Wrote a query to see how big the dataset is and what the data looks like to try and identify a pattern

SELECT CORR(age, contacted_previous_campaign)
FROM LunoTask.Luno
WHERE contacted_previous_campaign >= 30; -- Correlation came out as 0.985 which means the data is heaviliy correlated

-- Listing a count of every customer who bought the new campaign and categorized following their job type

SELECT COUNT(job_type) c_jobtype,job_type
FROM LunoTask.Luno
WHERE did_buy_current_campaign is true
GROUP BY job_type
ORDER BY c_jobtype DESC;

-- Running a check on what values are listed in the previous campaign, realising they aren't boolean like the current campaign

SELECT did_buy_previous_campaign
FROM LunoTask.Luno
GROUP BY did_buy_previous_campaign;

-- Created a new table featuring only data where we know whether a customer bought or didn't buy the previous campaign along with the current campaign data

CREATE TABLE LunoTask.Relationship
AS SELECT
  CASE  WHEN did_buy_previous_campaign = 'failure' then 'false' 
        WHEN did_buy_previous_campaign = 'success' then 'true'
        ELSE did_buy_previous_campaign
        END as bought_previous,
  did_buy_current_campaign
FROM LunoTask.Luno
WHERE did_buy_previous_campaign in ('success','failure');

SELECT COUNT(bought_previous)
FROM LunoTask.Relationship
WHERE bought_previous = 'true'; -- 706 people bought the previous campaign


CREATE TABLE LunoTask.Relationship2
AS SELECT
  CAST(bought_previous as bool) as bought_previous,
  CAST(did_buy_current_campaign as int64) as did_buy_current
FROM LunoTask.Relationship;

SELECT CORR(did_buy_current, CAST(bought_previous AS int64))
FROM LunoTask.Relationship2; -- Correlation between buying the first campaign and second campaign = 0.46

CREATE TABLE LunoTask.Relationship3
AS SELECT
  CAST(bought_previous as INT64) as bought_previous,
      did_buy_current
FROM LunoTask.Relationship2
WHERE bought_previous = true; 

SELECT did_buy_current, bought_previous
FROM LunoTask.Relationship3
WHERE did_buy_current = 1; -- Calculating how many customers bought the previous and current campaign, came out as 442

SELECT did_buy_current, bought_previous
FROM LunoTask.Relationship3
WHERE did_buy_current = 0; -- 264 people bought the previous campaign but not the current campaign


CREATE TABLE LunoTask.Relationship4
AS SELECT
  CAST(bought_previous as INT64) as bought_previous,
      did_buy_current
FROM LunoTask.Relationship2
WHERE bought_previous = false;

SELECT did_buy_current, bought_previous
FROM LunoTask.Relationship4
WHERE did_buy_current = 1; -- 280 people bought the current campaign but did not buy the previous campaign

SELECT did_buy_current, bought_previous
FROM LunoTask.Relationship4
WHERE did_buy_current = 0; -- 1478 people did not buy either one of the campaigns


-- To calculate whether there is a consistent buyer behaviour between the previous campaign and the current, I first calculated that there were 2464 customer data avaliable to conduct further analysis, there were:
    --442 multi buyers
    --280 new buyers the current campaign but not the previous campaign
    --264 people bought the previous campaign but not the current campaign
    --1478 people did not buy either one of the campaigns
    --My conclusion then, is that there is a consistent buyer behaviour pattern taking place during these studies

--Creating a table to feature the top 100 customers who bought the previous campaign and ranking them according to the duration of their calls, only considering customers who's calls had a duration greater than 500

CREATE TABLE LunoTask.Top100
  AS SELECT
    durations,
    did_buy_previous_campaign,
    contacted_previous_campaign
FROM LunoTask.Luno
WHERE did_buy_previous_campaign in ('success')
ORDER BY durations DESC
LIMIT 100;

SELECT AVG(contacted_previous_campaign)
FROM LunoTask.Top100

--We contacted a top 100 customer on a average of 3.41 times
