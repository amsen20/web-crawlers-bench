val scala3Version = "3.3.3"

lazy val root = project
  .in(file("."))
  .settings(
    // assembly / mainClass := Some("crawler.Main"),
    name := "web-crawler-gears-jvm",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies ++= Seq(
      "org.scalameta" %% "munit" % "0.7.29" % Test,
      "ch.epfl.lamp" %% "gears" % "0.2.0-SNAPSHOT",
      "com.lihaoyi" %% "requests" % "0.8.2",
    ),
  )
