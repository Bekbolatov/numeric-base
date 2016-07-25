package com.sparkydots.util.controllers

import javax.inject.Inject

import akka.util.ByteString
import com.sparkydots.services._
import com.sparkydots.util.views
import play.api.http.HttpEntity
import play.api.mvc.{Controller, _}
import play.api.i18n.{I18nSupport, MessagesApi}

import scala.concurrent.{Future, ExecutionContext}
import com.sparkydots.service.content._
import com.sparkydots.service.latex._

class Utils @Inject() (
                        val messagesApi: MessagesApi,
                        myComponent: LogHelper,
                        latexService: LatexService,
                        contentService: ContentService
                     )(implicit exec: ExecutionContext)
  extends Controller with I18nSupport {

  def simplelog(msg: => String): Unit = println(msg)

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
      latexService.convertLatexFile(texDoc, timeoutMillis=5000, log = Some(simplelog)).map { case (success, result) =>
        result.withHeaders("Content-Disposition" -> "attachment; filename=\"attachment.pdf\"")
      }

    }
  }

  def generatePracticeSet = Action.async {
    val spec = PracticeSetSpecification(
      "REN Example Practice Set",
      "Subtitle of the test",
      "Description here ",
      Seq(
        PracticeQuestionCount(
          PracticeQuestion(
            "com.sp.qw.qw.question",
            "1",
            1),
          2),
        PracticeQuestionCount(
          PracticeQuestion(
            "com.sp.qw.qw.question",
            "1",
            2),
          3)
      ),
      None
    )
    println(spec)

    contentService.generatePracticeSet(spec, timeoutMillis=5000, log = Some(simplelog)).map {
      result =>
        result.withHeaders("Content-Disposition" -> "attachment; filename=\"attachment.pdf\"")
    }

  }

}

