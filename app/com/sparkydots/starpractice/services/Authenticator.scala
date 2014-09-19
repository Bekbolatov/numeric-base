package com.sparkydots.starpractice.services

import java.security.MessageDigest
import play.api.mvc.{RequestHeader, Results, EssentialAction, Action}


import play.api.http.HeaderNames._

import scala.concurrent.ExecutionContext

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 9:14 PM
 */
case class Authenticator(action: EssentialAction) extends EssentialAction with Results {
  val digest = MessageDigest.getInstance("MD5")
  def md5(s: String) = digest.digest(s.getBytes).map("%02x".format(_)).mkString
  def md5check(hash: String, orig: String) =
    hash != null && !hash.isEmpty() && orig != null && !orig.isEmpty() && md5(orig) == hash

  def apply(rh: RequestHeader) = {
    implicit val executionContext: ExecutionContext = play.api.libs.concurrent.Execution.defaultContext
    val authorization = rh.headers.get(AUTHORIZATION).getOrElse("")
    authorization.split(":") match {
      case Array(secret, public, version) =>
        val check = md5check(public, secret)
        if (check) {
          action(rh)
        } else {
          Action { request => Ok("{}") } (rh)
        }
      case _ => Action { request => Ok("{}") } (rh)
    }
  }
}
