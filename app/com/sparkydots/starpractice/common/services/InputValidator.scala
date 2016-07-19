package com.sparkydots.starpractice.common.services

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 9:07 PM
 */
object InputValidator {
  val allowedChars=(('a' to 'z') ++ ('A' to 'Z') ++ ('0' to '9') ++ List('.', '_')).toSet
  def validateString(id: String)= {
    id.length < 100 && id.forall(allowedChars.contains(_))
  }

}
