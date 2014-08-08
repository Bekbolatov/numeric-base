package com.sparkydots.play.example.controllers

import com.sparkydots.play.example.views
import play.api.mvc.{Action, Controller}

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object Angular extends Controller {

  def index = Action {
    Ok(views.html.angular())
  }

}
