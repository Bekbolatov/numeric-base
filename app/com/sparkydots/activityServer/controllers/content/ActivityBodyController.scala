package com.sparkydots.activityServer.controllers.content

import java.io.File

import com.sparkydots.common.util.WithCors
import com.sparkydots.activityServer.models.{Activity, Message}
import com.sparkydots.activityServer.services.Authenticator
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.mvc._
import scala.util.Try

import scala.concurrent.ExecutionContext.Implicits.global


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
class ActivityBodyController extends Controller {

  import akka.util.ByteString

  private def getFileContent(pathName: String): ByteString = {
    import akka.util.ByteString
    val file = new File(pathName)
    val source = scala.io.Source.fromFile(file)
    val byteArray = source.map(_.toByte).toArray
    source.close()

    ByteString(byteArray)
  }

  def activityBody(id: String) = WithCors("GET")(
    Authenticator { profile =>
      Action { request =>
        Try {
          import play.api.http.HttpEntity
          import play.mvc.Http.MimeTypes
          val fileContent = getFileContent("/var/lib/starpractice/activity/body/" + id)
          Result(
            header = ResponseHeader(200),
            body = HttpEntity.Strict(fileContent, Some(MimeTypes.TEXT))
          )
        } getOrElse Ok("{}")
      }
    }
  )

}
