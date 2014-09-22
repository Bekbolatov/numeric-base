package com.sparkydots.activityServer.forms.admin

import com.sparkydots.activityServer.models.Activity
import play.api.data.Forms._
import play.api.data._
/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:26 PM
 */
object ActivityForm extends Form[Activity](
  mapping(
    "id" -> nonEmptyText,
    "name" -> nonEmptyText,
    "shortDescription" -> nonEmptyText,
    "description" -> nonEmptyText,
    "authorName" -> nonEmptyText,
    "authorEmail" -> email,
    "authorDate" -> date,
    "version" -> number)
    (Activity.apply)(Activity.unapply), Map.empty, Nil, None
)

