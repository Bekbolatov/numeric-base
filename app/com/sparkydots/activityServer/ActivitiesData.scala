package com.sparkydots.activityServer

import play.api.Logger
import javax.inject.Inject
import awscala._, dynamodbv2._

class ActivitiesData { //@Inject() (configuration: play.api.Configuration) {

//  val activitiesContentTable = configuration.underlying.getString("starpractice.activities.table")
  val activitiesContentTable = "starpractice_activities"
  val activitiesContentBodyField = "body"
  Logger.info(s"ActivitiesData with activitiesContentTable = $activitiesContentTable")

  val awsCredentialsURI = sys.env.get("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI")
  println(s"Credential URI length: ${awsCredentialsURI.map(_.length).getOrElse(0)}")

  def getData(id: String,
              version: String,
              attributes: Seq[String] = Seq(activitiesContentBodyField),
              tableName: String = activitiesContentTable): Map[String, String] = {

//    if (awsCredentialsURI.length > 3) {
//    }

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

    implicit val dynamoDB = DynamoDB.at(Region.US_WEST_2)

    dynamoDB.table(tableName).foreach { table =>
      Logger.info("new activity content")
      table.putItem(id, version, attribute -> data)
    }
  }

}
