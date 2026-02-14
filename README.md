# ☁️ AWS Immutable Web Server

## 📌 Project Overview
This project provisions a **self-healing, immutable web server** on AWS using Terraform. 
It follows the "Infrastructure as Code" pattern where servers are treated as cattle, not pets.

## 🏗️ Architecture
*(Insert your Diagram Screenshot Here)*

## 🔐 Security Decisions
* **No SSH Access:** Port 22 is strictly blocked. All configuration happens via `user_data` scripts.
* **Least Privilege:** Security Groups allow only HTTP traffic from the public internet.

## 🛠️ Tech Stack
* **IaC:** Terraform
* **Cloud:** AWS (VPC, EC2, SG)
* **Config Management:** Bash (Cloud-Init)
