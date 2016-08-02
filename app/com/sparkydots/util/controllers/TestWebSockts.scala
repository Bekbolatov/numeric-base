package com.sparkydots.util.controllers

import javax.inject._

import akka.actor.{OneForOneStrategy, ActorRefFactory, SupervisorStrategy, Props, Terminated, PoisonPill, Actor, ActorSystem, ActorRef, Status, _}
import play.api.mvc._
import akka.stream.{OverflowStrategy, Materializer}
import akka.stream.scaladsl.{Keep, Sink, Source, Flow, RunnableGraph}
import com.sparkydots.util.controllers.HelloActor.{ResponseToSlack, SayHello, FromSlack}
import play.api.libs.json.{Format, Json, JsValue}

import scala.concurrent.{Future, ExecutionContext}
import scala.concurrent.duration._
import scala.util.Try

object FlowActor {
  def newActorRef[In, Out](props: ActorRef => Props,
                           bufferSize: Int = 16,
                           overflowStrategy: OverflowStrategy = OverflowStrategy.dropNew
                          )
                          (implicit factory: ActorRefFactory, mat: Materializer)
  : Flow[In, Out, _] = {

    val source = Source.actorRef[Out](bufferSize, overflowStrategy)
    val (outActor, publisher) = source.toMat(Sink.asPublisher(false))(Keep.both).run()

    Flow.fromSinkAndSource(
      Sink.actorRef(factory.actorOf(Props(new Actor {
        val flowActor = context.watch(context.actorOf(props(outActor), "flowActor"))

        def receive = {
          case Status.Success(_) | Status.Failure(_) => flowActor ! PoisonPill
          case Terminated =>
            println("Child terminated, stopping")
            context.stop(self)
          case other => flowActor ! other
        }

        override def supervisorStrategy = OneForOneStrategy() {
          case t =>
            println("Stopping actor due to exception")
            t.printStackTrace()
            SupervisorStrategy.Stop
        }
      })), akka.actor.Status.Success(())),
      Source.fromPublisher(publisher)
    )
  }

}

class Controller1 @Inject()(implicit system: ActorSystem, materializer: Materializer) extends play.api.mvc.Controller {


  def socket = WebSocket.accept[String, String] { request =>

//    val s = Source.tick(1.seconds, 1.seconds, 1)
//    s.runForeach(println)

    FlowActor.newActorRef(out => MyWebSocketActor.props(out))
    //    ActorFlow.actorRef(out => MyWebSocketActor.props(out))


  }

  def example = {
    val source = Source(1 to 10)
    val sink = Sink.fold[Int, Int](0)(_ + _)

    // connect the Source to the Sink, obtaining a RunnableGraph
    val runnable: RunnableGraph[Future[Int]] = source.toMat(sink)(Keep.right)

    // materialize the flow and get the value of the FoldSink
    val sum: Future[Int] = runnable.run()
  }


  def exmpleremo = {

    implicit val system = ActorSystem("locals")

    class LocalActor extends Actor {
//      val remote = context.actorSelection("akka.tcp://application@192.168.99.1:2552/user/$a/flowActor")
      val remote = context.actorSelection("akka.tcp://application@ec2-52-43-3-58.us-west-2.compute.amazonaws.com:12552/user/$a/flowActor")
//      val remote = context.actorSelection("akka.tcp://application@127.0.0.1:2552/user/$a/flowActor")
//      val remote = context.actorSelection("akka.tcp://application@ec2-52-35-198-161.us-west-2.compute.amazonaws.com:12552/user/$a/flowActor")

      def receive = {
        case "HUY" => println("HUY received")
        case msg: String => remote ! msg
      }
    }

    val localActor = system.actorOf(Props[LocalActor], name = "LocalActor5")

    localActor ! "sendall"

  }
  //
  //
  //  def actorRef[In, Out](props: ActorRef => Props, bufferSize: Int = 16, overflowStrategy: OverflowStrategy = OverflowStrategy.dropNew)(implicit factory: ActorRefFactory, mat: Materializer): Flow[In, Out, _] = {
  //
  //    val source: Source[Out, ActorRef] = Source.actorRef[Out](bufferSize, overflowStrategy)
  //    val mat: RunnableGraph[(ActorRef, Publisher[Out])] = source.toMat(Sink.asPublisher(false))(Keep.both)
  //    val (outActor, publisher) = mat.run()
  //
  //    Flow.fromSinkAndSource(
  //      Sink.actorRef(factory.actorOf(Props(new Actor {
  //        val flowActor = context.watch(context.actorOf(props(outActor), "flowActor"))
  //
  //        def receive = {
  //          case Status.Success(_) | Status.Failure(_) => flowActor ! PoisonPill
  //          case Terminated =>
  //            println("Child terminated, stopping")
  //            context.stop(self)
  //          case other => flowActor ! other
  //        }
  //
  //        override def supervisorStrategy = OneForOneStrategy() {
  //          case _ =>
  //            println("Stopping actor due to exception")
  //            SupervisorStrategy.Stop
  //        }
  //      })), akka.actor.Status.Success(())),
  //      Source.fromPublisher(publisher)
  //    )
  //  }
  //


}


