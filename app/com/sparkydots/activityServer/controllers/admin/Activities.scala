package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.controllers.content.ChannelController._
import com.sparkydots.activityServer.forms.admin.ActivityForm
import com.sparkydots.activityServer.models.Activity
import com.sparkydots.activityServer.models.responses.ActivityListResponse
import com.sparkydots.activityServer.services.Authenticator
import com.sparkydots.activityServer.views
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Activities extends Controller {
  val form = ActivityForm

  def add = Action { implicit request =>
    Ok(views.html.admin.activities.add(form))
  }

  def save = Action { implicit request =>
    val boundForm = form.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(views.html.admin.activities.add(formWithErrors)),
      activity => {
        if (Activity.save(activity)) {
          Ok("ok")
        } else {
          BadRequest(views.html.admin.activities.add(boundForm)(Flash(Map("failure" -> "Activity was not created because this id is already used (duplicate Id)"))))
        }
      })
  }

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ActivityListResponse jsonContaining Activity.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def update(id: String) = Action { implicit request =>
    Activity.load(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.activities.edit(id, formWithErrors)),
        activityWithNewValues => {
          Activity.update(id, activityWithNewValues)
          Ok("ok")
        })
    }.getOrElse(NotFound)
  }

  def edit(id: String) = Action {
    Activity.load(id).map { activity =>
      val boundForm = form.fill(activity)
      Ok(views.html.admin.activities.edit(id, boundForm))
    }.getOrElse(NotFound)
  }

  def delete(id: String) = Authenticator {
    profile =>
      Action {
        Activity.delete(id)
        Ok("ok")
      }
  }

}