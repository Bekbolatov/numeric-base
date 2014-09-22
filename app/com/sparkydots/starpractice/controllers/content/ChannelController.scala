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

          Ok(ActivityListResponse jsonContaining Activity.pageOfChannel(chid, st, ssi))

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

          Ok(ChannelListResponse jsonContaining Channel.pageForEndUser(id, st, ssi))

        } catch {
          case e: Exception => Ok("{}")
        }
      }
  })
}
