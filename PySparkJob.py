import io
import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, datediff, when
from pyspark.sql import functions as F


def process(spark, input_file, target_path):
    df = spark.read.options(header="true", inferschema="true").parquet(input_file)  # read file
    df = rm_bugs(df, spark)  # delete advertisements with zero views and more than 0 clicks
    output_df = prepare_initial_df(df, spark)


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
    output_df = output_df.join(uniq_date, on="ad_id", how="left")

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
