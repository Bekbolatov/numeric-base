package com.sparkydots.starpractice.controllers

import java.io.File

import com.sparkydots.common.util.WithCors
import com.sparkydots.starpractice.models.{Activity, ActivityListResponse, Message}
import com.sparkydots.starpractice.services.Authenticator
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.mvc._

import scala.concurrent.ExecutionContext.Implicits.global


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object ContentController extends Controller {
  def touch(page: String, id: String) = WithCors("GET") (Authenticator {
    profile =>
      Action { request =>
        Ok("{}")
      }
  })

  private def getFileContent(pathName: String) = {
    val file = new File(pathName)
    val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
    fileContent
  }

  def activityBody(id: String) = WithCors("GET") (Authenticator {
    profile =>
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
    profile =>
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

  /* change to db pull */
  def channelList() = WithCors("GET") (Authenticator {
    profile =>
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

}
