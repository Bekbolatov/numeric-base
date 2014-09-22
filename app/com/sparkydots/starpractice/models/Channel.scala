package com.sparkydots.starpractice.models

import java.util.Date

import anorm._
import anorm.SqlParser._
import play.api.db.DB
import play.api.libs.json.Json
import play.api.Play.current

case class Channel(id: Int, name: String, createDate: Date)

object Channel {
  implicit val format = Json.format[Channel]
  private val parser: RowParser[Channel] = {
    get[Int]("id") ~
      get[String]("name") ~
      get[Date]("create_date") map {
      case id ~ name ~ createDate => Channel(id, name, createDate)
    }
  }

  def list = page(0, 1000)

  def page(startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from channel limit {startIndex},{size}")
        .on('startIndex -> startIndex, 'size -> size)
        .as(parser *)
    }
  }

  def load(id: Int): Option[Channel] = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from channel where id = {id}")
        .on('id -> id)
        .as(parser.singleOpt)
    }
  }

  def save(channel: Channel): Boolean = {
    try {
      DB.withConnection { implicit connection =>
        SQL("insert into channel (id, name, create_date) values ({id}, {name}, {createDate})")
          .on('id -> channel.id, 'name -> channel.name, 'createDate -> channel.createDate)
          .executeUpdate
      }
      true
    }
    catch {
      case e: Exception => false
    }
  }

  def update(id: Int, channel: Channel) {
    DB.withConnection { implicit connection =>
      SQL("UPDATE channel SET name = {name} WHERE id = {id}")
        .on('id -> id, 'name -> channel.name)
        .executeUpdate
    }
  }

  def delete(id: Int) {
    DB.withConnection { implicit connection =>
      SQL("delete from end_user_channel where channel_id = {id}")
        .on('id -> id)
        .executeUpdate
      SQL("delete from channel_activity where channel_id = {id}")
        .on('id -> id)
        .executeUpdate
      SQL("DELETE FROM channel where id = {id}")
        .on('id -> id)
        .executeUpdate
    }
  }

  // Channels (Activity Lists)
  def listForEndUser(id: String) = pageForEndUser(id, 0, 1000)
  def pageForEndUser(id: String, startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL(
        """
        select c.* from channel c, end_user_channel euc
        where c.id = euc.channel_id and euc.end_user_profile_id = {id}
        limit {startIndex},{size}
        """
      )
        .on('startIndex -> startIndex, 'size -> size, 'id -> id)
        .as(parser *)
    }
  }


}

