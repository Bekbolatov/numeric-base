package com.sparkydots.website.main.controllers

import com.sparkydots.website.main.views
import com.sparkydots.modules.LogHelper
import javax.inject.Inject

import play.api.mvc._
import play.api.i18n.{I18nSupport, MessagesApi}

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
  */
class SparkyDots @Inject() (val messagesApi: MessagesApi, val myComponent: LogHelper) extends Controller with I18nSupport {

   def index = Action {
     Ok(views.html.index())
   }

  def avvo = Action {
    Ok(views.html.avvo())
  }

  def health = Action {
    Ok(views.html.health())
  }

  def machine = Action {
    Ok(myComponent.getMachineInfo)
  }

  def starpractice = Action {
    Ok(views.html.starpractice())
  }

  def appDemo(appName: String) = Action {
    Ok(views.html.appDemo(appName))
  }

 }