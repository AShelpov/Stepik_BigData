import io
import sys
import os
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, datediff, when
from pyspark.sql import functions as F
from pyspark.sql.types import IntegerType


def process(spark, input_file, target_path):
    df = spark.read.options(header="true", inferschema="true").parquet(input_file)  # read file
    df = rm_bugs(df, spark)  # delete advertisements with zero views and more than 0 clicks
    output_df = prepare_initial_df(df, spark)
    output_df = count_ctr(df, output_df, spark)
    train_df, test_df, validate_df = output_df.randomSplit([0.5, 0.25, 0.25], 42)

    target_path = os.path.join(os.getcwd(), target_path)
    os.mkdir(target_path)

    path_train = os.path.join(target_path, "train")
    os.mkdir(path_train)
    train_df.repartition(1).write.mode('overwrite').parquet(path_train)

    path_test = os.path.join(target_path, "test")
    os.mkdir(path_test)
    test_df.repartition(1).write.mode('overwrite').parquet(path_test)

    path_validate = os.path.join(target_path, "validate")
    os.mkdir(path_validate)
    validate_df.repartition(1).write.mode('overwrite').parquet(path_validate)

    print("Have finished jobs")


def rm_bugs(data_frame, spark):
    """
    remove ads with clicks and without views
    """
    data_frame.createOrReplaceTempView("ads")
    total_clicks = spark.sql("""
                             SELECT ad_id, count(ad_id) as total_clicks  
                             FROM ads 
                             WHERE event = 'click'
                             GROUP BY ad_id
                             """)
    total_views = spark.sql("""
                            SELECT ad_id, count(ad_id) as total_views  
                            FROM ads 
                            WHERE event = 'view'
                            GROUP BY ad_id
                            """)
    find_bug = total_clicks.join(total_views, on="ad_id", how="full_outer")
    find_bug.createOrReplaceTempView("find_bug")
    bug_ads = spark.sql("""
                        SELECT DISTINCT(ad_id) FROM find_bug
                        WHERE (total_clicks > 0) AND (total_views is null)
                        """)
    data_frame = data_frame.join(bug_ads, on="ad_id", how="left_anti")
    return data_frame


def prepare_initial_df(data_frame, spark):
    """
    prepare unique 'ad_id', 'target_audience_count', 'has_video', 'is_cpm', 'is_cpc', 'ad_cost', 'day_count' columns
    """
    data_frame.createOrReplaceTempView("ads")
    output_df = spark.sql("""
                          SELECT DISTINCT(ad_id), target_audience_count, has_video, ad_cost_type
                          FROM ads
                          """)  # prepare unique ads_id
    # prepare functions to replace CPM and CPC
    is_cpm_column = when(col("ad_cost_type") == "CPM", 1).when(col("ad_cost_type") == "CPC", 0)
    is_cpc_column = when(col("ad_cost_type") == "CPC", 1).when(col("ad_cost_type") == "CPM", 0)

    # create columns is_cpm and is_cpc with functions above
    output_df = output_df.withColumn("is_cpm", is_cpm_column)
    output_df = output_df.withColumn("is_cpc", is_cpc_column)
    output_df = output_df.drop("ad_cost_type")

    #  aggregate DataFrame to find day_count feature and join with output_df
    uniq_date = data_frame.groupBy("ad_id").agg(F.countDistinct("date").alias("day_count"))
    uniq_date = uniq_date.withColumn("day_count", col("day_count").cast(IntegerType()))
    output_df = output_df.join(uniq_date, on="ad_id", how="left")

    return output_df


def count_ctr(data_frame, initial_df, spark):
    """
    count CTR for ads
    """
    data_frame.createOrReplaceTempView("df_new")
    ctr_df = spark.sql("""
                       SELECT tv.ad_id, tv.total_views, tc.total_clicks
                       FROM
                         (SELECT ad_id, count(ad_id) as total_views
                         FROM df_new
                         WHERE event = 'view'
                         GROUP BY ad_id) as tv
                       LEFT JOIN
                         (SELECT ad_id, count(ad_id) as total_clicks
                         FROM df_new
                         WHERE event = 'click'
                         GROUP BY ad_id) as tc
                       ON tv.ad_id = tc.ad_id
                       """)
    ctr_df = ctr_df.withColumn("CTR", when(col("total_clicks").isNull(), 0).
                               otherwise(col("total_clicks") / col("total_views")))
    output_df = initial_df.alias("df1").join(ctr_df.alias("df2"), on="ad_id", how="left").select("df1.*", "df2.CTR")
    return output_df


def main(argv):
    input_path = argv[0]
    print("Input path to file: " + input_path)
    target_path = argv[1]
    print("Target path: " + target_path)
    spark = _spark_session()
    process(spark, input_path, target_path)


def _spark_session():
    return SparkSession.builder.appName('PySparkJob').getOrCreate()


if __name__ == "__main__":
    arg = sys.argv[1:]
    if len(arg) != 2:
        sys.exit("Input and Target path are require.")
    else:
        main(arg)
