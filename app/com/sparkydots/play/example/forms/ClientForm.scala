package com.sparkydots.play.example.forms

import com.sparkydots.play.example.models.Client
import play.api.data.Form
import play.api.data.Forms._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 7:48 PM
 */

//Form(mapping, Map.empty, Nil, None)

object ClientForm extends Form[Client](
  mapping(
    "public_id" -> text,
    "name" -> text.verifying("must be non-empty", name => !name.isEmpty) //.verifying("must contains 's'", name => name.contains("s"))
  )(Client.apply)(Client.unapply), Map.empty, Nil, None)


/*

import com.sparkydots.play.example.models.Client
import play.api.data.Form
import play.api.data.Forms._

object ClientForm {
  val clientForm: Form[Client] = Form {
    mapping(
      "public_id" -> text,
      "name" -> text //.verifying("must contains 's'", name => name.contains("s"))
    )(Client.apply)(Client.unapply)
  }
}

*/