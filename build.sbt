import Grunt._
import play.PlayImport.PlayKeys.playRunHooks

name := """Numeric StarPractice"""

version := "1.0-SNAPSHOT"

scalaVersion := "2.10.3"  //"2.11.1"

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
  anorm,
  cache,
  ws,
  "org.sorm-framework" % "sorm" % "0.3.15"
)

libraryDependencies += "mysql" % "mysql-connector-java" % "5.1.27"

TwirlKeys.templateImports += "com.sparkydots.activityServer.models._"

TwirlKeys.templateImports += "com.sparkydots.common.controllers.routes"

net.virtualvoid.sbt.graph.Plugin.graphSettings




