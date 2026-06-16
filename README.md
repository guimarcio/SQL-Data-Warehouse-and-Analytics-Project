# SQL Data Warehouse & Analytics Solution

A practical data engineering and analytics project focused on building a modern data warehouse in SQL Server. The project covers the complete workflow from raw data ingestion to analytical reporting, following industry-standard warehousing practices.

---

## 📊 Solution Architecture

This project implements a Medallion-style architecture consisting of three processing layers:

![Architecture Diagram](docs/architecture.png)

### Bronze Layer

* Stores source data in its original format.
* Loads ERP and CRM CSV files into SQL Server without significant transformations.
* Acts as the system's raw data repository.

### Silver Layer

* Performs data cleansing and validation.
* Standardizes formats and resolves quality issues.
* Produces consistent and reliable datasets for downstream processing.

### Gold Layer

* Contains curated business-ready datasets.
* Implements dimensional modeling using a star schema design.
* Supports reporting, dashboarding, and analytical workloads.

---

## 📌 Project Summary

The goal of this project is to design and implement a centralized data warehouse that integrates information from multiple business systems and transforms it into a format suitable for analysis.

Key components include:

* Designing a layered data warehouse architecture.
* Developing ETL workflows to move and transform data.
* Creating fact and dimension tables for analytical querying.
* Producing SQL-driven business insights and reports.

### Skills Demonstrated

* SQL Development
* Data Warehousing
* ETL Design & Implementation
* Data Modeling
* Data Engineering
* Business Analytics

---

## 🎯 Business Requirements

### Data Warehouse Development

#### Goal

Build a SQL Server data warehouse that consolidates sales-related information from different operational systems into a single analytical platform.

#### Requirements

* Import ERP and CRM datasets provided as CSV files.
* Address data quality issues during transformation stages.
* Merge multiple source systems into a unified analytical model.
* Focus on the most recent available data (historical tracking is out of scope).
* Maintain documentation describing the warehouse structure and business entities.

---

### Analytics & Reporting

#### Goal

Generate analytical outputs that help stakeholders understand business performance and support decision-making.

#### Analysis Areas

* Customer Analysis
* Product Performance Evaluation
* Sales Trend Monitoring
* Business KPI Reporting

The final data model is designed to provide reliable metrics and actionable insights for business users.

---

## 📁 Repository Layout

```text
data-warehouse-project/
│
├── datasets/
│   └── Source ERP and CRM datasets
│
├── docs/
│   ├── architecture.png
│   ├── data_catalog.md
│   ├── data_flow.png
│   ├── data_model.png
|   └── integration_model_silver.png
│   
│
├── scripts/
│   ├── bronze/
│   │   └── Raw data loading scripts
│   │
│   ├── silver/
│   │   └── Data cleansing and transformation scripts
│   │
│   └── gold/
│       └── Dimensional model and reporting scripts
│
├── README.md
├── LICENSE
└── .gitignore
```

---

## 🏆 Outcomes

By completing this project, the following objectives were achieved:

* Centralized data from multiple source systems.
* Improved data quality through structured transformation processes.
* Built a scalable dimensional model for analytics.
* Delivered business-focused SQL reports and insights.

---

## 📄 License

This repository is available under the MIT License. Feel free to use, modify, and extend the project for educational or portfolio purposes.
