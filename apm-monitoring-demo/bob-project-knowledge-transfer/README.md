# Bob Project Knowledge Transfer Guide

This folder contains beginner-friendly documentation for understanding the Bob project from a DevOps and SRE point of view.

## Important note

This documentation is based only on:

- the repository links you shared
- the screenshots you shared
- inferred GitOps and CI/CD patterns visible from those screenshots

It does **not** modify any existing repository code.
It is intended as a learning and handover guide for a DevOps engineer who is new to the project.

## What this guide explains

1. Overall Bob platform architecture
2. Difference between microservice deployment and inference model deployment
3. ArgoCD-based deployment flow for Bob microservices
4. GitHub Actions based deployment flow for AI inference models
5. How config changes are typically made by DevOps/SRE teams
6. How PR review, merge, sync, DR, and CR likely fit into the process
7. Beginner glossary for important DevOps terms

## Source repositories referenced

- Bob microservices ArgoCD deployment repo:
  `https://github.ibm.com/automation-paas-cd-pipeline/wxca-argocd-deployments/tree/main/bob/application/prod`

- Cluster / platform / upgrade related repo:
  `https://github.ibm.com/automation-paas-cd-pipeline`

- AI / MLOps / model deployment repo:
  `https://github.ibm.com/code-assistant/cme3-devops-mlops`

## Suggested reading order

- [01-overall-architecture.md](./01-overall-architecture.md)
- [02-microservice-deployment-flow.md](./02-microservice-deployment-flow.md)
- [03-inference-model-deployment-flow.md](./03-inference-model-deployment-flow.md)
- [04-change-management-pr-review-sync-dr-cr.md](./04-change-management-pr-review-sync-dr-cr.md)
- [05-beginner-glossary.md](./05-beginner-glossary.md)

## What you should understand after reading

After reading this folder, you should be able to explain:

- where Bob microservice deployment configuration lives
- why ArgoCD is used for microservices
- where model deployment logic appears to live
- why GitHub Actions is likely used for model deployment
- how a config change moves from edit to PR to merge to deployment
- where DevOps, SRE, and platform responsibilities usually split
- how DR and CR automation may be connected to the deployment process

## Confidence level

Because direct repository file access was not available in the workspace, some parts of this guide are marked as:

- **Observed**: directly visible in screenshots/links
- **Inferred**: strongly suggested by naming and structure
- **Assumed**: common enterprise DevOps pattern, but should be validated internally

Use this guide as a strong onboarding document, then validate exact implementation details with your team.
