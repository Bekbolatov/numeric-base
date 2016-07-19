package com.sparkydots.util.controllers

import javax.inject.Inject

import com.sparkydots.modules.LogHelper
import com.sparkydots.website.main.views
import play.api.mvc.{Controller, _}
import play.api.i18n.{I18nSupport, MessagesApi}

class Utils @Inject()(val messagesApi: MessagesApi, val myComponent: LogHelper) extends Controller with I18nSupport {

  def health = Action {
    Ok(views.html.health())
  }

  def machine = Action {
    Ok(myComponent.getMachineInfo)
  }

  def myip = Action { request =>
    val ip = request.headers.get("x-forwarded-for").getOrElse("null")
    Ok(ip)
  }

}
