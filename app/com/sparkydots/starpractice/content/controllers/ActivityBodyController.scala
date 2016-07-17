package com.sparkydots.starpractice.content.controllers

import java.io.File
import javax.inject.Inject

import com.sparkydots.starpractice.common.models._
import com.sparkydots.starpractice.common.services.Authenticator
import play.api.mvc._
import play.api.http.HttpEntity
import play.mvc.Http.MimeTypes
import com.sparkydots.starpractice.common.services.{WithCors, ActivitiesData}
import akka.util.ByteString

import scala.util.{Success, Failure, Try}

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
class ActivityBodyController @Inject() (activitiesData: ActivitiesData) extends Controller {


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
          } match {
            case Success(result) => result
            case Failure(ex) => Ok(s"""{"msg": "Problem: ${ex.getMessage}"}""") // println(s"Problem rendering URL content: ${ex.getMessage}")
          }
//          getOrElse Ok("{}")
        }.get
      }
    }
  )

}
