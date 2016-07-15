package com.sparkydots.activityServer

object ActivitiesData {

  def getData(id: String,
              attributes: Seq[String] = Seq("body"),
              tableName: String = "activity_definitions"): Map[String, String] = {

    import awscala._, dynamodbv2._
    implicit val dynamoDB = DynamoDB.at(Region.US_WEST_2)

    dynamoDB.table(tableName).flatMap { table =>
      table.get(id).map { el =>
        el.attributes.
          filter(attr => attributes.contains(attr.name)).
          flatMap { attr =>
            attr.value.s.map { value =>
              attr.name -> value
            }
          }.toMap
      }
    }.getOrElse(Map())
  }

}
