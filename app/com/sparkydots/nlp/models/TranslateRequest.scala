package com.sparkydots.nlp.models

import play.api.libs.json.Json

case class TranslateRequest(text: String, translation: Option[String])

object TranslateRequest {
  implicit val translateRequestFormat = Json.format[TranslateRequest]

}


case class PhraseRequest(phrase: String, options: Option[List[String]])

object PhraseRequest {
  implicit val phraseRequestFormat = Json.format[PhraseRequest]

}