package com.sparkydots.website.controllers

import com.sparkydots.website.views
//import play.api.Play.current
//import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.mvc._

import scala.concurrent.Future

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
  */
object StarPractice extends Controller {

   def index = Action {
     Ok(views.html.starpractice.index())
   }

 }