package com.sparkydots.activityServer.services

import java.security.MessageDigest

import com.sparkydots.activityServer.models.EndUserProfile
import play.api.Logger
import play.api.http.HeaderNames._
import play.api.libs.ws.WS
import play.api.mvc.{Action, EssentialAction, RequestHeader, Results}

import scala.concurrent.ExecutionContext

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 9:14 PM
 */
case class Authenticator(action: EndUserProfile => EssentialAction) extends EssentialAction with Results {
  val starLogger = Logger("star")
  val sep = " # "

  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def emptyEssentialAction(rh: RequestHeader) = Action { request => Ok("{}")}(rh)

  def apply(rh: RequestHeader) = {
    implicit val executionContext: ExecutionContext = play.api.libs.concurrent.Execution.defaultContext
    val ip =  rh.remoteAddress
    val XFor =  rh.headers.get("X-Forwarded-For").getOrElse(" ")
    val xfor =  rh.headers.get("x-forwarded-for").getOrElse(" ")
    val path = rh.path
    val ua = rh.headers.get("User-Agent").getOrElse("")
    val authorization = rh.headers.get(AUTHORIZATION).getOrElse("")
    val method = rh.method

    authorization.split(":") match {
      case Array(secret, public, appGroup, appName, version) =>
        val check = md5check(public, secret)
        if (check) {
          starLogger.info(s"$ip$XFor$xfor$sep$method$sep$path$sep$public$sep$appGroup$sep$appName$sep$version$sep$ua")
          val profile = EndUserProfile.getOrCreate(public)
          if (profile.nonEmpty) {
            action(profile.get)(rh)
          } else {
            emptyEssentialAction(rh)
          }
        } else {
          starLogger.info(s"$ip$XFor$xfor$sep$method${sep}${path}${sep}NO:$public$sep$appGroup$sep$appName$sep$version$sep$ua")
          emptyEssentialAction(rh)
        }
      case _ =>
        starLogger.info(s"$ip$XFor$xfor$sep$method$sep${path}${sep}NA${sep}NA${sep}NA${sep}NA$sep$ua")
        emptyEssentialAction(rh)
    }
  }


}
