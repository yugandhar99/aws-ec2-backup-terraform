# Portfolio Notes

## Project Title

AWS EC2 Backup Automation with Terraform

## GitHub Description

Production-style AWS Backup solution for EC2 using Terraform, KMS encryption, tag-based backup selection, SNS alerts, optional cross-region copy, drift detection, Checkov scanning, and optional GenAI backup summaries.

## Resume Bullet

Built an AWS EC2 backup automation solution using Terraform and AWS Backup with encrypted backup vaults, tag-based backup selection, lifecycle retention, optional cross-region copy, SNS notifications, Backup Vault Lock, GitHub Actions validation, drift detection, and AI-assisted backup reporting.

## Interview Explanation

I created this project to demonstrate how EC2 backup operations can be standardized using Terraform and AWS Backup. Instead of writing custom snapshot scripts, the solution uses AWS Backup plans, backup selections, KMS-encrypted vaults, lifecycle retention rules, and tag-based selection so teams can onboard EC2 instances by applying a backup tag.

I also added current-market improvements like GitHub Actions quality checks, Checkov IaC scanning, TFLint, drift detection, optional cross-region copy for DR, optional Backup Vault Lock for stronger retention governance, SNS notifications, and a small GenAI-style backup summary helper to convert backup job data into an operations report.

## Career Progression Angle

This project shows progression from basic Terraform provisioning into cloud platform engineering. It covers infrastructure automation, backup governance, security, DR readiness, compliance thinking, CI validation, and modern AI-assisted operations reporting.
