package com.sparkydots.website.controllers

import com.sparkydots.website.views
//import play.api.Play.current
//import play.api.libs.concurrent.Execution.Implicits.defaultContext
import javax.inject.Inject

import play.api.mvc._

import scala.concurrent.Future
import play.api.i18n.{I18nSupport, MessagesApi}
import java.net.InetAddress

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
  */
class SparkyDots @Inject() (val messagesApi: MessagesApi) extends Controller with I18nSupport {

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
    val localhost = InetAddress.getLocalHost
//    val localIpAddress = localhost.getHostAddress
    Ok(localhost.toString)
  }

  def starpractice = Action {
    Ok(views.html.sparkydots.starpractice())
  }

  def appDemo(appName: String) = Action {
    Ok(views.html.sparkydots.appDemo(appName))
  }

 }