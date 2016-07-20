package com.sparkydots.modules

import java.io.File

object ServiceDiscovery {
  case class ServiceInstance(host: String, port: Int)
}

trait ServiceDiscovery {
  def findService(serviceName: String): Option[ServiceDiscovery.ServiceInstance]
}

class ServiceDiscoveryImpl extends ServiceDiscovery {

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

  /*
  can still be unreliable way - need to add retries, list of servers
   */
  override def findService(serviceName: String): Option[ServiceDiscovery.ServiceInstance] = {

    val instances = getListOfFiles(s"/EFS/run/services/$serviceName/")
    val port = serviceName match {
      case "latex2pdf" => 9002
      case _ => 9001
    }
    instances.headOption.map(instance => ServiceDiscovery.ServiceInstance(instance.getName, port))

  }
}
