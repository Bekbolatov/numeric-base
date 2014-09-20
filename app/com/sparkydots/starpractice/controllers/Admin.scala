package com.sparkydots.starpractice.controllers

import com.sparkydots.starpractice.services.Authenticator
import com.sparkydots.starpractice.views
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Admin extends Controller {
  def index =
    Action { implicit request =>
      Ok(views.html.admin.index())
    }
}

