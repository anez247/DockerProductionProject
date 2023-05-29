# Overview

This project is based on automation of Docker image build and upload into DockerHub using declarative Jenkins pipeline

- Automating Jenkins instance creation and docker installation
- Automating Docker image creation
- Automating Docker image upload
- Automating Docker container provisioning

You can configure pipeline in your Jenkins instance(with Docker also installed) by creating a Declarative pipeline.

# Pre-requisites

1. Create Credentials for connecting to Docker registry
2. Create scripted pipeline using Jenkinsfile from this repo
3. Install Docker Plugins (Docker + Docker Pipeline)


# Steps

Create an EC2 instance, install Jenkins and Docker using Terraform
Jenkins Configuration & plugins
Create Credentials for connecting to Docker registry
Install Docker Plugins (Docker + Docker Pipeline)
Create scripted pipeline using Jenkinsfile from this repo
Docker Image Build
Docker Image Upload into DockerHub


# steps to automate WebApp project in Jenkins:
 
1. Login to Jenkins. Click on New item.
2. Enter an item name --> select Pipeline.
3. Create scripted pipeline using Jenkinsfile from this repo
4. Click on Build - Build the pipeline
5. Optional - Create webhook for automated code push
6. Optional - Access Python App via port 8096



Use endpoint URL http://ec2-34-246-173-18.eu-west-1.compute.amazonaws.com:8096 to access the page

