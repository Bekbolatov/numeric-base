package com.sparkydots.nlp.forms.nlp

import com.sparkydots.nlp.models.{PhraseRequest, TranslateRequest}
import play.api.data.Forms._
import play.api.data._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:26 PM
 */
object TranslateForm extends Form[TranslateRequest](
  mapping(
    "text" -> nonEmptyText,
    "translation" -> optional(nonEmptyText)
  )
    (TranslateRequest.apply)(TranslateRequest.unapply), Map.empty, Nil, None
)


object PhraseForm extends Form[PhraseRequest] (
  mapping(
    "phrase" -> nonEmptyText,
    "options" -> optional(list(nonEmptyText))
  )
    (PhraseRequest.apply)(PhraseRequest.unapply), Map.empty, Nil, None
)
