package com.sparkydots.play.example.controllers

import com.sparkydots.play.example.converters.JsonFormats._
import com.sparkydots.play.example.forms._
import com.sparkydots.play.example.services._
import com.sparkydots.play.example.views
import play.Logger
import play.api.Play.current
import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.libs.json.Json
import play.api.libs.ws.WS
import play.api.mvc._

import scala.concurrent.Future

/**
 * import play.api.Play.current  // currentApplication
 * import play.api.libs.concurrent.Execution.Implicits.defaultContext // current ExecutionContext
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
 */
object Application extends Controller {

  def index = Action {
    Ok(views.html.index("Your new application is ready? ")) // + routes.SecondApp.index()))
  }


  def addClient() = Action {
    implicit request =>
      ClientForm.bindFromRequest.fold(
        formWithErrors => {
          Ok(views.html.index("errors: " + formWithErrors.errors))
        },
        client => {
          ClientService.create(client)
          Redirect(routes.Application.index())
        }
      )
  }

  def getClients = Action {
    val clients = ClientService.allClients
    Ok(Json.toJson(clients))
  }

  //////////

  object LoggingAction extends ActionBuilder[Request] {
    def invokeBlock[A](request: Request[A], block: (Request[A]) => Future[Result]) = {
      Logger.info(s"Calling action ${request.method}")
      block(request)
    }
  }

  def getContentDirectly(address: Option[String]) = LoggingAction.async {

    WS.url(address.get).get().map {
      result =>
        if (result.status == 200) {
          Ok(s"The website is up ${result.body}")
        } else {
          NotFound("The website is down")
        }
    }.recover {
      case e: Exception => Ok(s"Failed to connect $e") //Or any other result that you need to return
    }
  }


}