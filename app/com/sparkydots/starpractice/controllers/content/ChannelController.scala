package com.sparkydots.starpractice.controllers.content

import com.sparkydots.common.util.WithCors
import com.sparkydots.starpractice.models.responses.{ChannelListResponse, ActivityListResponse}
import com.sparkydots.starpractice.models.{Channel, Message, Activity}
import com.sparkydots.starpractice.services.Authenticator
import play.api.libs.json.Json
import play.api.mvc.{ResponseHeader, Result, Action, Controller}

object ChannelController extends Controller {

  def channel(chid: Int, st: Int, si: Int) = WithCors("GET") (Authenticator {
    profile =>
      Action { request =>
        try {
          var ssi = si
          if (si > 100) {
            ssi = 100
          }

          val activities = Activity.pageOfChannel(chid, st, ssi)
          val messages: List[Message] = List()
          val activitiesResponse = ActivityListResponse(messages, activities)
          Ok(Json.toJson(activitiesResponse))

        } catch {
          case e: Exception => Ok("{}")
        }
      }
  })

  def channelList(id: String, st: Int, si: Int) = WithCors("GET") (Authenticator {
    profile =>
      Action { request =>
        try {
          var ssi = si
          if (si > 100) {
            ssi = 100
          }

        val channels = Channel.pageForEndUser(id, st, ssi)
        val messages: List[Message] = List()
        val channelsResponse = ChannelListResponse(messages, channels)
        Ok(Json.toJson(channelsResponse))

        } catch {
          case e: Exception => Ok("{}")
        }
      }
  })
}
