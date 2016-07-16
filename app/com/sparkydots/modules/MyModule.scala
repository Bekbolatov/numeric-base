package com.sparkydots.modules

import play.api.Configuration
import play.api.Environment
import play.api.inject.Binding
import play.api.inject.Module

class MyModule extends Module {
  def bindings(environment: Environment, configuration: Configuration): Seq[Binding[_]] = {
    Seq(
      bind[MyComponent].to[MyComponentImpl]
    )
  }
}

