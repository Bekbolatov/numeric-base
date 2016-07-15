package com.sparkydots.activityServer

import javax.inject.Inject

class ActivitiesData { //@Inject() (configuration: play.api.Configuration) {

  import play.api.Logger


//  val activitiesContentTable = configuration.underlying.getString("starpractice.activities.table")
  val activitiesContentTable = "starpractice_activities"
  val activitiesContentBodyField = "body"

  Logger.info(s"ActivitiesData with activitiesContentTable = $activitiesContentTable")

  def getData(id: String,
              version: String,
              attributes: Seq[String] = Seq(activitiesContentBodyField),
              tableName: String = activitiesContentTable): Map[String, String] = {

    import awscala._, dynamodbv2._
    implicit val dynamoDB = DynamoDB.at(Region.US_WEST_2)

    dynamoDB.table(tableName).flatMap { table =>
      table.get(id, version).map { el =>
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

  def putActivityBody(id: String,
              version: String,
              data: String,
              attribute: String = activitiesContentBodyField,
              tableName: String = activitiesContentTable) = {

    import awscala._, dynamodbv2._
    implicit val dynamoDB = DynamoDB.at(Region.US_WEST_2)

    dynamoDB.table(tableName).foreach { table =>
      Logger.info("new activity content")
      table.putItem(id, version, attribute -> data)
    }
  }

}
