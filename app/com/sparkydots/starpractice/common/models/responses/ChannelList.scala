package com.sparkydots.starpractice.common.models.responses

import com.sparkydots.starpractice.common.models._
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:33 PM
 */

case class ChannelList(messages: List[Message], channels: List[Channel])
object ChannelList {
  implicit val channelListResponseFormat = Json.format[ChannelList]

  def containing(channels: List[Channel]) = {
    val messages: List[Message] = List()
    ChannelList(messages, channels)
  }

  def jsonContaining(channels: List[Channel]) = Json.toJson(containing(channels))

}