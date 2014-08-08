package com.sparkydots.play.example.controllers

import play.api.mvc.{Action, Controller}
import com.sparkydots.play.example.views

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 6:49 PM
 */
object SecondApp extends Controller {
  def index = Action {
    Ok(views.html.index("Your new application is ready?"))
  }

}
