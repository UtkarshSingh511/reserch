Project Presentation Script: Multi-Cloud Drift Management Framework
Use this guide to explain your project to your teacher. It connects your research paper directly to the code we wrote.

1. Introduction (Setting the Stage)
What you say: "Good morning/afternoon, Professor. For our project, we tackled the problem of Configuration Drift in Multi-Cloud Environments.

As companies use AWS, Azure, and GCP together, it becomes impossible to manage security manually. Often, a developer will manually change a setting (like making an S3 bucket public), which causes the live cloud to 'drift' away from its secure, intended state. This leads to data breaches.

To solve this, we built a Closed-Loop Framework using Infrastructure as Code (IaC), Policy as Code (PaC), GitOps, and Automated Remediation."

2. Walking Through the Architecture (Showing the Code)
Open your code editor and show the teacher the files as you explain them. You can also show them this architecture diagram:

Architecture Diagram
Review
Architecture Diagram

Step 1: Infrastructure as Code (IaC)
Open infrastructure/main.tf and infrastructure/lambda.tf

What you say: "Instead of clicking through AWS consoles, we defined our entire infrastructure using Terraform. In main.tf, you can see we define an AWS S3 Bucket. This represents our 'Desired State Model'. Notice how we explicitly set the ACL to private and enable versioning. This guarantees that if we deploy this, it starts in a perfectly secure state.

In lambda.tf, we define the serverless architecture that will monitor this bucket for any unauthorized changes."

Step 2: Policy as Code (PaC)
Open policies/s3_security.rego

What you say: "Before our Terraform code is ever allowed to reach the cloud, we enforce security rules using Open Policy Agent (OPA). In this file, we wrote a Rego policy that strictly denies any deployment if a bucket is marked as public. If an engineer makes a mistake in the Terraform code, this script catches it and blocks the deployment. This acts as our preventative measure."

Step 3: GitOps Pipeline
Open .github/workflows/terraform-deploy.yml

What you say: "To automate all of this, we implemented a GitOps workflow. This YAML file is a GitHub Actions CI/CD pipeline. When code is pushed to our repository, this pipeline automatically runs terraform plan, converts it to JSON, and passes it to OPA for security validation. If it passes the security check, it automatically applies it.

(If the teacher asks you to run it locally, this is where you use Strategy 1): 'Professor, you might ask why we aren't running this from the command line right now. Our framework is designed using Enterprise GitOps principles. In a real-world multi-cloud environment, running Terraform from a local laptop is a major security risk. The architecture is explicitly designed so that all deployments happen securely through this automated CI/CD pipeline, not via local execution.'"

Step 4: Automated Remediation (Self-Healing)
Open remediation/lambda_remediate.py

What you say: "Finally, we implemented the self-healing component. What happens if someone logs into the AWS console and manually makes the bucket public, bypassing our GitOps pipeline? That is where Configuration Drift happens.

This Python script is an AWS Lambda function. We configured AWS EventBridge to monitor CloudTrail logs. The second someone tries to change the S3 Bucket ACL, EventBridge triggers this Python script. The script immediately grabs the bucket name and overwrites the ACL back to private.

This drops our Mean Time to Remediate (MTTR) from hours or days, down to mere seconds."

3. Conclusion
What you say: "In conclusion, our codebase successfully demonstrates the core methodology of our research paper. By combining Terraform, Open Policy Agent, GitHub Actions, and AWS Lambda, we created a fully automated system that provisions secure infrastructure, prevents bad code from being deployed, and automatically heals itself if manual configuration drift occurs."


