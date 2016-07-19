package com.sparkydots.starpractice.common.models

import java.util.Date

import anorm.SqlParser._
import anorm._
import play.api.Play.current
import play.api.db.DB
import play.api.libs.json.Json

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/13/14 6:36 PM
 */
case class Activity(id: String, name: String, shortDescription: String, description: String, authorName: String, authorEmail: String, authorDate: Date, version: Int, content: String)

object Activity {

  implicit val activityFormat = Json.format[Activity]

  private val activityParser: RowParser[Activity] = {
    get[String]("id") ~
      get[String]("name") ~
      get[String]("short_description") ~
      get[String]("description") ~
      get[String]("author_name") ~
      get[String]("author_email") ~
      get[Date]("author_date") ~
      get[Int]("version") map {
      case id ~ name ~ shortDescription ~ description ~ authorName ~ authorEmail ~ authorDate ~ version => Activity(id, name, shortDescription, description, authorName, authorEmail, authorDate, version, "<data>")
    }
  }

  def list = page(0, 1000)

  def page(startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from activity limit {startIndex},{size}")
        .on('startIndex -> startIndex, 'size -> size)
        .as(activityParser *)
    }
  }

  def load(id: String): Option[Activity] = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from activity where id = {id}")
        .on('id -> id)
        .as(activityParser.singleOpt)
    }
  }

  def save(activity: Activity): Boolean = {
    try {
      DB.withConnection { implicit connection =>
        SQL(
          """
            insert into activity (id, name, short_description, description, author_name, author_email, author_date, version) values
            ({id}, {name}, {shortDescription}, {description}, {authorName}, {authorEmail}, {authorDate}, {version})
          """
        )
          .on(
            'id ->
              activity.id,
            'name -> activity.name,
            'shortDescription -> activity
              .shortDescription,
            'description -> activity.description,
            'authorName -> activity.authorName,
            'authorEmail -> activity.authorEmail,
            'authorDate -> activity.authorDate,
            'version ->
              activity.
                version)
          .executeUpdate
      }
      true
    }
    catch {
      case e: Exception => false
    }
  }

  def update(id: String, activity: Activity) {
    DB.withConnection { implicit connection =>
      SQL( """
    		  UPDATE activity SET
          id = {newid},
    		  name = {name},
    		  short_description = {shortDescription},
    		  description = {description},
    		  author_name = {authorName},
    		  author_email = {authorEmail},
    		  version = {version}
    		  WHERE id = {id}
           """).on(
          'id -> id,
          'newid -> activity.id,
          'name -> activity.name,
          'shortDescription -> activity.shortDescription,
          'description -> activity.description,
          'authorName -> activity.authorName,
          'authorEmail -> activity.authorEmail,
          'version -> activity.version
        ).executeUpdate
    }
  }

  def delete(id: String) {
    DB.withConnection { implicit connection =>
      SQL("delete from channel_activity where activity_id = {id}")
        .on('id -> id)
        .executeUpdate
      SQL("DELETE FROM activity where id = {id}")
        .on('id -> id)
        .executeUpdate
    }
  }


  // Channels (Activity Lists)
  def listForChannel(channel: String) = pageOfChannel(channel, 0, 1000)
  def pageOfChannel(channelId: String, startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL(
        """
        select a.* from activity a
        left join channel_activity ala on (ala.activity_id = a.id and ala.channel_id = {channelId})
        where ala.activity_id is not null
        limit {startIndex},{size}
        """
      )
        .on('startIndex -> startIndex, 'size -> size, 'channelId -> channelId)
        .as(activityParser *)
    }
  }

  def addToChannel(id: String, chid: String) {
    DB.withConnection { implicit connection =>
      SQL("REPLACE INTO channel_activity (activity_id, channel_id) values ({id}, {chid})")
        .on('id -> id, 'chid -> chid)
        .executeUpdate
    }
  }

  def removeFromChannel(id: String, chid: String) {
    DB.withConnection { implicit connection =>
      SQL("DELETE FROM channel_activity where activity_id = {id} and channel_id = {chid}")
        .on('id -> id, 'chid -> chid)
        .executeUpdate
    }
  }

}