// read plain
val rdd = sc.textFile("s3://logs-sparkydots-incoming/logs/starpractice/*.gz")

// read as proper data
val df = sqlContext.read.json("s3://logs-sparkydots-incoming/logs/starpractice/*.gz")


