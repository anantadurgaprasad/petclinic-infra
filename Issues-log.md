# InfraStructure Issues Log

This document tracks all the issues encountered during the development and validation of infra code, along with their solutions.

---

## Table of Contents
- [Issue 1](#issue-1)

<!-- Add links for each new issue here -->

---

## Issue 1

**Date:** 2024-12-08
**Description:**
When Deploying AWS ALB Controller with terraform and IRSA, the helm deployment failed because `controller went into crashloopback error`, On inspecting the controller pod logs  the error message showed
```
{"level":"error","ts":"2024-12-07T18:04:41Z","logger":"setup","msg":"unable to initialize AWS cloud","error":"failed to get VPC ID: failed to fetch VPC ID from instance metadata: error in fetching vpc id through ec2 metadata: get mac metadata: operation error ec2imds: GetMetadata, canceled, context deadline exceeded"}
```

**Root Cause:**
Explain the reason behind the issue, I used EKS version 1.30 and it has  issue with IMDSv2 . The hop limit is 1 . I didn't face this issue before because I was using lower EKS version and Nodes were not using IMDSv2.

**Solution:**

* Pass VpcId and region while deploying helm chart.
* Change the hop limit to 2
_"From this article on [IMDSv2 hop limit](https://aws.amazon.com/about-aws/whats-new/2020/08/amazon-eks-supports-ec2-instance-metadata-service-v2/) the EKS node launch template should have hop limit of 2 but when I checked it has hop limit of 1 . I found that for  EKS version < 1.30 the hop limit is 2"_
* Update the EKS module aws_eks_node_group resource with version attribute so it picks up latest Launch Template and AMI based on EKS version .
* Use EKS version < 1.30 until it's resolved.

**HelpedResources:**
https://opensource.hcltechsw.com/digital-experience/CF223/get_started/system_requirements/kubernetes/imds_limit/
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/#using-metadata-server-version-2-imdsv2
https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/deploy/installation/#using-metadata-server-version-2-imdsv2
