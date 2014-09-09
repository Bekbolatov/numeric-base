package com.sparkydots.play.example.controllers

import scala.concurrent.ExecutionContext.Implicits.global
import com.sparkydots.play.example.views
import play.api.Logger
import play.api.mvc._
import java.io.File
import scala.concurrent._
import play.api.libs.iteratee.Enumerator
import java.security.MessageDigest

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object StarPractice extends Controller {

  val starLogger = Logger("star")
  val logSeparator = "#"

  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def logAndCheck(page: String, did: String, request: RequestHeader) = {

    val ip = request.remoteAddress
    val authorization = request.headers.get(AUTHORIZATION).getOrElse("*")
    val md5v = md5(authorization)
    val check = md5check(did, authorization)

    starLogger.info(s"S$logSeparator$ip$logSeparator$did$logSeparator$check$logSeparator$page$logSeparator$authorization$logSeparator$md5v")
    check
  }

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
    fileContent
  }


  def activityBody(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (!logAndCheck(s"body$logSeparator${id}", did, request)) {
          Ok("{}")
        } else {
          val fileContent = getFileContent("public/tasks/remote/server/activity/body/" + id)
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def activityMeta(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (!logAndCheck(s"meta$logSeparator${id}", did, request) ) {
          Ok("{}")
        } else {
          val fileContent = getFileContent("public/tasks/remote/server/activity/meta/" + id)
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def activityList(did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (!logAndCheck(s"list$logSeparator", did, request)) {
          Ok("{}")
        } else {
          val fileContent = getFileContent("public/tasks/remote/server/activity/meta/list")
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def hello(did: String) = WithCors("GET") {
    Action { request =>
      logAndCheck(s"hello$logSeparator", did, request)
      Ok("{}")
    }
  }

  def index() = Action {
    Ok(views.html.starpractice())
  }

}
