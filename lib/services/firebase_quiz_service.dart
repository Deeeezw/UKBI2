import 'package:cloud_firestore/cloud_firestore.dart';
import '../QuizModel.dart';

class FirebaseQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all quizzes
  Stream<List<QuizModel>> getQuizzes() {
    return _firestore.collection('quizzes').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList(),
    );
  }

  // Get single quiz by ID
  Future<QuizModel?> getQuizById(String quizId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quizzes').doc(quizId).get();
      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  // ✅ Get questions for a quiz from the 'questions' SUBCOLLECTION
  Future<List<QuestionModel>> getQuizQuestions(String quizId) async {
    try {
      print('🔥 Fetching questions for quiz: $quizId');

      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')  // ✅ Subcollection
          .get();

      print('🔥 Found ${snapshot.docs.length} questions');

      if (snapshot.docs.isEmpty) {
        print('⚠️ No questions found in Firebase, using local fallback');
        return QuizDataStore.getQuestionsForQuiz(quizId);
      }

      final questions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print('📝 Question data: $data');
        return QuestionModel.fromFirestore(data);
      }).toList();

      return questions;
    } catch (e) {
      print('❌ Error getting questions: $e');
      // Fallback to local questions
      return QuizDataStore.getQuestionsForQuiz(quizId);
    }
  }

  // Add a new quiz (for admin)
  Future<String?> addQuiz(QuizModel quiz, List<QuestionModel> questions) async {
    try {
      // Add quiz
      DocumentReference quizRef = await _firestore.collection('quizzes').add(quiz.toJson());

      // Add questions to subcollection
      for (var question in questions) {
        await quizRef.collection('questions').add(question.toJson());
      }

      return quizRef.id;
    } catch (e) {
      print('Error adding quiz: $e');
      return null;
    }
  }
}
