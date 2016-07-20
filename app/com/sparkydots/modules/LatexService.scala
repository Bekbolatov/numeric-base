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

  def convertLatex(tex: String, filename: String,
                   serviceInstance: Option[ServiceDiscovery.ServiceInstance] = None): Future[String]

  def convertLatexFile(tex: String, filename: String): Future[Result]
}


class LatexServiceImpl @Inject()(ws: WSClient, serviceDiscovery: ServiceDiscovery) extends LatexService {

  override def convertLatex(tex: String, filename: String,
                            useServiceInstance: Option[ServiceDiscovery.ServiceInstance] = None): Future[String] = {

    val serviceInstance = (useServiceInstance orElse serviceDiscovery.findService("latex2pdf")).get
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
        val jresponse = response.json
        val error = jresponse \ "error"

        if (error.toOption.isDefined) {
          error.as[String]
        } else {
          s"http://$host:$port${(response.json \ "uri").as[String]}"
        }
    }

    futureResult
  }

  //Array[Byte]
  override def convertLatexFile(tex: String, filename: String): Future[Result] = {
    val serviceInstance = serviceDiscovery.findService("latex2pdf").get

    val host = serviceInstance.host
    val port = serviceInstance.port

    val futureResponse: Future[WSResponse] = for {
      uri <- convertLatex(tex, filename, Some(serviceInstance))
      fileResponse <- ws.url(uri).get()
    } yield fileResponse

    val futureResult: Future[Result] = futureResponse.map { response =>
      Result(
        header = ResponseHeader(200),
        body = HttpEntity.Strict(response.bodyAsBytes, Some("application/pdf"))
      )
    }

    futureResult
  }
}
