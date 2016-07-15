import Grunt._
import play.sbt.PlayImport.PlayKeys.playRunHooks

name := """SparkyDots Server"""

version := "1.0-SNAPSHOT"

scalaVersion := "2.11.8" //2.10.6"  //"2.11.1"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

CoffeeScriptKeys.sourceMap := false

CoffeeScriptKeys.bare := true


includeFilter in (Assets, LessKeys.less) := "*.less"

// need to disable for prod
//playRunHooks <+= baseDirectory.map(base => Grunt(base))  // (base / "app" / "assets"))


//pipelineStages := Seq(uglify)
//includeFilter in uglify := GlobFilter("javascripts/*.js")
//UglifyKeys.uglifyOps := {
//  js =>
//    Seq( (js.sortBy(_._2), "myconcat.min.js"))
//}




libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  "com.typesafe.play" %% "anorm" % "2.4.0",
  "org.sorm-framework" % "sorm" % "0.3.15",
  "com.github.seratch" %% "awscala" % "0.5.+"
)

libraryDependencies += "mysql" % "mysql-connector-java" % "5.1.27"

TwirlKeys.templateImports += "com.sparkydots.activityServer.models._"

TwirlKeys.templateImports += "com.sparkydots.common.controllers.routes"

net.virtualvoid.sbt.graph.Plugin.graphSettings




