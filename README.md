# yolt-assignment


## Possible improvements to make it PRODUCTION ready:

- Use more variables for for repeatability, which can be plugged into the build tool

- Use Airflow for scheduling since Yolt use Airflow, for this single use-case / assignment, it's maybe a bit overkill, so used AWS native Workflows

- Role, policy
- Glue components (DB, workflow, Triggers (02:30AM), crawler, job)
- S3 buckets (encryption)
- 