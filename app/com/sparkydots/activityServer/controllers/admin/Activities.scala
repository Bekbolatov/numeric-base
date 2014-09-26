package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.forms.admin.ActivityForm
import com.sparkydots.activityServer.models.Activity
import com.sparkydots.activityServer.models.responses.ActivityList
import com.sparkydots.activityServer.services.Authenticator
import com.sparkydots.activityServer.views
import play.api.mvc._
//import play.libs.Json
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Activities extends Controller {
  val form = ActivityForm

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ActivityList jsonContaining Activity.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def channelActivities(channelId: String, startIndex: Option[Int], size: Option[Int])  = Action { implicit request =>
    Ok(ActivityList jsonContaining Activity.pageOfChannel(channelId, startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Action {
    Activity.load(id).map { activity =>
      Ok(Json.toJson(activity))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Action { implicit request =>
    Activity.load(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(formWithErrors.errorsAsJson),
        activityWithNewValues => {
          Activity.update(id, activityWithNewValues)
          Ok("ok")
        })
    }.getOrElse(NotFound)
  }

  def delete(id: String) = Authenticator {
    profile =>
      Action {
        Activity.delete(id)
        Ok("ok")
      }
  }

  def save = Action { implicit request =>
    val boundForm = form.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(formWithErrors.errorsAsJson),
      activity => {
        if (Activity.save(activity)) {
          Ok("ok")
        } else {
          BadRequest("{ \"dbError\" : \"error\" }")
        }
      })
  }
}