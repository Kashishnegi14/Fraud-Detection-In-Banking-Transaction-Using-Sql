Fraud-Detection-in-Banking-Transactions-Using-SQL
Detecting Financial Fraud with SQL
Detecting fraudulent banking transactions using SQL techniques such as CTEs, subqueries, and pattern recognition. By analyzing real-world financial transaction data, we aim to identify suspicious activities such as:

Frequent High-Value Transactions: Customers making multiple large transactions in a short time frame.

Duplicate Transactions: Multiple transactions with identical amounts, timestamps, and recipients.

Unusual Withdrawals: Withdrawals at odd hours or from different locations in a short period.

The goal is to build a structured SQL-based fraud detection system that can be integrated into financial security frameworks, helping banks and financial institutions prevent unauthorized transactions and mitigate risks.

🔗 Technologies Used
MySQL (Database)
GitHub (Version Control)
🔗 Features
Detects high-value fraudulent transactions using SQL queries.
Identifies duplicate transactions by analyzing transaction patterns.
Flags unusual withdrawals based on time and location changes.
Stores suspicious transactions in a separate table for further analysis.
Uses optimized SQL techniques to ensure efficient query execution.
🔗 How to Run This Project
Set up MySQL and create a database for transactions.
Create a bank_transactions table and load the dataset.
Run the SQL queries to detect fraudulent transactions.
Store flagged transactions in the flaggedtransactions table for further analysis.
