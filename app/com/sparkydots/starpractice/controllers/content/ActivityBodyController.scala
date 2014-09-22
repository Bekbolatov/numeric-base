package com.sparkydots.starpractice.controllers.content

import java.io.File

import com.sparkydots.common.util.WithCors
import com.sparkydots.starpractice.models.{Activity, Message}
import com.sparkydots.starpractice.services.Authenticator
import play.api.libs.iteratee.Enumerator
import play.api.libs.json.Json
import play.api.mvc._

import scala.concurrent.ExecutionContext.Implicits.global


/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 8/4/14 9:22 PM
 */
object ActivityBodyController extends Controller {

  private def getFileContent(pathName: String) = {
    val file = new File(pathName)
    val fileContent: Enumerator[Array[Byte]] = Enumerator.fromFile(file)
    fileContent
  }

  def activityBody(id: String) = WithCors("GET") (Authenticator {
    profile =>
      Action { request =>
        try {
          val fileContent = getFileContent("/var/lib/starpractice/activity/body/" + id)
          Result(
            header = ResponseHeader(200),
            body = fileContent
          )
        } catch {
          case e: Exception => Ok("{}")
        }
      }
  })


}
