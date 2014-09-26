package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.controllers.admin.Channels._
import com.sparkydots.activityServer.forms.admin.EndUserProfileForm
import com.sparkydots.activityServer.models.{Channel, EndUserProfile}
import com.sparkydots.activityServer.models.responses.{EndUserProfileListResponse, ActivityListResponse}
import com.sparkydots.activityServer.views
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
object EndUserProfiles extends Controller {

  val form = EndUserProfileForm

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(EndUserProfileListResponse jsonContaining EndUserProfile.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Action { implicit request =>
    val profile = EndUserProfile.getOrCreate(id)
    if (profile.nonEmpty) {
      val boundForm = form.fill(profile.get)
      Ok(views.html.admin.endUserProfiles.edit(id, boundForm))
    } else {
      NotFound
    }
  }

  def update(id: String) = Action { implicit request =>
    EndUserProfile.getOrCreate(id).map { activity =>
      form.bindFromRequest.fold(
        formWithErrors => BadRequest(views.html.admin.endUserProfiles.edit(id, formWithErrors)),
        updatedProfile => {
          EndUserProfile.update(updatedProfile)
          Ok("ok")
        })
    }.getOrElse(NotFound)
  }

}