package com.sparkydots.util.controllers

import javax.inject.Inject

import com.sparkydots.modules.{LogHelper, LatexService}
import com.sparkydots.util.views
import play.api.mvc.{Controller, _}
import play.api.i18n.{I18nSupport, MessagesApi}
import scala.concurrent.ExecutionContext.Implicits.global

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

  def latex = Action.async {
    val texDoc =

    raw"""
      |\documentclass{book}
      |
      |
      |\begin{document}
      |\chapter{Sample}
      |
      |Huyaks
      |
      |\end{document}
    """.
      stripMargin

//    latexService.convertLatexFile(texDoc)
    latexService.convertLatex(texDoc, "huya").map { uri => Ok(views.html.latex(uri)) }
  }
}
