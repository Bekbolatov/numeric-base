
name := """SparkyDots Server"""

version := "1.0-SNAPSHOT"

scalaVersion := "2.11.8" //2.10.6"  //"2.11.1"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

CoffeeScriptKeys.sourceMap := false

CoffeeScriptKeys.bare := true


includeFilter in (Assets, LessKeys.less) := "*.less"

//import Grunt._
//import play.sbt.PlayImport.PlayKeys.playRunHooks

// need to disable for prod
//playRunHooks <+= baseDirectory.map(base => Grunt(base))  // (base / "app" / "assets"))

//pipelineStages := Seq(uglify)
//includeFilter in uglify := GlobFilter("javascripts/*.js")
//UglifyKeys.uglifyOps := {
//  js =>
//    Seq( (js.sortBy(_._2), "myconcat.min.js"))
//}

unmanagedSourceDirectories in Compile += baseDirectory.value / "src" / "main" / "scala"

//javacOptions += "-Xno-uescape"

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  "com.typesafe.play" %% "anorm" % "2.4.0",
  "org.sorm-framework" % "sorm" % "0.3.15",
  "com.github.seratch" %% "awscala" % "0.5.+",
  "joda-time" % "joda-time" % "2.9.4"
)

libraryDependencies += "com.sparkydots.utils" %% "servicediscovery" % "1.0-SNAPSHOT"

libraryDependencies += "mysql" % "mysql-connector-java" % "5.1.27"

libraryDependencies += "org.scalatest" %% "scalatest" % "2.2.6" % "test"

TwirlKeys.templateImports += "com.sparkydots.starpractice.common.models._"
TwirlKeys.templateImports += "com.sparkydots.common.controllers.routes"
TwirlKeys.templateImports += "com.sparkydots._"

routesGenerator := InjectedRoutesGenerator

net.virtualvoid.sbt.graph.Plugin.graphSettings




