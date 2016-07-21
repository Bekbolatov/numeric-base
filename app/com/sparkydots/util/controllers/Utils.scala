package com.sparkydots.util.controllers

import javax.inject.Inject

import akka.util.ByteString
import com.sparkydots.modules.{LogHelper, LatexService}
import com.sparkydots.util.views
import play.api.http.HttpEntity
import play.api.mvc.{Controller, _}
import play.api.i18n.{I18nSupport, MessagesApi}

import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.Future

class Utils @Inject()(
                       val messagesApi: MessagesApi,
                       val myComponent: LogHelper,
                       val latexService: LatexService
                     )
  extends Controller with I18nSupport {

  def health = Action {
    Ok(views.html.health())
  }

  def machine = Action {
    Ok(myComponent.getMachineInfo)
  }

  def myip = Action { request =>
    val ip = request.headers.get("x-forwarded-for").getOrElse("null")
    Ok(ip)
  }

  def latex = Action {
    Ok(views.html.latex())
  }

  def createLatex = Action.async { request =>

    val texDoc = request.body.asRaw.get.asBytes().get.utf8String
    if (texDoc.size > 50000) {
      Future.successful(Result(
        header = ResponseHeader(200),
        HttpEntity.Strict(ByteString("We can only allow documents less that 50K chars.".getBytes("UTF-8")), Some("plain/text"))
      ))
    } else {
      latexService.convertLatexFile(texDoc).map { case (success, result) =>
        result
      }

    }
  }

  def makeq1() = Action.async {
    val content = com.sparkydots.util.views.txt.q1(3, 4)
    val body = content.body
    println(body)
    latexService.convertLatexFile(body).map { case (success, result) =>
      result
    }
  }


}

