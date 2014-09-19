package com.sparkydots.starpractice.services

import java.security.MessageDigest

import play.api.Logger
import play.api.http.HeaderNames._
import play.api.libs.ws.WS
import play.api.mvc.RequestHeader
import play.api.Play.current

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 7:56 PM
 */
object StarLogger {

  val uaMobilePattern = "(iPhone|webOS|iPod|Android|BlackBerry|mobile|SAMSUNG|IEMobile|OperaMobi)".r.unanchored

  def isMobile(ua: String) =
    ua match {
      case uaMobilePattern(a) => true
      case _ => false
    }





}
