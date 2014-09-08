package com.sparkydots.play.example.controllers

import com.sparkydots.play.example.views
import play.api.Logger
import play.api.mvc.{Action, Controller}
import play.api.http.HeaderNames._

import play.api.mvc._
import scala.concurrent._
import play.api.http.HeaderNames._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object StarPractice extends Controller {

  val logger = Logger("star")


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
                ACCESS_CONTROL_ALLOW_HEADERS ->  s"$ORIGIN, X-Requested-With, $CONTENT_TYPE, $ACCEPT, $AUTHORIZATION, X-Auth-Token",
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


  def activityBody(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        val file = new java.io.File("public/tasks/remote/server/activity/body/" + id)
        Ok.sendFile(
          content = file
        )
      } catch {
        case e: Exception => Ok("nothing")
      }
    }
  }

  def activityMeta(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        val file = new java.io.File("public/tasks/remote/server/activity/meta/" + id)
        Ok.sendFile(
          content = file
        )
      } catch {
        case e: Exception => Ok("nothing")
      }
    }
  }

  def activityList(did: String) = WithCors("GET") {
    Action { request =>
      try {
        logger.info("as")
        val authorization = request.headers.get(AUTHORIZATION).getOrElse("*")
        logger.info(s"calling did: ${did} with auth: ${authorization}")
        val file = new java.io.File("public/tasks/remote/server/activity/meta/list")
        Ok.sendFile(
          content = file
        )
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def hello(did: String) = WithCors("GET") {
    Action { request =>
      Ok("{}")
    }
  }
  def index = Action {
      Ok(views.html.starpractice())
  }

}
