package com.sparkydots.play.example.controllers

import scala.concurrent.ExecutionContext.Implicits.global
import com.sparkydots.play.example.views
import play.api.Logger
import play.api.mvc._
import java.io.File
import scala.concurrent._
import play.api.libs.iteratee.Enumerator

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object StarPractice extends Controller {

  val starLogger = Logger("star")


  case class WithCors(httpVerbs: String*)(action: EssentialAction) extends EssentialAction with Results {
    def apply(request: RequestHeader) = {
      implicit val executionContext: ExecutionContext = play.api.libs.concurrent.Execution.defaultContext
      val origin = request.headers.get(ORIGIN).getOrElse("*")
      if (request.method == "OPTIONS") {
        val corsAction = Action {
          request =>
            Ok("").withHeaders(
              ACCESS_CONTROL_ALLOW_ORIGIN -> origin,
              ACCESS_CONTROL_ALLOW_METHODS -> (httpVerbs.toSet + "OPTIONS").mkString(", "),
              ACCESS_CONTROL_MAX_AGE -> "3600",
              ACCESS_CONTROL_ALLOW_HEADERS -> s"$ORIGIN, X-Requested-With, $CONTENT_TYPE, $ACCEPT, $AUTHORIZATION, X-Auth-Token",
              ACCESS_CONTROL_ALLOW_CREDENTIALS -> "true")
        }
        corsAction(request)
      } else {
        action(request).map(response =>
          response.withHeaders(
            ACCESS_CONTROL_ALLOW_ORIGIN -> origin,
            ACCESS_CONTROL_ALLOW_CREDENTIALS -> "true"
          )
        )
      }
    }
  }


  def getFileContent(pathName: String) = {
    val file = new File(pathName)
    val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
    starLogger.info(s"in file: ${pathName}")
    fileContent
  }

  def activityBody(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        val fileContent = getFileContent("public/tasks/remote/server/activity/body/" + id)
        Result(
          header = ResponseHeader(200),
          body = fileContent
        )
      } catch {
        case e: Exception => Ok("nothing")
      }
    }
  }

  def activityMeta(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        val fileContent = getFileContent("public/tasks/remote/server/activity/meta/" + id)
        Result(
          header = ResponseHeader(200),
          body = fileContent
        )
      } catch {
        case e: Exception => Ok("nothing")
      }
    }
  }

  def activityList(did: String) = WithCors("GET") {
    Action { request =>
      starLogger.info("ass")
      try {
        starLogger.info("as")
        Logger.info("hello")
        val authorization = request.headers.get(AUTHORIZATION).getOrElse("*")
        starLogger.info(s"calling did: ${did} with auth: ${authorization}")
        val fileContent = getFileContent("public/tasks/remote/server/activity/meta/list")
        Result(
          header = ResponseHeader(200),
          body = fileContent
        )
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def hello(did: String) = WithCors("GET") {
    Action { request =>
      starLogger.info("hello2")
      Ok("{}")
    }
  }

  def index = Action {
    starLogger.info("index")
    Ok(views.html.starpractice())
  }

}
