package com.sparkydots.activityServer.models

import java.text.SimpleDateFormat
import java.util.{Calendar, Date}

import anorm._
import anorm.SqlParser._
import play.api.db.DB
import play.api.libs.json.Json
import play.api.Play.current

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 9/18/14 7:13 PM
 */

case class EndUserProfile(id: String, name: String, createDate: Date)

object EndUserProfile {

  implicit val endUserProfileFormat = Json.format[EndUserProfile]

  private val parser: RowParser[EndUserProfile] = {
    get[String]("id") ~
      get[String]("name") ~
      get[Date]("create_date") map {
      case id ~ name ~ createDate => EndUserProfile(id, name, createDate)
    }
  }

  def list = page(0, 1000)

  def page(startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from end_user_profile limit {startIndex},{size}")
        .on('startIndex -> startIndex, 'size -> size)
        .as(parser *)
    }
  }

  def getOrCreate(id: String): Option[EndUserProfile] =
    DB.withConnection { implicit connection =>
      SQL("SELECT * from end_user_profile where id = {id}")
        .on('id -> id)
        .as(parser.singleOpt)
    }.orElse {
      DB.withConnection { implicit connection =>
        SQL("SELECT p.* from end_user_profile p, end_user_alias a where p.id = a.end_user_profile_id and a.id = {id}")
          .on('id -> id)
          .as(parser.singleOpt)
      }
    }.orElse {
      val today = Calendar.getInstance().getTime()
      try {
        DB.withConnection { implicit connection =>
          SQL("REPLACE INTO end_user_profile (id, name, create_date) values ({id}, {id}, {today})")
            .on('id -> id, 'today -> today)
            .executeUpdate
        }
      }
      catch {
        case e: Exception => return None
      }
      Some(EndUserProfile(id, id, today))
    }

  def update(profile: EndUserProfile) {
    DB.withConnection { implicit connection =>
      SQL("UPDATE end_user_profile SET name = {name} WHERE id = {id}")
        .on('id -> profile.id, 'name -> profile.name)
        .executeUpdate
    }
  }

  def addAlias(id: String, userUserProfileId: String) {
    DB.withConnection { implicit connection =>
      SQL( """
    		  REPLACE INTO end_user_alias (id, end_user_profile_id) values ({id}, {userUserProfileId})
           """).on(
          'id -> id,
          'userUserProfileId -> userUserProfileId
        ).executeUpdate
    }
  }

  def removeAlias(id: String, userUserProfileId: String) {
    DB.withConnection { implicit connection =>
      SQL( """
    		  DELETE FROM end_user_alias where id = {id} and end_user_profile_id = {userUserProfileId}
           """).on(
          'id -> id,
          'userUserProfileId -> userUserProfileId
        ).executeUpdate
    }
  }

  def delete(id: String) {
    DB.withConnection { implicit connection =>
      SQL("DELETE FROM end_user_alias where end_user_profile_id = {id} ")
        .on('id -> id)
        .executeUpdate
      SQL("DELETE FROM end_user_profile where id = {id}")
        .on('id -> id)
        .executeUpdate
    }
  }

  def setPermissionChannel(userProfileId: String, channelId: String, permission: Int) { // read, write, execute - style  - if can x a channel, then can x any
    DB.withConnection { implicit connection =>
      if (permission > 0) {
        SQL("REPLACE INTO end_user_profile_permissions (end_user_profile_id, resource_type, resource_id, permission) values ({userProfileId}, {resourceType}, {resourceId}, {permission})")
          .on('userProfileId -> userProfileId, 'resourceType -> "channel", 'resourceId -> channelId, 'permission -> permission)
          .executeUpdate
      } else {
        SQL("DELETE FROM end_user_profile_permissions where end_user_profile_id = {id} and resource_type = {resourceType} and resource_id =  {resourceId} ")
          .on('userProfileId -> userProfileId, 'resourceType -> "channel", 'resourceId -> channelId)
          .executeUpdate
      }
    }
  }

  def setPermissionActivity(userProfileId: String, activityId: String, permission: Int) { // read, write, execute - style
    DB.withConnection { implicit connection =>
      SQL("REPLACE INTO end_user_profile_permissions (end_user_profile_id, resource_type, resource_id, permission) values ({userProfileId}, {resourceType}, {resourceId}, {permission})")
        .on('userProfileId -> userProfileId, 'resourceType -> "activity", 'resourceId -> activityId, 'permission -> permission)
        .executeUpdate
    }
  }
}