package com.sparkydots.util.questions

import com.sparkydots.util.views.txt.questions

class QuestionsGeneration {

  def cleanU(before: String): String = {
    before.replace("\\\\", "\\")
  }

  val singleDocumenMultipleQuestionstWrapper: (Seq[(String, String)], String) => String = (blocks: Seq[(String, String)], blockPrefix: String) => {
    val document = questions.single_question_document(blocks, blockPrefix)
    document.body
  }

  val makeq1: () => String = () => questions.q1(1, 2).body
  val makeq2: () => String = () => questions.q2(1).body
  val makeq3: () => String = () => questions.q3(1, 2).body

  val availableQuestions = Seq(
    "q1" -> makeq1,
    "q2" -> makeq2,
    "q3" -> makeq3
  ).toMap


  def createQuestion(qid: String): String = {
    cleanU {
      availableQuestions.get(qid).map {
        q =>
          val body = q()
          val blocks = (1 to 3).map(i => (i.toString, availableQuestions.get("q" + i.toString).get()))
          singleDocumenMultipleQuestionstWrapper(blocks, "Question: ")
      }.getOrElse(s"No question with id $qid")

    }

  }



}
