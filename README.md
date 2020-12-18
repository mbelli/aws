On premises:

1. On premises connected to AWS cloud via File Gateway (AWS Storage Gateway)
2. File Gateway is a service that enables hybrid cloud architectures that allow for low latency access to your hot data in its local cache, while all your data is stored in Amazon S3

AWS Cloud:

1. Raw file is added to S3 bucket
2. Amazon S3 event notification is placed in an SQS queue
3. Notification is consumed by a Lambda function that routes the event to the correct extraction, transformation, and loading (ETL) process based on the metadata
4. Event is routed to the first step function in the ETL process, which transforms and moves data from the raw data area to the staging area for the data lake
5. DynamoDB table holds operational metadata about a single object stored in Amazon S3
6. CloudWatch Events rule triggers a Lambda function

AWS CloudFormation reproducible and fast deployments with easy operations and administration.

Technology stack

Technology stack  
Amazon CloudWatch Events
AWS CloudFormation
AWS CodePipeline
AWS CodeBuild
AWS CodeCommit
Amazon DynamoDB
AWS Glue
AWS Lambda
Amazon S3
Amazon SQS
AWS Step Functions
