package com.sparkydots.starpractice.common.models.responses

import com.sparkydots.starpractice.common.models._
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