#Terrform file for Yolt assignment Infra-as-Code

#Creates s3 bucket for data assets
resource "aws_s3_bucket" "s3-module" {
  bucket = "${var.s3-bucket-name}"
  acl    = "private"
}

#Creates s3 bucket for ETL scripts
resource "aws_s3_bucket" "s3-scripts-module" {
  bucket = "${var.s3-scriptsbucket-name}"
  acl    = "private"
}

### New role creation
### Here assume_role_policy MUST be defined for the trust relationship
resource "aws_iam_role" "glue_service_role" {
  name = "GlueWorkflowRole"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "glue.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

### AWS policy ARN for existing service role
data "aws_iam_policy" "glue_service_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}


### Policy attachment
resource "aws_iam_role_policy_attachment" "glue_service_role_policy_attach" {
   role       = "${aws_iam_role.glue_service_role.name}"
   policy_arn = "${data.aws_iam_policy.glue_service_policy.arn}"
}

#Creates Glue components DB
resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "yolt-assignment"
  description = "Yolt assignment database"
  location_uri = "s3://yolt-assignment-2022"
}

#Creates Glue crawler
resource "aws_glue_crawler" "yolt_assignment_crawler" {
  database_name = "yolt-assignment"
  name          = "yolt_assignment_crawler"
  role          = "arn:aws:iam::473255871391:role/GlueWorkflowRole"

  s3_target {
    path = "s3://yolt-assignment-2022"
  }
}

#Creates Glue job
resource "aws_glue_job" "yolt-assignment-job" {
  name     = "yolt-assignment-job"
  role_arn = "arn:aws:iam::473255871391:role/GlueWorkflowRole"

  command {
    script_location = "s3://yolt-assignment-scripts-2022/yolt-transform.py"
  }
}

#Creates Glue Workflow / DAG
resource "aws_glue_workflow" "yolt-assignment-workflow" {
  name = "yolt-assignment-workflow"
}

#Creates Glue trigger 1
resource "aws_glue_trigger" "yolt-assignment-trigger1" {
  name     = "yolt-assignment-trigger1"
  schedule = "cron(30 2 * * ? *)"
  type     = "SCHEDULED"
  workflow_name = "yolt-assignment-workflow"

  actions {
    job_name = "yolt-assignment-job"
  }
}

#Creates Glue trigger 2
resource "aws_glue_trigger" "yolt-assignment-trigger2" {
  name = "yolt-assignment-trigger2"
  type = "CONDITIONAL"
  workflow_name = "yolt-assignment-workflow"

  predicate {
    conditions {
      job_name = "yolt-assignment-job"
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = "yolt_assignment_crawler"
  }
}
