import io
import sys

from pyspark.ml import PipelineModel
from pyspark.sql import SparkSession

# Используйте как путь откуда загрузить модель
MODEL_PATH = 'spark_ml_model'


def process(spark, input_file, output_file):
    model = PipelineModel.load(MODEL_PATH)
    input_df = spark.read.options(header=True, inferschema="true").parquet(input_file)
    predictions = model.transform(input_df)
    predictions = predictions.select("ad_id", "prediction")
    predictions.write.mode('overwrite').parquet(output_file)
    print("="*100)
    predictions.show(5)
    print("="*100)


def main(argv):
    input_path = argv[0]
    print("Input path to file: " + input_path)
    output_file = argv[1]
    print("Output path to file: " + output_file)
    spark = _spark_session()
    process(spark, input_path, output_file)


def _spark_session():
    return SparkSession.builder.appName('PySparkMLPredict').getOrCreate()


if __name__ == "__main__":
    arg = sys.argv[1:]
    if len(arg) != 2:
        sys.exit("Input and Target path are require.")
    else:
        main(arg)
