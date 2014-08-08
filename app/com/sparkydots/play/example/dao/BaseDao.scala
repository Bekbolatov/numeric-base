package com.sparkydots.play.example.dao

import com.sparkydots.play.example.datasource.DataSource

import scala.reflect.runtime.universe.TypeTag

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 6:58 PM
 */
trait BaseDao[A <: AnyRef] {

  lazy val ds = implicitly[DataSource]

  def save(a: A)(implicit evidence: TypeTag[A]) {
    ds.save(a)
  }

  def findByPublicId(public_id: String)(implicit evidence: TypeTag[A]): Option[A] = {
    ds.findByPublicId(public_id)
  }

  def findAll()(implicit evidence: TypeTag[A]): Stream[A] = {
    ds.findAll[A]()
  }

}
