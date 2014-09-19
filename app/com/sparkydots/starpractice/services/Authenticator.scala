package com.sparkydots.starpractice.services

import java.security.MessageDigest

import play.api.Logger
import play.api.http.HeaderNames._
import play.api.libs.ws.WS
import play.api.mvc.{Action, EssentialAction, RequestHeader, Results}

import scala.concurrent.ExecutionContext

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 9:14 PM
 */
case class Authenticator(action: EssentialAction) extends EssentialAction with Results {
  val starLogger = Logger("star")
  val sep = " # "

  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def apply(rh: RequestHeader) = {
    implicit val executionContext: ExecutionContext = play.api.libs.concurrent.Execution.defaultContext
    val ip =  rh.remoteAddress
    val path = rh.path
    val ua = rh.headers.get("User-Agent").getOrElse("")
    val authorization = rh.headers.get(AUTHORIZATION).getOrElse("")

    authorization.split(":") match {
      case Array(secret, public, version) =>
        val check = md5check(public, secret)
        if (check) {
          starLogger.info(s"$ip$sep$path$sep$public$sep$version$sep$ua")
          action(rh)
        } else {
          starLogger.info(s"$ip${sep}${path}NO:$sep$public$sep$version$sep$ua")
          Action { request => Ok("{}")}(rh)
        }
      case _ =>
        starLogger.info(s"$ip$sep${path}NA${sep}NA$sep$ua")
        Action { request => Ok("{}")}(rh)
    }
  }


}
