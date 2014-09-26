package com.sparkydots.activityServer.controllers.content

import com.sparkydots.common.util.WithCors
import com.sparkydots.activityServer.models.responses.{ChannelList, ActivityList}
import com.sparkydots.activityServer.models.{Channel, Message, Activity}
import com.sparkydots.activityServer.services.Authenticator
import play.api.libs.json.Json
import play.api.mvc.{ResponseHeader, Result, Action, Controller}

object ChannelController extends Controller {

  def channel(chid: String, st: Int, si: Int) = WithCors("GET") (Authenticator {
    profile =>
      Action { request =>
        try {
          var ssi = si
          if (si > 100) {
            ssi = 100
          }

          Ok(ActivityList jsonContaining Activity.pageOfChannel(chid, st, ssi))

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

          Ok(ChannelList jsonContaining Channel.pageForEndUser(id, st, ssi))

        } catch {
          case e: Exception => Ok("{}")
        }
      }
  })
}
