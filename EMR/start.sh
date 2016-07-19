Might be something like this still, but need to find out how to do it:
 1) on spot instances
 2) using json specification

noglob aws emr create-cluster
--name Avito3
--release-label emr-4.7.2
--instance-groups file://./configs/instance-groups.json
--service-role EMR_DefaultRole
--ec2-attributes file://./configs/ec2-attributes.json
--applications  file://./configs/applications.json

noglob aws emr create-cluster --name Avito3 --release-label emr-4.7.2 --instance-groups file://./configs/instance-groups.json --service-role EMR_DefaultRole --ec2-attributes file://./configs/ec2-attributes.json --applications  file://./configs/applications.json



// stop
// terminate-clusters --cluster-ids j-2MSXR8FY0L5V1





/////////////
// old --bootstrap-actions file://./configs/bootstrap-actions.json
//[--instance-type c3.2xlarge --instance-count 13]
// "InstanceGroupType": "MASTER"|"CORE"|"TASK"

-instance-groups (list)

    A specification of the number and type of Amazon EC2 instances to create instance groups in a cluster.

    Each instance group takes the following parameters: [Name], InstanceGroupType, InstanceType, InstanceCount, [BidPrice], [EbsConfiguration] . [EbsConfiguration] is optional. EbsConfiguration takes the following parameters: EbsOptimized and EbsBlockDeviceConfigs . EbsBlockDeviceConfigs is an array of EBS volume specifications, which takes the following parameters : ([VolumeType], [SizeInGB], Iops) and VolumesPerInstance which is the count of EBS volumes per instance with this specification.

JSON Syntax:

[
  {
    "InstanceCount": integer,
    "Name": "string",
    "InstanceGroupType": "MASTER"|"CORE"|"TASK",
    "EbsConfiguration": {
      "EbsOptimized": true|false,
      "EbsBlockDeviceConfigs": [
        {
          "VolumeSpecification": {
            "Iops": integer,
            "VolumeType": "string",
            "SizeInGB": integer
          },
          "VolumesPerInstance": integer
        }
        ...
      ]
    },
    "BidPrice": "string",
    "InstanceType": "string"
  }
  ...
]



