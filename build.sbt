
name := """play-scala-intro"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

includeFilter in (Assets, LessKeys.less) := "*.less"

pipelineStages := Seq(uglify)

includeFilter in uglify := GlobFilter("javascripts/*.js")


//scalaVersion := "2.11.1"

scalaVersion := "2.10.3"  

libraryDependencies ++= Seq(
  jdbc,
  anorm,
  cache,
  ws,
  "org.sorm-framework" % "sorm" % "0.3.15"
)


net.virtualvoid.sbt.graph.Plugin.graphSettings



