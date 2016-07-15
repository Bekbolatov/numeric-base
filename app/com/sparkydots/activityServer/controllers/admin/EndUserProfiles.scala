package com.sparkydots.activityServer.controllers.admin

import javax.inject.Inject

import com.sparkydots.activityServer.forms.admin.EndUserProfileForm
import com.sparkydots.activityServer.models.{EndUserProfile, Channel}
import com.sparkydots.activityServer.models.responses.{ActivityList, EndUserProfileList}
import com.sparkydots.activityServer.services.{AuthorisationChecker, Authenticator}
import com.sparkydots.activityServer.views
import play.api.mvc._
import play.api.i18n.{I18nSupport, MessagesApi}

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
class EndUserProfiles @Inject() (val messagesApi: MessagesApi) extends Controller with I18nSupport {

  val form = EndUserProfileForm

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(EndUserProfileList jsonContaining EndUserProfile.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>
        val profile = EndUserProfile.getOrCreate(id)
        if (profile.nonEmpty) {
          val boundForm = form.fill(profile.get)
          Ok(views.html.admin.endUserProfiles.edit(id, boundForm))
        } else {
          NotFound
        }
      }
    }
  }

  def update(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>
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
  }

}