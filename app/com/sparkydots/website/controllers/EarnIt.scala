package com.sparkydots.website.controllers

import com.sparkydots.website.views
//import play.api.Play.current
//import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.mvc._

import scala.concurrent.Future

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 9/21/14 11:42 PM
  */
object EarnIt extends Controller {

   def index = Action {
     Ok(views.html.earnit.index())
   }

 }