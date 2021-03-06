package com.sparkydots.starpractice.common.services

import com.sparkydots.starpractice.common.models._
import play.api.mvc.{Action, EssentialAction, Results}

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/26/14 6:02 PM
 */
case class AuthorisationChecker(user: EndUserProfile) extends Results {
  def isRoot = {
    Permission.load(user.id, "root", "1").exists(permission => permission.permission == 7)
  }
  def onlyRoot(action: => EssentialAction): EssentialAction = {
    if (isRoot) {
      action()
    } else {
      Action {
        Unauthorized
      }
    }
  }
}
