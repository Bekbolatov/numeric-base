package com.sparkydots.play.example.services

import com.sparkydots.play.example.dao._
import com.sparkydots.play.example.models._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 6:57 PM
 */
object ClientService {

  def allClients: Stream[Client] = {
    ClientDao.findAll()
  }

  def create(client: Client) {
    ClientDao.save(client.withNewId)
  }

  def update(client: Client) {
    ClientDao.save(client)
  }
}
