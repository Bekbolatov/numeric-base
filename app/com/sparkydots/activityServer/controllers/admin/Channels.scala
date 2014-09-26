package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.controllers.admin.Activities._
import com.sparkydots.activityServer.forms.admin.ChannelForm
import com.sparkydots.activityServer.models.responses.{ChannelList, ActivityList}
import com.sparkydots.activityServer.models.{Activity, Channel}
import com.sparkydots.activityServer.services.Authenticator
import com.sparkydots.activityServer.views
import play.api.libs.json.Json
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Channels extends Controller {
  val form = ChannelForm

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ChannelList jsonContaining Channel.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def activityChannels(activityId: String, startIndex: Option[Int], size: Option[Int])  = Action { implicit request =>
    Ok(ChannelList jsonContaining Channel.pageOfActivity(activityId, startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Action {
    Channel.load(id).map { channel =>
      Ok(Json.toJson(channel))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Action { implicit request =>
    Channel.load(id).map { channel =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(formWithErrors.errorsAsJson),
        channelWithNewValues => {
          Channel.update(id, channelWithNewValues)
          Ok("ok")
        })
    }.getOrElse(NotFound)
  }

  def delete(id: String) = Authenticator {
    profile =>
      Action {
        Channel.delete(id)
        Ok("ok")
      }
  }

  def save = Action { implicit request =>
    val boundForm = form.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(formWithErrors.errorsAsJson),
      channel => {
        if (Channel.save(channel)) {
          Ok("ok")
        } else {
          BadRequest("{ \"dbError\" : \"error\" }")
        }
      })
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