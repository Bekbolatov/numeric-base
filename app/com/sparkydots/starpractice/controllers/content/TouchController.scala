package com.sparkydots.starpractice.controllers.content

import com.sparkydots.common.util.WithCors
import com.sparkydots.starpractice.services.Authenticator
import play.api.mvc.{Action, Controller}

object TouchController extends Controller {
  def touch(page: String, id: String) = WithCors("GET")(Authenticator {
    profile =>
      Action { request =>
        Ok("{}")
      }
  })
}
