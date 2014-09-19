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


//  def logAndCheck(typ: String, pageName: String, id: String, did: String, request: RequestHeader) = {
//
//    val ip = request.remoteAddress
//    val authorization = request.headers.get(AUTHORIZATION).getOrElse("*")
//
//    val ua = userAgentLogString(request)
//
//    val geoip = s"http://freegeoip.net/json/${ip}"
//    WS.url(geoip).get().map {
//      result =>
//        if (result.status == 200) {
//          val city = result.json \ "city"
//          val region_name = result.json \ "region_name"
//          val country_code = result.json \ "country_code"
//          val geo = s" ${city} ${region_name} ${country_code} "
//          starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}${geo}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
//        } else {
//          starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
//        }
//    }.recover {
//      case e: Exception =>
//        starLogger.info(s"${typ}${logSeparator}$ip${logSeparator}$logSeparator$did$logSeparator$check$logSeparator${pageName}${logSeparator}${id}$ua${logSeparator}$authorization$logSeparator$md5v")
//    }
//    check
//  }

}
