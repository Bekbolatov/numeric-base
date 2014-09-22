package com.sparkydots.starpractice.models.responses

import com.sparkydots.starpractice.models.{Channel, Message}
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:33 PM
 */

case class ChannelListResponse(messages: List[Message], channels: List[Channel])
object ChannelListResponse {
  implicit val channelListResponseFormat = Json.format[ChannelListResponse]

  def containing(channels: List[Channel]) = {
    val messages: List[Message] = List()
    ChannelListResponse(messages, channels)
  }

  def jsonContaining(channels: List[Channel]) = Json.toJson(containing(channels))

}