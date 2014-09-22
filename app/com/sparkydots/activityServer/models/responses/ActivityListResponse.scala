package com.sparkydots.activityServer.models.responses

import com.sparkydots.activityServer.models.{Activity, Message}
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:33 PM
 */

case class ActivityListResponse(messages: List[Message], activities: List[Activity])
object ActivityListResponse {
  implicit val activityListResponseFormat = Json.format[ActivityListResponse]

  def containing(activities: List[Activity]) = {
    val messages: List[Message] = List()
    ActivityListResponse(messages, activities)
  }

  def jsonContaining(activities: List[Activity]) = Json.toJson(containing(activities))

}