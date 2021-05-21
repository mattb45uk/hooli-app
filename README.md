# Hooli Ping Application
This is a simple application designed to POC using AWS as a cloud provider.

The application is nodejs running in Docker on AWS Fargate.

The deployment mechanism uses CodePipeline, CodeCommit, CodeBuild and CodeDeploy to automate build and deployment when pushes are made to master. 