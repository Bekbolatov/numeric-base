package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.controllers.admin.Activities._
import com.sparkydots.activityServer.forms.admin.ChannelForm
import com.sparkydots.activityServer.models.responses.{ChannelListResponse, ActivityListResponse}
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
          Ok("ok")
        } else {
          BadRequest(views.html.admin.channels.add(boundForm)(Flash(Map("failure" -> "Channel was not created because this id is already used (duplicate Id)"))))
        }
      })
  }

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ChannelListResponse jsonContaining Channel.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Action {
    Channel.load(id).map { channel =>
      val boundForm = form.fill(channel)
      Ok(views.html.admin.channels.details(channel, boundForm, Activity.listForChannel(channel.id), Activity.list))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Action { implicit request =>
    Channel.load(id).map { channel =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.channels.details(channel, formWithErrors, Activity.listForChannel(channel.id), Activity.list)),
        channelWithNewValues => {
          Channel.update(id, channelWithNewValues)
          Ok("ok")
        })
    }.getOrElse(NotFound)
  }

  def delete(id: String) = Action {
    Channel.delete(id)
    Ok("ok")
  }


  def addActivityToChannel(activityId: String, channelId: String) = Action {
    Activity.addToChannel(activityId, channelId)
    Ok("ok")
  }

  def removeActivityFromChannel(activityId: String, channelId: String) = Action {
    Activity.removeFromChannel(activityId, channelId)
    Ok("ok")
  }


}