import scala.concurrent.Future
import play.api.mvc._
import play.api.libs.streams._

class Controller3 @Inject()(implicit system: ActorSystem, materializer: Materializer) extends play.api.mvc.Controller {
  def socket = WebSocket.acceptOrResult[String, String] { request =>
    Future.successful(request.session.get("user") match {
      case None => Left(Forbidden)
      case Some(_) => Right(ActorFlow.actorRef(MyWebSocketActor.props))
    })
  }
}

import akka.actor._

object MyWebSocketActor {
  def props(out: ActorRef) = Props(new MyWebSocketActor(out))
}

case class MessageSending(msg: String)

class MyWebSocketActor(out: ActorRef) extends Actor {

  println("Started MyWebSocketActor: " + this)
  println(" path: " + self.path)

  var myrec: Option[ActorRef] = None

  def receive = {
    case "receiver" =>
      println("My recv: " + sender())
      myrec = Some(sender())

    case "blah" =>
      println("received blah")
      sender() ! "HUY"

    case MessageSending(msg) =>
      println("Received " + msg)
      myrec.map(r => r ! msg)

    case "sendall" =>
      println("sending to all: flowActor")
      context.actorSelection("akka://application/user/*/flowActor") ! MessageSending("BCAST")

    case "others?" =>
      println("searching: " + context.system./("**"))
      context.actorSelection("akka://application/user/*/flowActor") ! Identify(())

    case path: String if path.startsWith("path-") =>
      println(path)
      println(path.split("-"))
      path.split("-").zipWithIndex.foreach { case (i, p) =>
        println(s"$i => $p")
      }
      val ppa = path.split("-")(1)
      println(ppa)
      val pppa = context.system./(ppa)
      println(pppa)
      Try {
        context.actorSelection(ppa) ! MessageSending("BCAST")
      }.recover { case t =>
        t.printStackTrace()
      }
      println("sent")


    case ActorIdentity(_, Some(ref)) =>
      println(s"found: ${ref.path}")
      self ! ref.path

    case "KILL" =>
      killmyself
    case msg: String =>
      out ! ("I received your message: " + msg)
  }

  override def postStop() = {
    println("AKTOR GESLOSSTYYYAA")
  }


  def killmyself = {
    self ! PoisonPill
  }
}


object HelloActor {
  def props = Props[HelloActor]

  case class SayHello(name: String)
  case class FromSlack(user_name: String, text: String)
  case class ResponseToSlack(text: String)

}

class HelloActor extends Actor {
  import HelloActor._
  implicit val ResponseToSlackFormat = Json.format[ResponseToSlack]

  var items: Seq[String] = Seq()

  def receive = {
    case SayHello(name: String) =>
      sender() ! "Hello, " + name
    case FromSlack(user_name, text) =>
      val response_text = if (user_name == "slackbot") {
        ""
      } else {
        s"Oh yeah, $user_name, $text"
      }
      def jsonString = Json.toJson(ResponseToSlack(response_text)).toString
      sender() ! jsonString
  }
}

import scala.concurrent.duration._
import akka.pattern.ask


@Singleton
class SlackController @Inject()(implicit system: ActorSystem, materializer: Materializer, ec: ExecutionContext) extends Controller {

  implicit val timeout: akka.util.Timeout = 5.seconds

  val helloActor = system.actorOf(HelloActor.props, "hello-actor")

  def fromSlack(name: String) = Action.async { request =>

    if (name == "roblox") {

      println(request.body)

      request.body.asJson.map { data =>
        println(data)

        val token = (data \ "token").as[String]
        if (token == "bqXUvO3W0WOgc5Cykl9aOVTG") {
          //      (helloActor ? SayHello("g")).mapTo[String].map { message =>
          val text = (data \ "text").as[String]
          val user_name = (data \ "user_name").as[String]

          (helloActor ? FromSlack(user_name, text)).mapTo[String].map { message =>
            Ok(message)
          }
        } else {
          Future.successful(Ok(""))
        }
      }.orElse {
        request.body.asFormUrlEncoded.map { data =>
          println(data)

          val token = data("token").head
          if (token == "bqXUvO3W0WOgc5Cykl9aOVTG") {
            val text = data("text").head
            val user_name = data("user_name").head

            (helloActor ? FromSlack(user_name, text)).mapTo[String].map { message =>
              Ok(message)
            }
          } else {
            Future.successful(Ok(""))
          }

        }
      }.getOrElse {
        Future.successful(Ok(""))
      }
    } else {
      Future.successful(Ok("hello"))
    }
  }
}
