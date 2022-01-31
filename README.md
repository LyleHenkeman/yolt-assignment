# yolt-assignment


## Possible improvements to make it PRODUCTION ready:

- Use more variables for for repeatability, which can be plugged into the build tool

- Use Airflow for scheduling since Yolt use Airflow, for this single use-case / assignment, it's maybe a bit overkill, so used AWS native Workflows

- Further more, I would send event logs to an external monitoring / dashboard system, which can be used to monitor failed jobs etc.

## Included:
- Role, policy
- Glue components (DB, workflow, Triggers, crawler, job)
- Cloudwatch logs are sent to a log group from Glue
- S3 buckets (encryption)

## Workflow:
- A scheduled trigger to run at 02:30 daily
- A PySpark Glue job to read data, performa a transformation & write the dataframe to s3 in parquet format
- Another trigger to initiate a crawler which catalogs the data from the transformation and allows it to be queried in Athena
