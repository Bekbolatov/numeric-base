package com.sparkydots.play.example.controllers

import java.io.File
import java.security.MessageDigest

import com.sparkydots.play.example.converters.JsonFormats._
import com.sparkydots.play.example.models._
import com.sparkydots.play.example.views
import play.api.Logger
import play.api.Play.current
import play.api.http.HeaderNames._
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.libs.ws.WS
import play.api.mvc._

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent._


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */

object StarLogger {
  val starLogger = Logger("star")

  val logSeparator = "# "

  val uaMobilePattern = "(iPhone|webOS|iPod|Android|BlackBerry|mobile|SAMSUNG|IEMobile|OperaMobi)".r.unanchored

  def isMobile(ua: String) =
    ua match {
      case uaMobilePattern(a) => true
      case _ => false
    }

  def userAgentLogString(request: RequestHeader) = {
    val ua = request.headers.get("User-Agent")
    val uaString = ua.getOrElse("")
    s"${logSeparator}${uaString}"
  }


  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def logAndCheck(typ: String, pageName: String, id: String, did: String, request: RequestHeader) = {

    val ip = request.remoteAddress
    val authorization = request.headers.get(AUTHORIZATION).getOrElse("*")
    val md5v = md5(authorization)
    val check = md5check(did, authorization)

    val ua = userAgentLogString(request)

    val geoip = s"http://freegeoip.net/json/${ip}"
    WS.url(geoip).get().map {
      result =>
        if (result.status == 200) {
          val city = result.json \ "city"
          val region_name = result.json \ "region_name"
          val country_code = result.json \ "country_code"
          val geo = s" ${city} ${region_name} ${country_code} "
          starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}${geo}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
        } else {
          starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
        }
    }.recover {
      case e: Exception =>
        starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
    }
    check
  }

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

object StarPractice extends Controller {
  val allowedChars=(('a' to 'z') ++ ('A' to 'Z') ++ ('0' to '9') ++ List('.', '_')).toSet
  def validateStringInput(id: String)= {
    id.length < 100 && id.forall(allowedChars.contains(_))
  }


  def getFileContent(pathName: String) = {
    val file = new File(pathName)
    val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
    fileContent
  }

  def activityBody(id: String, did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (validateStringInput(id) && validateStringInput(did) && StarLogger.logAndCheck("S", "body", id, did, request)) {
          val fileContent = getFileContent("public/tasks/remote/server/activity/body/" + id)
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        } else {
          Ok("{}")
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def activityList(chid: Int, st: Int, si: Int, did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (validateStringInput(did) && StarLogger.logAndCheck("S","list","", did, request)) {

          var ssi = si
          if (si > 100) {
            ssi = 100
          }

          val activities = Activity.page(st, ssi)
          val messages: List[Message] = List()
          val activitiesResponse = ActivityListResponse(messages, activities)
          Ok(Json.toJson(activitiesResponse))


        } else {
          Ok("{}")
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def channelList(did: String) = WithCors("GET") {
    Action { request =>
      try {
        if (validateStringInput(did) && StarLogger.logAndCheck("S","channels","", did, request)) {
          val fileContent = getFileContent("public/tasks/remote/server/channels")
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        } else {
          Ok("{}")
        }
      } catch {
        case e: Exception => Ok("{}")
      }
    }
  }

  def touch(page: String, id: Option[String], did: String) = WithCors("GET") {
    Action { request =>
      val idString = id.getOrElse("")
      if (validateStringInput(page) && (id.isEmpty || validateStringInput(idString)) && validateStringInput(did)) {
        StarLogger.logAndCheck("T", page, idString, did, request)
      }
      Ok("{}")
    }
  }

  def index() = Action {
    Ok(views.html.starpractice())
  }

}
