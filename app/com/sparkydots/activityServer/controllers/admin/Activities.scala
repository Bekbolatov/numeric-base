package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.forms.admin.ActivityForm
import com.sparkydots.activityServer.models.Activity
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
          Redirect(routes.Activities.list).flashing("success" -> "Activity successfully created!")
        } else {
          BadRequest(views.html.admin.activities.add(boundForm)(Flash(Map("failure" -> "Activity was not created because this id is already used (duplicate Id)"))))
        }
      })
  }

  def list = Action { implicit request =>
    Ok(views.html.admin.activities.list(Activity.list))
  }

  def edit(id: String) = Action {
    Activity.load(id).map { activity =>
      val boundForm = form.fill(activity)
      Ok(views.html.admin.activities.edit(id, boundForm))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Action { implicit request =>
    Activity.load(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.activities.edit(id, formWithErrors)),
        activityWithNewValues => {
          Activity.update(id, activityWithNewValues)
          Redirect(routes.Activities.list).flashing("success" -> "Activity successfully updated!")
        })
    }.getOrElse(NotFound)
  }

  def delete(id: String) = Action {
    Activity.delete(id)
    Redirect(routes.Activities.list).flashing("success" -> "Activity successfully deleted!")
  }

}