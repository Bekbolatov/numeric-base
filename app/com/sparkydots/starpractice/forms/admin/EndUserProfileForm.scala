package com.sparkydots.starpractice.forms.admin

import com.sparkydots.starpractice.models.EndUserProfile
import play.api.data.Forms._
import play.api.data._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:26 PM
 */
object EndUserProfileForm extends Form[EndUserProfile](
  mapping(
    "id" -> nonEmptyText,
    "name" -> nonEmptyText,
    "createDate" -> date)
    (EndUserProfile.apply)(EndUserProfile.unapply), Map.empty, Nil, None
)

