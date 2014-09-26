package com.sparkydots.activityServer.models.responses

import com.sparkydots.activityServer.models.{EndUserProfile, Message}
import play.api.libs.json.Json


case class EndUserProfileListResponse(messages: List[Message], endUserProfiles: List[EndUserProfile])

object EndUserProfileListResponse {
  implicit val endUserProfileListResponseFormat = Json.format[EndUserProfileListResponse]

  def containing(endUserProfiles: List[EndUserProfile]) = {
    val messages: List[Message] = List()
    EndUserProfileListResponse(messages, endUserProfiles)
  }

  def jsonContaining(endUserProfiles: List[EndUserProfile]) = Json.toJson(containing(endUserProfiles))

}