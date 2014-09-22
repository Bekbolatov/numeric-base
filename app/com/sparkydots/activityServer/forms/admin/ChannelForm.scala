package com.sparkydots.activityServer.forms.admin

import com.sparkydots.activityServer.models.Channel
import play.api.data.Forms._
import play.api.data._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 9:26 PM
 */
object ChannelForm extends Form[Channel](
  mapping(
    "id" -> number,
    "name" -> nonEmptyText,
    "createDate" -> date)
    (Channel.apply)(Channel.unapply), Map.empty, Nil, None
)

