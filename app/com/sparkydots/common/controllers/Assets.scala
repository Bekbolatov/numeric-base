package com.sparkydots.common.controllers

import play.api.http.LazyHttpErrorHandler

/**
 * @author Renat Bekbolatov (renatb@sparkydots.com) 7/29/14 11:24 PM
 */

class Assets extends controllers.AssetsBuilder(LazyHttpErrorHandler)
