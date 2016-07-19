package com.sparkydots.starpractice.common.controllers

import com.sparkydots.starpractice.common.services.{WithCors, Authenticator}
import play.api.mvc.{Controller, Action}

class TouchController extends Controller {

  def touch(page: String, id: String) = WithCors("GET")(
    Authenticator { profile =>
      Action { request =>
        Ok("{}")
      }
    }
  )

}
