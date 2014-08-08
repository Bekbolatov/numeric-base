package com.sparkydots.play.example.datasource

import com.sparkydots.play.example.datasource

import scala.reflect.runtime.universe._

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 7:15 PM
 */
trait DataSource {

  def save[A <: AnyRef : TypeTag](value: A): Unit

  def findAll[A <: AnyRef : TypeTag](): Stream[A]

  def findByPublicId[A <: AnyRef : TypeTag](public_id: String): Option[A]
}

object DataSource {
  // use DBDataSource implementation of DataSource
  implicit val dbSource: DataSource = DBDataSource

  // use MySQLDataSource implementation of DataSource
  //implicit val dbSource: DataSource = MySQLDataSource
}
