package com.sparkydots.play.example.forms

import com.sparkydots.play.example.models.Person
import play.api.data.Form
import play.api.data.Forms._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/30/14 1:38 PM
 */
object PersonForm extends Form[Person](
  mapping(
    "name" -> text //.verifying("must contains 's'", name => name.contains("s"))
  )(Person.apply)(Person.unapply), Map.empty, Nil, None)
