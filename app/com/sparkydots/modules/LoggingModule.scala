package com.sparkydots.modules

import play.api.Configuration
import play.api.Environment
import play.api.inject.Binding
import play.api.inject.Module

class LoggingModule extends Module {
  def bindings(environment: Environment, configuration: Configuration): Seq[Binding[_]] = {
    Seq(
      bind[LogHelper].to[LogHelperImpl],
      bind[LatexService].to[LatexServiceImpl]
    )
  }
}

