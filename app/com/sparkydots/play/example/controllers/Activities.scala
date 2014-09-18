package com.sparkydots.play.example.controllers

import play.api.mvc._
import play.api.data._
import play.api.data.Forms._
import play.api.data.validation._
import anorm._
import com.sparkydots.play.example.models.Activity
import scala.collection.mutable.HashMap
import com.sparkydots.play.example.views
import com.sparkydots.play.example.forms.ActivityForm
/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object Activities extends Controller {
    val form = ActivityForm
//  val form = Form(
//    mapping(
//      "id" -> nonEmptyText,
//      "name" -> nonEmptyText,
//      "shortDescription" -> nonEmptyText,
//      "description" -> nonEmptyText,
//      "authorName" -> nonEmptyText,
//      "authorEmail" -> email,
//      "authorDate" -> date,
//      "version" -> number)
//      (Activity.apply)(Activity.unapply))

  def add = Action { implicit request =>
    Ok(views.html.activities.add(form))
  }

  def save = Action { implicit request =>
    val boundForm = form.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(views.html.activities.add(formWithErrors)),
      activity => {
        if (Activity.save(activity)) {
          Redirect(routes.Activities.list).flashing("success" -> "Activity successfully created!")
        } else {
          BadRequest(views.html.activities.add(boundForm)(Flash(Map("failure" -> "Activity was not created because this id is already used (duplicate Id)"))))
        }
      })
  }

  def list = Action { implicit request =>
    Ok(views.html.activities.list(Activity.list, Activity.listForChannel(0)))
  }

  def edit(id: String) = Action {
    Activity.load(id).map { activity =>
      val boundForm = form.fill(activity)
      Ok(views.html.activities.edit(id, boundForm))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Action { implicit request =>
    Activity.load(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.activities.edit(id, formWithErrors)),
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


  def addToChannel(id: String, chid: Int) = Action {
    Activity.addToChannel(id, chid)
    Redirect(routes.Activities.list).flashing("success" -> s"Activity ${id} successfully added to channel ${chid}!")
  }

  def removeFromChannel(id: String, chid: Int) = Action {
    Activity.removeFromChannel(id, chid)
    Redirect(routes.Activities.list).flashing("success" -> s"Activity ${id} successfully removed from channel ${chid}!")
  }

}