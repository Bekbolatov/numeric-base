import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import play.api.Logger
import play.api.mvc._
import play.api._

object AccessLoggingFilter extends Filter {

  val accessLogger = Logger("access")

  def apply(next: (RequestHeader) => Future[Result])(rh: RequestHeader): Future[Result] = {
    val resultFuture = next(rh)

    resultFuture.foreach(result => {
      val msg =
        "" +
          s"method=${rh.method} uri=${rh.uri} " +
          s"remote-address=${rh.remoteAddress} " +
          s"domain=${rh.domain} " +
          s"query-string=${rh.rawQueryString} " +
          s"referer=${rh.headers.get("referer").getOrElse("N/A")} " +
          s"user-agent=[${rh.headers.get("user-agent").getOrElse("N/A")}]"

      accessLogger.info(msg)
    })

    resultFuture
  }
}

object HTTPSRedirectFilter extends Filter {

  def apply(next: (RequestHeader) => Future[Result])(rh: RequestHeader): Future[Result] = {
    rh.headers.get("x-forwarded-proto") match {
      case Some(header) => {
        if ("https" == header) {
          next(rh).map { result => result.withHeaders(("Strict-Transport-Security", "max-age=31536000")) }
        } else {
          Future.successful(Results.Redirect("https://" + rh.host + rh.uri, 301))
        }
      }
      case None => next(rh)
    }
  }
}

object Global extends WithFilters(HTTPSRedirectFilter, AccessLoggingFilter) {

  override def onStart(app: Application) {
    Logger.info("Application [Krista] has started")
  }

  override def onStop(app: Application) {
    Logger.info("Application [Krista] has stopped")
  }
}
