package com.sparkydots.common.events

import org.joda.time.{DateTimeZone, DateTime}
import play.api.libs.json.Json
import play.api.mvc.RequestHeader

// Touch event
case class TouchEvent(app_name: String)

object TouchEvent {
  def event_type: String = "touch"
}

// App event
case class AppEvent(check: Boolean,
                    public_id: Option[String] = None,
                    app_group: Option[String] = None, app_name: Option[String] = None, app_version: Option[String] = None)

object AppEvent {
  def event_type: String = "app"
}

// EVENT
case class Event(
                  recv: String,
                  recv_millis: Long,
                  method: String,
                  uri: String,
                  domain: String,
                  query_string: String,
                  user_agent: Option[String],
                  remote_ip: String,
                  x_forwarded_for: Option[String],
                  referrer: Option[String],
                  event_type: String,
                  appEvent: Option[AppEvent],
                  touchEvent: Option[TouchEvent]
                // such unscalable way: each event separate, only to make it easier for Hive-like processing
                ) {

  implicit val touchEventFormat = Json.format[TouchEvent]
  implicit val appEventFormat = Json.format[AppEvent]
  implicit val eventFormat = Json.format[Event]

  def jsonString = Json.toJson(this).toString

}

object Event {

  def createEvent(rh: RequestHeader): Event = {

    val curtime = new DateTime(DateTimeZone.UTC)

    Event(
      curtime.toString,
      curtime.getMillis,
      rh.method,
      rh.uri,
      rh.domain,
      rh.rawQueryString,
      rh.headers.get("user-agent"),
      rh.remoteAddress,
      rh.headers.get("x-forwarded-for"),
      rh.headers.get("referer"),
      "access",
      None,
      None
    )

  }

  def createAccessEvent(rh: RequestHeader): Event = createEvent(rh)

  def createAppEvent(rh: RequestHeader, check: Boolean,
                     public_id: Option[String] = None,
                     app_group: Option[String] = None, app_name: Option[String] = None, app_version: Option[String] = None): Event =
    createEvent(rh).
      copy(event_type = AppEvent.event_type).
      copy(appEvent = Some(AppEvent(check: Boolean, public_id, app_group, app_name, app_version)))

  def createTouchEvent(rh: RequestHeader, app_name: String): Event =
    createEvent(rh).
      copy(event_type = TouchEvent.event_type).
      copy(touchEvent = Some(TouchEvent(app_name)))

}







