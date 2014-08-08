package com.sparkydots.play.example.models

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 7:07 PM
 */
case class Client(public_id: String, name: String) {
  def withNewId: Client = {
    copy(public_id = java.util.UUID.randomUUID.toString)
  }
}
