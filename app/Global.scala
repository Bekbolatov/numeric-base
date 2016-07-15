import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.{Future, ExecutionContext}
import play.api.Logger
import play.api.mvc._
import play.api._
import javax.inject.Inject
import play.api.http.DefaultHttpFilters
import akka.stream.Materializer


import scala.concurrent.Future
import javax.inject._
import play.api.inject.ApplicationLifecycle

@Singleton
class ExampleOnStop @Inject() (lifecycle: ApplicationLifecycle) {
//  val connection = connectToMessageQueue()
  lifecycle.addStopHook { () =>
//    Future.successful(connection.stop())
    Logger.info("Application [Krista] has stopped")
    Future.successful()
  }
}

//object Global {
//
//  override def onStart(app: Application) {
//    Logger.info("Global has started")
//  }
//
//  override def onStop(app: Application) {
//    Logger.info("Global has stopped")
//  }
//}

