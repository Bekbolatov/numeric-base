package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.forms.admin.EndUserProfileForm
import com.sparkydots.activityServer.models.EndUserProfile
import com.sparkydots.activityServer.views
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object EndUserProfiles extends Controller {

  val form = EndUserProfileForm

  def list = Action { implicit request =>
    Ok(views.html.admin.endUserProfiles.list(EndUserProfile.list))
  }

  def edit(id: String) = Action { implicit request =>
    val profile = EndUserProfile.getOrCreate(id)
    if (profile.nonEmpty) {
      val boundForm = form.fill(profile.get)
      Ok(views.html.admin.endUserProfiles.edit(id, boundForm))
    } else {
      Ok(views.html.admin.endUserProfiles.list(EndUserProfile.list))
    }
  }

  def update(id: String) = Action { implicit request =>
    EndUserProfile.getOrCreate(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.endUserProfiles.edit(id, formWithErrors)),
        updatedProfile => {
          EndUserProfile.update(updatedProfile)
          Redirect(routes.EndUserProfiles.list).flashing("success" -> "Profile successfully updated!")
        })
    }.getOrElse(NotFound)
  }

  def addToEndUser(userId: String, chid: Int) = Action {
    EndUserProfile.addChannel(userId, chid)
    Ok("added")
  }

  def removeFromEndUser(userId: String, chid: Int) = Action {
    EndUserProfile.removeChannel(userId, chid)
    Ok("removed")
  }


}