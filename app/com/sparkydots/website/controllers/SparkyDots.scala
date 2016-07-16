package com.sparkydots.website.controllers

import com.sparkydots.website.views
import com.sparkydots.modules.MyComponent
import javax.inject.Inject

import play.api.mvc._
import play.api.i18n.{I18nSupport, MessagesApi}

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
  */
class SparkyDots @Inject() (val messagesApi: MessagesApi, val myComponent: MyComponent) extends Controller with I18nSupport {

   def index = Action {
     Ok(views.html.sparkydots.index())
   }

  def avvo = Action {
    Ok(views.html.sparkydots.avvo())
  }

  def health = Action {
    Ok(views.html.sparkydots.health())
  }

  def machine = Action {
    Ok(myComponent.getMachineInfo)
  }

  def starpractice = Action {
    Ok(views.html.sparkydots.starpractice())
  }

  def appDemo(appName: String) = Action {
    Ok(views.html.sparkydots.appDemo(appName))
  }

 }