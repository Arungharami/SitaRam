import unittest

from retrieval import rank_passages


class TestLexicalRetrieval(unittest.TestCase):
    def setUp(self):
        self.passages = [
            {"id": "first", "kandaId": "bala", "englishText": "Valmiki meets Narada."},
            {"id": "second", "kandaId": "ayodhya", "englishText": "Rama accepts exile in the forest."},
        ]

    def test_question_retrieves_relevant_passage_instead_of_first_record(self):
        matches = rank_passages("Why did Rama accept exile?", self.passages)
        self.assertEqual([passage["id"] for passage, _ in matches], ["second"])

    def test_unrelated_or_blank_query_has_no_evidence(self):
        for question in ("quantum computers", "", "the and why"):
            self.assertEqual(rank_passages(question, self.passages), [])

    def test_filters_apply_before_ranking(self):
        self.assertEqual(rank_passages("exile", self.passages, filters={"kandaId": "bala"}), [])

    def test_limit_is_bounded(self):
        for limit in (0, -1, 51):
            with self.subTest(limit=limit), self.assertRaises(ValueError):
                rank_passages("exile", self.passages, limit=limit)
