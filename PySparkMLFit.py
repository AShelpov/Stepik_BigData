import io
import sys

from pyspark.ml import Pipeline
from pyspark.ml.evaluation import RegressionEvaluator
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.regression import DecisionTreeRegressor
from pyspark.sql import SparkSession


# Используйте как путь куда сохранить модель
MODEL_PATH = 'spark_ml_model'


def process(spark, train_data, test_data):
    train_df = spark.read.options(header=True, inferschema="true").parquet(train_data)
    test_df = spark.read.options(header=True, inferschema="true").parquet(test_data)
    feature = VectorAssembler(inputCols=["target_audience_count", "has_video", "is_cpm",
                                         "is_cpc", "ad_cost", "day_count"],
                              outputCol="features")
    evaluator = RegressionEvaluator(labelCol="ctr", predictionCol="prediction", metricName="rmse")
    tr = DecisionTreeRegressor(labelCol="ctr", featuresCol="features", maxDepth=7,
                               maxBins=100, minInstancesPerNode=2)
    pipeline_tr = Pipeline(stages=[feature, tr])
    model = pipeline_tr.fit(train_df)
    predictions = model.transform(test_df)
    model.write().overwrite().save(MODEL_PATH)
    print("=" * 100)
    print(f"Estimate model with rmse={evaluator.evaluate(predictions)}")
    print("=" * 100)


def main(argv):
    train_data = argv[0]
    print("Input path to train data: " + train_data)
    test_data = argv[1]
    print("Input path to test data: " + test_data)
    spark = _spark_session()
    process(spark, train_data, test_data)


def _spark_session():
    return SparkSession.builder.appName('PySparkMLFitJob').getOrCreate()


if __name__ == "__main__":
    arg = sys.argv[1:]
    if len(arg) != 2:
        sys.exit("Train and test data are require.")
    else:
        main(arg)
