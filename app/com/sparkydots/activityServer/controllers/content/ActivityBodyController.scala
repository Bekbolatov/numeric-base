package com.sparkydots.activityServer.controllers.content

import java.io.File
import javax.inject.Inject

import com.sparkydots.common.util.WithCors
import com.sparkydots.activityServer.models.{Message, Activity}
import com.sparkydots.activityServer.services.Authenticator
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.mvc._

import scala.util.Try
import scala.concurrent.ExecutionContext.Implicits.global
import play.api.http.HttpEntity
import play.mvc.Http.MimeTypes
import akka.util.ByteString


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
class ActivityBodyController @Inject() (activitiesData: com.sparkydots.activityServer.ActivitiesData) extends Controller {

  import akka.util.ByteString

  private def getFileContent(pathName: String): ByteString = {
    val file = new File(pathName)
    val source = scala.io.Source.fromFile(file)
    val byteArray = source.map(_.toByte).toArray
    source.close()

    ByteString(byteArray)
  }

  private def getActivityContent(activity: Activity): ByteString = {
    val content = activitiesData.getData(activity.id, activity.version.toString)("body")
    ByteString(content.getBytes("UTF-8"))
  }

  def activityBody(id: String) = WithCors("GET")(
    Authenticator { profile =>
      Action { request =>
        Activity.load(id).map { activity =>
          Try {
//            val data = getFileContent("/var/lib/starpractice/activity/body/" + id)
            val data = getActivityContent(activity)
            Result(
              header = ResponseHeader(200),
              body = HttpEntity.Strict(data, Some(MimeTypes.TEXT))
            )
          } getOrElse Ok("{}")
        }.get
      }
    }
  )

}
