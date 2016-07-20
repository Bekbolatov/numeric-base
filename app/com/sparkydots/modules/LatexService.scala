package com.sparkydots.modules

import javax.inject.Inject

import play.api.http.HttpEntity

import scala.concurrent.Future
import scala.concurrent.duration._
import play.api.libs.ws._
import play.api.mvc.{Result, ResponseHeader}

import scala.concurrent.ExecutionContext.Implicits.global
import akka.util.ByteString


trait LatexService {
  def convertLatex(tex: String): Future[String] //Array[Byte]
  def convertLatexFile(tex: String): Future[Result] //Array[Byte]
}


class LatexServiceImpl @Inject()(ws: WSClient) extends LatexService {
  override def convertLatex(tex: String): Future[String] = {
    //Array[Byte] = {


    val filename = "huyaks"
    val host = "52.42.48.92"
    val port = 6000
    val url = s"http://$host:$port/cgi-bin/latex2pdf.sh?$filename"

    val request: WSRequest = ws.url(url).
      withHeaders("Content-Type" -> "application/x-tex").
      withHeaders("Accept" -> "application/json").
      withRequestTimeout(10000.millis)
    // withQueryString("search" -> "play")

    val futureResponse: Future[WSResponse] = request.post(tex)

    val futureResult: Future[String] = futureResponse.map {
      response =>
        (response.json \ "uri").as[String]
    }

    futureResult
  }

  //Array[Byte]
  override def convertLatexFile(tex: String): Future[Result] = {

    val filename = "huyaks"
    val host = "52.42.48.92"
    val port = 6000
    val url = s"http://$host:$port/cgi-bin/latex2pdf.sh?$filename"

    val futureResponse: Future[WSResponse] = for {
      responseOne <- ws.url(url).
        withHeaders("Content-Type" -> "application/x-tex").
        withHeaders("Accept" -> "application/json").
        withRequestTimeout(10000.millis).
        post(tex)

      responseTwo <- ws.url((responseOne.json \ "uri").as[String]).
        get()
    } yield responseTwo

    val futureResult: Future[Result] = futureResponse.map { response =>
      Result(
        header = ResponseHeader(200),
        body = HttpEntity.Strict(response.bodyAsBytes, Some("application/pdf"))
      )
    }

    futureResult
  }
}
