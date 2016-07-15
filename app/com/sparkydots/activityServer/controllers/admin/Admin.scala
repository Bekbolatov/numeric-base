package com.sparkydots.activityServer.controllers.admin

import javax.inject.Inject

import com.sparkydots.activityServer.views
import play.api.mvc._
import play.api.i18n.{I18nSupport, MessagesApi}
/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
class Admin @Inject() (val messagesApi: MessagesApi) extends Controller with I18nSupport {
  def index =
    Action { implicit request =>
      Ok(views.html.admin.index())
    }
}

