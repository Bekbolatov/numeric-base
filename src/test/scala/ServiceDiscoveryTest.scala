import com.sparkydots.modules.ServiceDiscoveryImpl

import collection.mutable.Stack
import org.scalatest._


class ServiceDiscoveryTest extends FlatSpec with Matchers {

  "Service" should "use the one that works" in {
    val sd = new ServiceDiscoveryImpl()

    println(sd.getService("latex2pdf"))
  }
}
