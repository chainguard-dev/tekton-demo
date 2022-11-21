# tekton-demo
Tekton and Sigstore Demo 

1. Setup Tekton Build cluster
2. Setup Test AWS Cluster
3. Run Tekton build pipeline
4. Install Enforce on Test cluster
5. Demo time

Tools needed 

1. kubectl
2. tekton cli 
3. chainctl
4. terraform 
5. aws cli 
6. gcp cli 

Tekton is currently setup to run in GCP 

1. Set up GitHub OIDC 
2. Run terraform/development/1-infrastructure 
3. Run terraform/development/2-post-installation

Test Cluster is set up to run on AWS. 

1. Run terraform/development/eks


Demo prep 

* aws sso login 
* aws eks update-kubeconfig
* chainctl cluster install --group aws-customer-group 
* tkn pr describe $PIPELINE_RUN 
* tkn tr describe $SOURCE_TO_IMAGE_TR



