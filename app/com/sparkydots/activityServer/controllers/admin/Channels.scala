package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.forms.admin.ChannelForm
import com.sparkydots.activityServer.models.{Activity, Channel}
import com.sparkydots.activityServer.views
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Channels extends Controller {
  val form = ChannelForm

  def add = Action { implicit request =>
    Ok(views.html.admin.channels.add(form))
  }

  def save = Action { implicit request =>
    val boundForm = form.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(views.html.admin.channels.add(formWithErrors)),
      channel => {
        if (Channel.save(channel)) {
          Redirect(routes.Channels.list).flashing("success" -> "Channel successfully created!")
        } else {
          BadRequest(views.html.admin.channels.add(boundForm)(Flash(Map("failure" -> "Channel was not created because this id is already used (duplicate Id)"))))
        }
      })
  }

  def list = Action { implicit request =>
    Ok(views.html.admin.channels.list(Channel.list))
  }

  def edit(id: Int) = Action {
    Channel.load(id).map { channel =>
      val boundForm = form.fill(channel)
      Ok(views.html.admin.channels.details(channel, boundForm, Activity.listForChannel(channel.id), Activity.list))
    }.getOrElse(NotFound)
  }

  def update(id: Int) = Action { implicit request =>
    Channel.load(id).map { channel =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.channels.details(channel, formWithErrors, Activity.listForChannel(channel.id), Activity.list)),
        channelWithNewValues => {
          Channel.update(id, channelWithNewValues)
          Redirect(routes.Channels.list).flashing("success" -> "Channel successfully updated!")
        })
    }.getOrElse(NotFound)
  }

  def delete(id: Int) = Action {
    Channel.delete(id)
    Redirect(routes.Channels.list).flashing("success" -> "Channel successfully deleted!")
  }


  def addToChannel(id: String, chid: Int) = Action {
    Activity.addToChannel(id, chid)
    Redirect(routes.Channels.edit(chid)).flashing("success" -> s"Activity ${id} successfully added to channel ${chid}!")
  }

  def removeFromChannel(id: String, chid: Int) = Action {
    Activity.removeFromChannel(id, chid)
    Redirect(routes.Channels.edit(chid)).flashing("success" -> s"Activity ${id} successfully removed from channel ${chid}!")
  }


}