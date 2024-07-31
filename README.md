# prisma_ecs_runtime_defense

Hi, this is a brief article of how to deploy an AWS ECS task definition with Prisma Cloud Serverless Runtime defense with Terraform and Azure Devops. 
There aren’t any real examples of how to include runtime defence via CICD online so I thought it apt to share this with those interested. 

Before starting here are a few prerequisites:
-	A deployed container image in AWS ECR.
-	A fargate task json file (‘original_task_defnition.json’) – I have included an example in the repo.

Prisma Cloud Runtime defense is imperative because it safeguards your app against threats which emerge after deployment. It is noteworthy that embedding a defender in your fargate task also instantiates vulnerability scanning and visibility into compliance risks. In laymens terms, Prisma deploys a side car container which runs alongside your task, in conjunction the entrypoint of you task is changed to twistlock, wrapping your container similar to what happens when embedding a Prisma Cloud serverless defender on an AWS Lambda function. 
(https://docs.prismacloud.io/en/classic/compute-admin-guide/install/deploy-defender/app-embedded/install-app-embedded-defender-fargate)

In the repo Ive included a ‘main.tf’ terraform script, this is a super basic deployment, merely specifying the ecs execution role, creation of an ecs cluster and task with our generated protected task.
On the Azure Devops side, ive automated the whole deployment within one pipeline and two stages, this can be adjusted as need be, and is not limited to a specific CICD technology. The pipeline orchestrates the retrieval of the ‘original_task_definition.json’ and generates a ‘protected_task.json’ with runtime defense capabilities. The use of terraform ensures that automation can be done consistently and be repeatedly deployed within whatever CICD workflow. 

In summary this is what happens:
-	The protected task definition is obtained through a script task in the pipeline by authenticating with your Prisma Cloud console, and it stores the new task as a pipeline artifact. 
-	The new protected task artifact is retrieved in the last stage by Azure devops and is set as a Terraform environment variable (TF_VAR_task_definition_path).
-	Terraform deploys the ECS Task with the generated protected_task.json as its task definition json. 

In the repo, find attached the ‘generate_secure_task.sh’ which is a separate script which can be used for local testing. 
