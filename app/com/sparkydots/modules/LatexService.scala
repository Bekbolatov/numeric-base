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
  def convertLatex(tex: String, filename: String): Future[String] //Array[Byte]
  def convertLatexFile(tex: String, filename: String): Future[Result] //Array[Byte]
}


class LatexServiceImpl @Inject()(ws: WSClient, serviceDiscovery: ServiceDiscovery) extends LatexService {
  override def convertLatex(tex: String, filename: String): Future[String] = {
    val serviceInstance = serviceDiscovery.findService("latex2pdf").get
    val host = serviceInstance.host
    val port = serviceInstance.port

    val url = s"http://$host:$port/cgi-bin/latex2pdf.sh?$filename"

    val request: WSRequest = ws.url(url).
      withHeaders("Content-Type" -> "application/x-tex").
      withHeaders("Accept" -> "application/json").
      withRequestTimeout(10000.millis)
    // withQueryString("search" -> "play")

    val futureResponse: Future[WSResponse] = request.post(tex)

    val futureResult: Future[String] = futureResponse.map {
      response =>
        s"http://$host:$port${(response.json \ "uri").as[String]}"
    }

    futureResult
  }

  //Array[Byte]
  override def convertLatexFile(tex: String, filename: String): Future[Result] = {
    val serviceInstance = serviceDiscovery.findService("latex2pdf").get
    val host = serviceInstance.host
    val port = serviceInstance.port

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
