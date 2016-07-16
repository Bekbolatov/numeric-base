package com.sparkydots.modules

import javax.inject.Inject

import play.api.inject.ApplicationLifecycle

import scala.concurrent.Future
import java.net.InetAddress

trait MyComponent {
  def getMachineInfo: String
}

class MyComponentImpl @Inject()(lifecycle: ApplicationLifecycle) extends MyComponent {
  // previous contents of Plugin.onStart
  lifecycle.addStopHook { () =>
    // previous contents of Plugin.onStop
    println("Bye MyComponentImpl")
    Future.successful(())
  }

  override def getMachineInfo: String =  {
    val localhost = InetAddress.getLocalHost
    //    val localIpAddress = localhost.getHostAddress
    localhost.toString
  }
}