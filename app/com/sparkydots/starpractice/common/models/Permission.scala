package com.sparkydots.starpractice.common.models

import java.util.Date

import anorm._
import anorm.SqlParser._
import play.api.db.DB
import play.api.libs.json.Json
import play.api.Play.current

case class Permission(userId: String, resourceType: String, resourceId: String, permission: Int)

object Permission {

  implicit val format = Json.format[Permission]
  private val parser: RowParser[Permission] = {
    get[String]("end_user_profile_id") ~
      get[String]("resource_type") ~
      get[String]("resource_id") ~
      get[Int]("permission") map {
      case userId ~ resourceType ~ resourceId ~ permission => Permission(userId, resourceType, resourceId, permission)
    }
  }

  def list = page(0, 1000)

  def page(startIndex: Int, size: Int) = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * from end_user_permissions limit {startIndex},{size}")
        .on('startIndex -> startIndex, 'size -> size)
        .as(parser *)
    }
  }

  def listOfUser(userId: String) = pageOfUser(userId, 0, 1000)

  def pageOfUser(userId: String, startIndex: Int, size: Int): List[Permission] = {
    DB.withConnection { implicit connection =>
      SQL(
        """
        select p.* from end_user_permissions p where end_user_profile_id = {userId} or end_user_profile_id = {publicId}
        limit {startIndex},{size}
        """
      )
        .on('startIndex -> startIndex, 'size -> size, 'userId -> userId, 'publicId -> "public")
        .as(parser *)
    }
  }

  def load(userId: String, resourceType: String, resourceId: String ): Option[Permission] = {
    DB.withConnection { implicit connection =>
      SQL("select p.* from end_user_permissions p where end_user_profile_id = {userId} and resource_type = {resourceType} and resource_id = {resourceId}")
        .on('userId -> userId, 'resourceType -> resourceType, 'resourceId -> resourceId)
        .as(parser.singleOpt)
    }
  }


  def save(permission: Permission): Boolean = {
    try {
      DB.withConnection { implicit connection =>
        SQL("replace into end_user_permissions (end_user_profile_id, resource_type, resource_id, permission) values ({id}, {resourceType}, {resourceType}, {permission})")
          .on('id -> permission.userId, 'resourceType -> permission.resourceType, 'resourceId -> permission.resourceId, 'permission -> permission.permission)
          .executeUpdate
      }
      true
    }
    catch {
      case e: Exception => false
    }
  }

  def update(permission: Permission) {
    DB.withConnection { implicit connection =>
      SQL("UPDATE end_user_permissions SET permission = {permission} WHERE id = {id} and resource_type = {resourceType} and resource_id = {resourceType}")
        .on('id -> permission.userId, 'resourceType -> permission.resourceType, 'resourceId -> permission.resourceId, 'permission -> permission.permission)
        .executeUpdate
    }
  }

  def delete(permission: Permission) {
    DB.withConnection { implicit connection =>
      SQL("delete from end_user_permissions where id = {id} and resource_type = {resourceType} and resource_id = {resourceType}")
        .on('id -> permission.userId, 'resourceType -> permission.resourceType, 'resourceId -> permission.resourceId, 'permission -> permission.permission)
        .executeUpdate
    }
  }


}