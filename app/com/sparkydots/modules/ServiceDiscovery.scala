package com.sparkydots.modules

import java.io.File

import org.joda.time.DateTime

import scala.util.{Random, Try}

object ServiceDiscovery {
  case class ServiceInstance(host: String, port: Int)
}

trait ServiceDiscovery {

  import ServiceDiscovery._

  def call[T](serviceName: String)(f: (ServiceInstance) => Option[T]): Option[T] =
    Seq(
      () => getService(serviceName),
      () => getService(serviceName, forceRefresh = true)
    ).foldLeft[Option[T]](None) {
      case (None, serviceGetter) => serviceGetter().call(f)
      case (Some(before), _) => Some(before)
    }

  case class Service(instances: Seq[ServiceInstance]) {
    def call[T](f: (ServiceInstance) => Option[T]): Option[T] = {
      Random.shuffle(instances).
        foldLeft[Option[T]](None) {
        case (None, next: ServiceInstance) => f(next)
        case (Some(before), _) => Some(before)
      }
    }
  }

  def getService(serviceName: String, forceRefresh: Boolean = false): Service

}

class ServiceDiscoveryImpl extends ServiceDiscovery {

  import ServiceDiscovery._

  val REGISTRY_LOC = "/EFS/run/services"
  val MAX_FRESH_TIME_MILLIS: Long = 300000

  case class CachedService(serviceName: String, lastUpdatedMillis: Long, expirationTimeMillis: Long, service: Service)

  var cachedServices: Seq[CachedService] = Seq()

  override def getService(serviceName: String, forceRefresh: Boolean = false): Service = {
    val curTimeMillis = new DateTime().getMillis
    val minExpirationTimeMillis = if (forceRefresh) Long.MaxValue else curTimeMillis

    cachedServices.
      find(cs => cs.serviceName == serviceName && cs.expirationTimeMillis > minExpirationTimeMillis).
      map(_.service) getOrElse updateCachedService(serviceName, curTimeMillis)
  }

  /**
    * Update and return a service - synchronized, potentially with 0 instances (but updated lastUpdatedMillis).
    * @param serviceName
    * @param requestTime
    * @return
    */
  def updateCachedService(serviceName: String, requestTime: Long): Service = synchronized {
    cachedServices.
      find(cs => cs.serviceName == serviceName && cs.lastUpdatedMillis < requestTime).
      map(_.service) getOrElse {
      val instances = Try {
        getListOfFiles(s"$REGISTRY_LOC/$serviceName/").map { file =>
          val pieces = file.getName.split(":")
          ServiceInstance(pieces(0), pieces(1).toInt)
        }
      }.getOrElse(Seq())

      val service = Service(instances)
      val curTimeMillis = new DateTime().getMillis
      val cachedService = CachedService(serviceName, curTimeMillis, curTimeMillis + MAX_FRESH_TIME_MILLIS, service)
      service
    }
  }

  def getListOfFiles(dir: String):List[File] = {
    val d = new File(dir)
    if (d.exists && d.isDirectory) {
      d.listFiles.
        filter(_.isFile).
        sortBy(_.lastModified()). // start with oldest record
        toList
    } else {
      List[File]()
    }
  }

}
