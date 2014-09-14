package com.sparkydots.play.example.converters

import com.sparkydots.play.example.models._
import play.api.libs.json.Json


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 7:08 PM
 */
object JsonFormats {
  implicit val personFormat = Json.format[Person]
  implicit val clientFormat = Json.format[Client]


  implicit val activityFormat = Json.format[Activity]
  implicit val messageFormat = Json.format[Message]
  implicit val activityListResponseFormat = Json.format[ActivityListResponse]


}
