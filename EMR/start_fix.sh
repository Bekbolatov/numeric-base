#tunnel/proxy: ssh -i  ~/.ssh/panerapig.pem -N -D 8157 hadoop@ec2-50-112-3-5.us-west-2.compute.amazonaws.com
# resource manager:8088

sudo su - hdfs
hdfs dfs -mkdir /user/ec2-user
hdfs dfs -chown ec2-user /user/ec2-user




