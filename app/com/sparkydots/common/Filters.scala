package com.sparkydots.common

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.{Future, ExecutionContext}
import play.api.Logger
import play.api.mvc._
import javax.inject.Inject

import play.api.http.DefaultHttpFilters
import akka.stream.Materializer
import com.sparkydots.common.events.Event

class LoggingFilter @Inject() (implicit val mat: Materializer, ec: ExecutionContext) extends Filter {

  def apply(nextFilter: RequestHeader => Future[Result])
           (requestHeader: RequestHeader): Future[Result] = {

    val startTime = System.currentTimeMillis

    nextFilter(requestHeader).map { result =>

      val endTime = System.currentTimeMillis
      val requestTime = endTime - startTime

      Logger.info(s"${requestHeader.method} ${requestHeader.uri} took ${requestTime}ms and returned ${result.header.status}")

      result.withHeaders("Request-Time" -> requestTime.toString)
    }
  }
}

class AccessLoggingFilter @Inject() (implicit val mat: Materializer, ec: ExecutionContext) extends Filter {

  Logger.info("AccessLoggingFilter object started")

  def apply(next: (RequestHeader) => Future[Result])(rh: RequestHeader): Future[Result] = {
    val resultFuture = next(rh)

    resultFuture foreach { result =>
      val event = Event.createAccessEvent(rh)
      if (rh.uri == "/health") {
        Logger("health") info event.jsonString
      } else {
        Logger("events") info event.jsonString
      }
    }

    resultFuture
  }
}

class HTTPSRedirectFilter @Inject() (implicit val mat: Materializer, ec: ExecutionContext) extends Filter {
  Logger.info("HTTPSRedirectFilter object started")

  def apply(next: (RequestHeader) => Future[Result])(rh: RequestHeader): Future[Result] = {
    rh.headers.get("x-forwarded-proto") match {
      case Some(header) =>
        if ("https" == header) {
          next(rh).map { result => result.withHeaders(("Strict-Transport-Security", "max-age=31536000")) }
        } else {
          Future.successful(Results.Redirect("https://" + rh.host + rh.uri, 301))
        }
      case None => next(rh)
    }
  }
}

class Filters @Inject() (httpRedirect: HTTPSRedirectFilter, accessLog: AccessLoggingFilter) extends DefaultHttpFilters(httpRedirect, accessLog) {
  println("Filters starting")
  Logger.info("Filters object started")
}
