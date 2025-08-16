# Netflix_Data_Analysis_Project-SQL-Python
🔹 Project Overview

This project demonstrates a complete ETL and Data Analysis pipeline using Python, SQL Server, and Data Modeling techniques.
The workflow covers:

Uploading raw data into SQL Server using Python

Cleaning and transforming the data directly in SQL Server

Running SQL queries for insightful analysis

🔹 Tech Stack

Python (Pandas, SQLAlchemy) – for uploading data

SQL Server – for data cleaning, transformation, and modeling

🔹 Steps in the Project

Data Upload (Python → SQL Server)

Used pandas and SQLAlchemy to load Netflix dataset into SQL Server.

Data Cleaning (SQL Server)

Removed duplicates

Handled missing values (e.g., unknown directors)

Converted data types (dates, duration, etc.)


Data Analysis (SQL Queries)

1.Generate a new table for directors columns 
2. for each director count the number of movies and tv shows created by them in separate columns fro director	who have created tv shows and movies both
3..for each year(as per date added to netflix ),which director has the maximum number of movies released 
4.what is the average duration of movies in each genre 
5.find the list of directors who have created horror and comedy movies both.
display director name along with number of comedy and horror movies directed by them 
