package com.sparkydots.activityServer.controllers.content

import com.sparkydots.common.util.WithCors
import com.sparkydots.activityServer.services.Authenticator
import play.api.mvc.{Action, Controller}

object TouchController extends Controller {
  def touch(page: String, id: String) = WithCors("GET")(Authenticator {
    profile =>
      Action { request =>
        Ok("{}")
      }
  })
}
