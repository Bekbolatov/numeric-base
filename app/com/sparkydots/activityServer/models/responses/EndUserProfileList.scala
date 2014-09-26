package com.sparkydots.activityServer.models.responses

import com.sparkydots.activityServer.models.{EndUserProfile, Message}
import play.api.libs.json.Json


case class EndUserProfileList(messages: List[Message], endUserProfiles: List[EndUserProfile])

object EndUserProfileList {
  implicit val endUserProfileListResponseFormat = Json.format[EndUserProfileList]

  def containing(endUserProfiles: List[EndUserProfile]) = {
    val messages: List[Message] = List()
    EndUserProfileList(messages, endUserProfiles)
  }

  def jsonContaining(endUserProfiles: List[EndUserProfile]) = Json.toJson(containing(endUserProfiles))

}