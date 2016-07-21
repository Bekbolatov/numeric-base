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

  def convertLatex(tex: String, serviceInstance: Option[ServiceDiscovery.ServiceInstance] = None): Future[(Boolean, String)]

  def convertLatexFile(tex: String): Future[(Boolean, Result)]

}


class LatexServiceImpl @Inject()(ws: WSClient, serviceDiscovery: ServiceDiscovery) extends LatexService {

  override def convertLatex(tex: String,
                            useServiceInstance: Option[ServiceDiscovery.ServiceInstance] = None
                           ): Future[(Boolean, String)] = {

    val serviceInstance = (useServiceInstance orElse serviceDiscovery.findService("latex2pdf")).get
    val host = serviceInstance.host
    val port = serviceInstance.port

    val url = s"http://$host:$port/cgi-bin/latex2pdf.sh"

    val request: WSRequest = ws.url(url).
      withHeaders("Content-Type" -> "application/x-tex").
      withHeaders("Accept" -> "application/json").
      withRequestTimeout(10000.millis)

    val futureResponse: Future[WSResponse] = request.post(tex)

    val futureResult: Future[(Boolean, String)] = futureResponse.map {
      response =>
        val jresponse = response.json
        val error = jresponse \ "error"

        if (error.toOption.isDefined) {
          (false, s"http://$host:$port${(response.json \ "log").as[String]}")
        } else {
          (true, s"http://$host:$port${(response.json \ "uri").as[String]}")
        }
    }

    futureResult
  }

  override def convertLatexFile(tex: String): Future[(Boolean, Result)] = {
    val serviceInstance = serviceDiscovery.findService("latex2pdf").get

    val host = serviceInstance.host
    val port = serviceInstance.port

    val futureResponse: Future[(Boolean, WSResponse)] = for {
      (success, uri) <- convertLatex(tex, Some(serviceInstance))
      fileResponse <- ws.url(uri).get()
    } yield (success, fileResponse)

    val futureResult: Future[(Boolean, Result)] = futureResponse.map { case (success, response) =>
      (success, if (success) {
        Result(
          header = ResponseHeader(200),
          body = HttpEntity.Strict(response.bodyAsBytes, Some("application/pdf"))
        ).withHeaders("Content-Disposition" -> "inline; filename=\"result.pdf\"")
      } else {
        Result(
          header = ResponseHeader(200),
          body = HttpEntity.Strict(response.bodyAsBytes, Some("plain/text"))
        )
      })
    }
    futureResult
  }
}
