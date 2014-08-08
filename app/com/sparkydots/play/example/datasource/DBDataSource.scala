package com.sparkydots.play.example.datasource

import com.sparkydots.play.example.models._
import sorm._

import scala.reflect.runtime.universe.TypeTag

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/28/14 3:04 PM
 */

object DBDataSource extends DataSource {

  // register all entities
  val entities = Seq(
    Entity[Person](),
    Entity[Client]()
  )

  // provide DB url
  val url = "jdbc:h2:mem:test"

  val instance = new Instance(entities = entities, url = url)


  def save[A <: AnyRef : TypeTag](a: A) {
    instance.save(a)
  }

  def findAll[A <: AnyRef : TypeTag](): Stream[A] = {
    instance.query[A].fetch()
  }

  def findByPublicId[A <: AnyRef : TypeTag](public_id: String): Option[A] = {
    instance.query[A].whereEqual("public_id", public_id).fetchOne()
  }

}



