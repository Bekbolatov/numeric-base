package com.sparkydots.starpractice.content.controllers

import com.sparkydots.starpractice.common.models._
import com.sparkydots.starpractice.common.models.responses._
import com.sparkydots.starpractice.common.services.Authenticator
import play.api.mvc.{Controller, Action}
import Math.min

import com.sparkydots.starpractice.common.services.WithCors

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
