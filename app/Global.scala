import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future
import play.api.Logger
import play.api.mvc._
import play.api._

object AccessLoggingFilter extends Filter {

  val accessLogger = Logger("access")

  def apply(next: (RequestHeader) => Future[Result])(request: RequestHeader): Future[Result] = {
    val resultFuture = next(request)

    resultFuture.foreach(result => {
      //val msg = s"method=${request.method} uri=${request.uri} remote-address=${request.remoteAddress}" +
      //  s" status=${result.header.status}";


      val msg = s"method=${request.method} uri=${request.uri} remote-address=${request.remoteAddress} " +
        s"domain=${request.domain} query-string=${request.rawQueryString} " +
        s"referer=${request.headers.get("referer").getOrElse("N/A")} " +
        s"user-agent=[${request.headers.get("user-agent").getOrElse("N/A")}]"

      accessLogger.info(msg)
    })

    resultFuture
  }
}

object Global extends WithFilters(AccessLoggingFilter) {

  override def onStart(app: Application) {
    Logger.info("Application [Krista] has started")
  }

  override def onStop(app: Application) {
    Logger.info("Application [Krista] has stopped")
  }
}
