package com.sparkydots.nlp.mt

import _root_.edu.berkeley.nlp.io.IOUtils
import _root_.edu.berkeley.nlp.langmodel.EnglishWordIndexer
import _root_.edu.berkeley.nlp.langmodel.NgramLanguageModel
import _root_.edu.berkeley.nlp.langmodel.impl.KneserNeyLm
import _root_.edu.berkeley.nlp.langmodel.impl.NgramLanguageModelAdaptor
import _root_.edu.berkeley.nlp.langmodel.impl.NgramMapOpts
import _root_.edu.berkeley.nlp.mt.phrasetable.PhraseTable
import _root_.edu.berkeley.nlp.mt.phrasetable.PhraseTable
import _root_.edu.berkeley.nlp.mt.phrasetable.ScoredPhrasePairForSentence
import _root_.edu.berkeley.nlp.mt.phrasetable.ScoredPhrasePairForSentence
import _root_.edu.berkeley.nlp.util.CollectionUtils
import _root_.edu.berkeley.nlp.util.CollectionUtils
import _root_.edu.berkeley.nlp.util.Counter
import _root_.edu.berkeley.nlp.util.Counter
import edu.berkeley.nlp.assignments.decoding.MtDecoderTester
import edu.berkeley.nlp.assignments.decoding.student.DistortingWithLmDecoderFactory
import edu.berkeley.nlp.langmodel.EnglishWordIndexer
import edu.berkeley.nlp.langmodel.NgramLanguageModel
import edu.berkeley.nlp.langmodel.RandomLanguageModel
import edu.berkeley.nlp.langmodel.impl.KneserNeyLm
import edu.berkeley.nlp.langmodel.impl.NgramLanguageModelAdaptor
import edu.berkeley.nlp.langmodel.impl.NgramMapOpts
import java.io.{IOException, File}
import edu.berkeley.nlp.mt.decoder.LinearDistortionModel

import scala.collection.JavaConversions._


import edu.berkeley.nlp.mt.phrasetable.{ScoredPhrasePairForSentence, PhraseTable}
import edu.berkeley.nlp.util.{CollectionUtils, Counter}
import edu.berkeley.nlp.io.IOUtils



object PhraseTranslation {

//  val base: String = "/home/ec2-user/NLP/tm/data"
  val base: String = "/Users/rbekbolatov/repos/uw/csep517p4/data"

  val lmFile: File = new File(s"$base/lm.gz")
  val phraseTableFile = new File(s"$base/phrasetable.txt.gz")
  val weightsFile = new File(s"$base/weights.txt")


  def readWeightsFile(weightsFile: File): Counter[String] = {
    val ret = new Counter[String]()

    val e = CollectionUtils.iterable(IOUtils.lineIterator(weightsFile.getPath)).iterator()

    while (e.hasNext) {
      val line = e.next()
      if (line.trim().length() != 0) {
        val parts = line.trim().split("\t")
        ret.setCount(parts(0).intern(), java.lang.Double.parseDouble(parts(1) ) )
      }
    }
    ret
  }

  val weights = readWeightsFile(weightsFile)

  val indexer = EnglishWordIndexer.getIndexer
  def enc(w: String): Int = EnglishWordIndexer.getIndexer.addAndGetIndex(w)
  def encs(ss: String): Seq[Int] = ss.split(" ").map(enc _)



  val lm: NgramLanguageModel = new NgramLanguageModelAdaptor(KneserNeyLm.fromFile(new NgramMapOpts, lmFile.getPath, 3, EnglishWordIndexer.getIndexer))
  def lmp(s: String, i: Int, j: Int) = {
    lm.getNgramLogProbability(encs(s).toArray, i, j)
  }
  def uni(s: String) = lmp(s, 0, 1)
  def bi(s: String) = lmp(s, 0, 2)
  def tri(s: String) = lmp(s, 0, 3)

  def lmest(ss: String) = {
    val s = encs(ss)
    if (s.length == 1) {
      lm.getNgramLogProbability(s.toArray, 0, 1)
    } else if (s.length == 2) {
      lm.getNgramLogProbability(s.toArray, 0, 1) + lm.getNgramLogProbability(s.toArray, 0, 2)
    } else {
      var score = lm.getNgramLogProbability(s.toArray, 0, 1) + lm.getNgramLogProbability(s.toArray, 0, 2)
      (0 to (s.length - 3)).foreach { i =>
        score = score + lm.getNgramLogProbability(s.toArray, i, i + 3)
      }
      score
    }
  }

  val dm = new LinearDistortionModel(4, weights.getCount("linearDist"))

  val phraseTable = new PhraseTable(5, 30)
  phraseTable.readFromFile(phraseTableFile.getPath, weights)

  val decfac = new DistortingWithLmDecoderFactory()

  def tt(s: String): java.util.List[ScoredPhrasePairForSentence] = {
    val ws: java.util.List[String] = s.split(" ").toList
    val tt = phraseTable.initialize(ws)
    tt.getScoreSortedTranslationsForSpan(0, ws.size())
  }

  def ptt(s: String) = {
    val ss: Seq[ScoredPhrasePairForSentence] = tt(s)
    ss.foreach { println}
  }


  def trans(s: String)(i: Int = 0, j: Int = s.length): Seq[ScoredPhrasePairForSentence] = {
    val ws: java.util.List[String] = s.split(" ").toList
    val tt = phraseTable.initialize(ws)
    val res: Seq[ScoredPhrasePairForSentence] = tt.getScoreSortedTranslationsForSpan(i, j)
    res
  }

  def clean(s: String): Seq[String] = {
    var ss: Seq[String] = s.trim().split("\\s+")
    ss = ss.take(100)
    ss = ss.map(_.toLowerCase)

    ss = ss.flatMap { c =>

      val cs: Seq[String] = c.split("'")
      if (cs.size == 1) {
        Seq(c)
      } else {
        cs.take(cs.size - 1).map(_ + "'") :+ cs.last
      }
    }

    ss = ss.filter(!_.isEmpty)
    ss = ss.flatMap { c =>

      val cs: Seq[String] = c.split(",")
      if (cs.size == 1) {
        Seq(c)
      } else if (cs.size > 1) {
        cs.take(cs.size - 1).map(_ + "'") :+ cs.last
      } else {
        Seq(",")
      }
    }
    ss = ss.filter(!_.isEmpty)

    if ( ss.last.endsWith(".") ||  ss.last.endsWith("!")  ||  ss.last.endsWith("?")) {
      ss = ss.take(ss.size - 1) :+  ss.last.substring(0, ss.last.length - 1) :+ ss.last.substring(ss.last.size-1, ss.last.size)
    }
    ss = ss.filter(!_.isEmpty)

    ss.take(100)
  }


  def extractEnglish(translation: java.util.List[ScoredPhrasePairForSentence]): String = {
    var result = List[String]()
    val i = translation.iterator

    while(i.hasNext) {
      val trans = i.next()
      trans.getEnglish.foreach { word =>
        result = result :+ word
      }
    }

    result.mkString(" ")
  }


  def translate(s: String): String = {
    println(s.take(2000))
    val decoder = decfac.newDecoder(phraseTable, lm, dm)
    val ff = decoder.decode(clean(s))
    extractEnglish(ff)
  }


  def phrases(s: Seq[String]): Seq[String] = {
    println(s.take(2000))
    val ttt: Seq[ScoredPhrasePairForSentence] = tt(s.mkString(" "))
    ttt.map { t =>
      s"[LM: ${lmest(t.getEnglish.mkString(" "))}}]: [TM: " + t.toString + "]"
    }
  }

}
