package com.sparkydots.modules

import javax.inject.Inject

import play.api.inject.ApplicationLifecycle

import scala.concurrent.Future
import java.net.InetAddress

import collection.JavaConversions._
import play.api.Logger
import org.slf4j.{LoggerFactory, Logger => Slf4jLogger}
import ch.qos.logback.classic.LoggerContext
import ch.qos.logback.core.Appender
import ch.qos.logback.core.rolling.RollingFileAppender
import ch.qos.logback.core.rolling.helper.{CompressionMode, Compressor}
import org.joda.time.{DateTime, DateTimeZone}

import scala.util.Try


trait LogHelper {
  def getMachineInfo: String

  val d = 7
}


class LogHelperImpl @Inject()(lifecycle: ApplicationLifecycle) extends LogHelper {

  lazy val compressor = new Compressor(CompressionMode.GZ)

  def gzName(fileName: String): String = {
    val curtime = new DateTime(DateTimeZone.UTC)
    s"$fileName.${curtime.getMillis}.gz"
  }

  def compress(fileName: String) = {
    println(s"...$fileName")
    compressor.compress(fileName, gzName(fileName), "")
  }

  lifecycle.addStopHook { () =>
    val t = Try {

      val loggerContext: LoggerContext = LoggerFactory.getILoggerFactory.asInstanceOf[LoggerContext]
      val allLoggers = loggerContext.getLoggerList.toList
      val allRemainingFiles = allLoggers.
        flatMap(_.iteratorForAppenders().toList).
        toSet.
        map { x: Appender[_] =>  x.asInstanceOf[RollingFileAppender[_]]}.
        map(_.getFile)

      println("Generating final log file GZ for the following files: ")
      allRemainingFiles.foreach(println)

      println("loggerContext.stop()")
      loggerContext.stop()

      println("Compressing...")
      allRemainingFiles.foreach(compress)

    }.failed.map(_.printStackTrace())

    println("Bye LogHelper")
    Future.successful(())
  }

  override def getMachineInfo: String = {
    val localhost = InetAddress.getLocalHost
    //    val localIpAddress = localhost.getHostAddress
    localhost.toString
  }
}