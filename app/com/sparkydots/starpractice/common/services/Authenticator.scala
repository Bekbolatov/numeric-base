package com.sparkydots.starpractice.common.services

import java.security.MessageDigest

import com.sparkydots.common.events.Event
import com.sparkydots.starpractice.common.models._
import play.api.Logger
import play.api.http.HeaderNames._
import play.api.libs.ws.WS
import play.api.mvc.{Results, RequestHeader, EssentialAction, Action}

import scala.concurrent.ExecutionContext

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 9:14 PM
 */
case class Authenticator(action: EndUserProfile => EssentialAction) extends EssentialAction with Results {
  val eventLogger = Logger("events")
  val sep = " # "

  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def emptyEssentialAction(rh: RequestHeader) = Action { request => Ok("{}")}(rh)

  def apply(rh: RequestHeader) = {
    implicit val executionContext: ExecutionContext = play.api.libs.concurrent.Execution.defaultContext
    val ip =  rh.remoteAddress
    val xfor =  rh.headers.get("x-forwarded-for").getOrElse("")
    val path = rh.path
    val ua = rh.headers.get("User-Agent").getOrElse("")
    val authorization = rh.headers.get(AUTHORIZATION).getOrElse("")
    val method = rh.method

    authorization.split(":") match {
      case Array(secret, public, appGroup, appName, version) =>
        val check = md5check(public, secret)
          val event = Event.createAppEvent(rh, check, Some(public), Some(appGroup), Some(appName), Some(version))
          eventLogger info event.jsonString
        if (check) {
          val profile = EndUserProfile.getOrCreate(public)
          if (profile.nonEmpty) {
            if (rh.uri.startsWith("/activityServer/data/touch")) {
              eventLogger info Event.createTouchEvent(rh, appName).jsonString
            }
            action(profile.get)(rh)
          } else {
            emptyEssentialAction(rh)
          }
        } else {
          emptyEssentialAction(rh)
        }
      case _ =>
        val event = Event.createAppEvent(rh, false)
        eventLogger info event.jsonString
        emptyEssentialAction(rh)
    }
  }


}
