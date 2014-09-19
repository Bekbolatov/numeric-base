package com.sparkydots.starpractice.controllers

import java.io.File
import java.security.MessageDigest

import com.sparkydots.common.util.WithCors
import com.sparkydots.starpractice.services.{StarLogger, InputValidator, Authenticator}
import com.sparkydots.starpractice.views
import com.sparkydots.starpractice.models.{Activity, ActivityListResponse, Message}
import play.api.Logger
import play.api.Play.current
import play.api.http.HeaderNames._
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.libs.ws.WS
import play.api.mvc._


import scala.concurrent.ExecutionContext.Implicits.global


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object StarPractice extends Controller {

  def getFileContent(pathName: String) = {
    val file = new File(pathName)
    val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
    fileContent
  }

  def activityBody(id: String) = WithCors("GET") (Authenticator {
    Action { request =>
      try {
          val fileContent = getFileContent("/var/lib/starpractice/activity/body/" + id)
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  })

  def activityList(chid: Int, st: Int, si: Int) = WithCors("GET") (Authenticator {
    Action { request =>
      try {
          var ssi = si
          if (si > 100) {
            ssi = 100
          }

          val activities = Activity.pageOfChannel(chid, st, ssi)
          val messages: List[Message] = List()
          val activitiesResponse = ActivityListResponse(messages, activities)
          Ok(Json.toJson(activitiesResponse))

      } catch {
        case e: Exception => Ok("{}")
      }
    }
  })

  def channelList() = WithCors("GET") (Authenticator {
    Action { request =>
      try {
          val fileContent = getFileContent("public/tasks/remote/server/channels")
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  })

  def touch(page: String, id: String) = WithCors("GET") (Authenticator {
    Action { request =>
      Ok("{}")
    }
  })

  def index() = Action {
    Ok(views.html.starpractice())
  }

}
