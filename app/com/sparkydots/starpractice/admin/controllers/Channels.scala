package com.sparkydots.starpractice.admin.controllers

import javax.inject.Inject

import com.sparkydots.starpractice.admin.forms.ChannelForm
import com.sparkydots.starpractice.common.models._
import com.sparkydots.starpractice.common.models.responses._
import com.sparkydots.starpractice.common.services.{AuthorisationChecker, Authenticator}
import play.api.i18n.{I18nSupport, MessagesApi}
import play.api.libs.json.Json
import play.api.mvc._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 7:08 PM
 */
class Channels @Inject() (val messagesApi: MessagesApi) extends Controller with I18nSupport {
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

  def update(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action { implicit request =>
        Channel.load(id).map { channel =>
          form.bindFromRequest.fold(
            formWithErrors => BadRequest(formWithErrors.errorsAsJson),
            channelWithNewValues => {
              Channel.update(id, channelWithNewValues)
              Ok("ok")
            })
        }.getOrElse(NotFound)
      }
    }
  }

  def delete(id: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action {
        Channel.delete(id)
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
          channel => {
            if (Channel.save(channel)) {
              Ok("ok")
            } else {
              BadRequest("{ \"dbError\" : \"error\" }")
            }
          })
      }
    }
  }



  def addActivityToChannel(activityId: String, channelId: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action {
        Activity.addToChannel(activityId, channelId)
        Ok("ok")
      }
    }
  }

  def removeActivityFromChannel(activityId: String, channelId: String) = Authenticator { profile =>
    AuthorisationChecker(profile).onlyRoot {
      Action {
        Activity.removeFromChannel(activityId, channelId)
        Ok("ok")
      }
    }
  }


}