import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Spark context:
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# Job init:
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
logger = glueContext.get_logger()

datasource0 = glueContext.create_dynamic_frame.from_catalog(database = "yolt-assignment", table_name = "yolt_assignment_data", transformation_ctx = "datasource0")

# Starting pipeline:
print('Message="Start of pipeline"')

applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("name", "string", "name", "string"), ("value", "float", "value", "float"), ("start_date", "date", "start_date", "date"), ("end_date", "date", "end_date", "date"), ("year_week", "string", "year_week", "string"), ("has_subtrackers", "boolean", "has_subtrackers", "boolean"), ("token", "string", "token", "string"), ("dataplatform_inserted_at", "timestamp", "dataplatform_inserted_at", "timestamp"), ("country", "string", "country", "string"), ("os_name", "string", "os_name", "string")], transformation_ctx = "applymapping1")


resolvechoice2 = ResolveChoice.apply(frame = applymapping1, choice = "make_struct", transformation_ctx = "resolvechoice2")


df_yolt_output = resolvechoice2.toDF()

s3_path_output = "s3://yolt-assignment-data/processed/"
df_yolt_output.repartition(1).write.mode("overwrite").parquet(s3_path_output)

job.commit()