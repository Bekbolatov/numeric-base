package com.sparkydots.activityServer.controllers.admin

import com.sparkydots.activityServer.forms.admin.ActivityForm
import com.sparkydots.activityServer.models.{Permission, Activity}
import com.sparkydots.activityServer.models.responses.ActivityList
import com.sparkydots.activityServer.services.{AuthorisationChecker, Authenticator}
import com.sparkydots.activityServer.views
import play.api.mvc._
//import play.libs.Json
import javax.inject.Inject

import play.api.libs.json.Json
import play.api.Play.current
import play.api.i18n.Messages.Implicits._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
class Activities @Inject() (activitiesData: com.sparkydots.activityServer.ActivitiesData) extends Controller {
  val form = ActivityForm

  def list(startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ActivityList jsonContaining Activity.page(startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def channelActivities(channelId: String, startIndex: Option[Int], size: Option[Int]) = Action { implicit request =>
    Ok(ActivityList jsonContaining Activity.pageOfChannel(channelId, startIndex.getOrElse(0), size.getOrElse(100)))
  }

  def edit(id: String) = Action {
    Activity.load(id).map { activity =>
      Ok(Json.toJson(activity))
    }.getOrElse(NotFound)
  }

  def update(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>
        Activity.load(id).map { activity =>
          form.bindFromRequest.fold(
            formWithErrors => BadRequest(formWithErrors.errorsAsJson),
            activityWithNewValues => {
              Activity.update(id, activityWithNewValues)
              Ok("ok")
            })
        }.getOrElse(NotFound)
      }
    }
  }

  def updateContent(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>
        Activity.load(id).map { activity =>
          form.bindFromRequest.fold(
            formWithErrors => BadRequest(formWithErrors.errorsAsJson),
            activityWithNewValues => {
              val content = activityWithNewValues.content
              if (content.length > 30) {
                val version = activityWithNewValues.version.toString
                activitiesData.putActivityBody(id, version, content)
                Ok("ok")
              } else {
                Ok("too short")
              }
            })
        }.getOrElse(NotFound)
      }
    }
  }

  def delete(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action {
        Activity.delete(id)
        Ok("ok")
      }
    }
  }

  def save = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>

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
  }
}