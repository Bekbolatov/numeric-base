package com.sparkydots.nlp.controllers

import com.sparkydots.activityServer.forms.admin.ActivityForm
import com.sparkydots.nlp.forms.nlp.{PhraseForm, TranslateForm}
import com.sparkydots.nlp.models.{PhraseRequest, TranslateRequest}
import com.sparkydots.nlp.mt.PhraseTranslation
import com.sparkydots.nlp.views
import play.api.data.Form

//import play.api.Play.current
//import play.api.libs.concurrent.Execution.Implicits.defaultContext
import play.api.mvc._

/**
  * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
  */
object MT extends Controller {

  import play.api.libs.json.Json

  val form = TranslateForm
  val phrasesForm = PhraseForm


  def translate = Action { implicit request =>
        val boundForm = form.bindFromRequest
        boundForm.fold(
          formWithErrors => BadRequest(formWithErrors.errorsAsJson),
          translateRequest => {
            if (true) {
              val translated = PhraseTranslation.translate(translateRequest.text)
//              val translated = clean(translateRequest.text).mkString
              val newForm = form.fill(translateRequest.copy(translation = Some(translated)))
              Ok(views.html.nlp.translate(newForm))
            } else {
              BadRequest("{ \"Error\" : \"error\" }")
            }
          })
      }


  def phrase = Action { implicit request =>
    val boundForm = phrasesForm.bindFromRequest
    boundForm.fold(
      formWithErrors => BadRequest(formWithErrors.errorsAsJson),
      translateRequest => {
        if (true) {
          val cleanText = PhraseTranslation.clean(translateRequest.phrase)

          val translated = PhraseTranslation.phrases(cleanText).toList
          val newForm = phrasesForm.fill(translateRequest.copy(options = Some(translated)))
          Ok(views.html.nlp.phrase(newForm))
        } else {
          BadRequest("{ \"Error\" : \"error\" }")
        }
      })
  }

//  def translate_classic =  Action { request =>
//    val json = request.body.asJson.get
//    val phrase = json.as[PhraseRequest]
//    println(phrase)
//    Ok
//  }

   def index = Action {
     Ok(views.html.nlp.index())
   }

  def phrase_input = Action {
    Ok(views.html.nlp.phrase(PhraseForm))
  }

  def translate_input = Action {
    Ok(views.html.nlp.translate(TranslateForm))
  }



}