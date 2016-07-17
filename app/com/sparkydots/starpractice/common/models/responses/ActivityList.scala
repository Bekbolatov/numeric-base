package com.sparkydots.starpractice.common.models.responses

import com.sparkydots.starpractice.common.models._
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:33 PM
 */

case class ActivityList(messages: List[Message], activities: List[Activity])
object ActivityList {
  implicit val activityListResponseFormat = Json.format[ActivityList]

  def containing(activities: List[Activity]) = {
    val messages: List[Message] = List()
    ActivityList(messages, activities)
  }

  def jsonContaining(activities: List[Activity]) = Json.toJson(containing(activities))

}