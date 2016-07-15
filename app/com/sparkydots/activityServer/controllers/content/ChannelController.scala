package com.sparkydots.activityServer.controllers.content

import com.sparkydots.common.util.WithCors
import com.sparkydots.activityServer.models.responses.{ChannelList, ActivityList}
import com.sparkydots.activityServer.models.{Channel, Message, Activity}
import com.sparkydots.activityServer.services.Authenticator
import play.api.libs.json.Json
import play.api.mvc.{ResponseHeader, Result, Action, Controller}
import Math.min
import scala.util.Try

class ChannelController extends Controller {

  def channel(chid: String, st: Int, si: Int) = WithCors("GET")(
    Authenticator { profile =>
      Action { request =>
        Try {
          Ok(ActivityList jsonContaining Activity.pageOfChannel(chid, st, min(si, 100)))
        } getOrElse Ok("{}")
      }
    }
  )

  def channelList(id: String, st: Int, si: Int) = WithCors("GET")(
    Authenticator { profile =>
      Action { request =>
        Try {
          Ok(ChannelList jsonContaining Channel.pageForEndUser(id, st, min(si, 100)))
        } getOrElse Ok("{}")
      }
    }
  )

}
