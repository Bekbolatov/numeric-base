package com.sparkydots.play.example.models

import java.util.Date

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:33 PM
 */

case class Message(id: Int, priority: Int, content: String)
case class ActivityListResponse(messages: List[Message], activities: List[Activity])
