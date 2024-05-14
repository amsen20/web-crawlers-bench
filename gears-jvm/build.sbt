val scala3Version = "3.3.3"

lazy val root = project
  .in(file("."))
  .settings(
    name := "web-crawler-gears-jvm",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies ++= Seq(
      "org.scalameta" %% "munit" % "0.7.29" % Test,
      "ch.epfl.lamp" %% "gears" % "0.2.0-SNAPSHOT",
      "com.lihaoyi" %% "requests" % "0.8.2",
    ),
    javaOptions ++= Seq(
      "Xms512M",
      "-Xmx1024M",
      "-Xss2M",
      "-XX:MaxMetaspaceSize=1024M",
    ),
  )
