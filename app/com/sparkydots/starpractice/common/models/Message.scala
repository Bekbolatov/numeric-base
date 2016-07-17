package com.sparkydots.starpractice.common.models

import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 7:51 PM
 */

case class Message(id: Int, priority: Int, content: String)

object Message {
  implicit val messageFormat = Json.format[Message]
}