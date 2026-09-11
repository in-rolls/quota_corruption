import unittest

from scripts.audit_tables import contrasts, repeated_counts


class ContrastTests(unittest.TestCase):
    def test_contrasts_recover_four_cell_differences(self):
        neither, current, previous, both = 0.4, 0.5, 0.3, 0.2
        result = contrasts(
            current - neither,
            previous - neither,
            both - current - previous + neither,
        )
        self.assertAlmostEqual(result["both_vs_previous_only"], both - previous)
        self.assertAlmostEqual(result["both_vs_current_only"], both - current)
        self.assertAlmostEqual(result["both_vs_neither"], both - neither)
        self.assertNotAlmostEqual(result["interaction"], both - previous)

    def test_counts_reconcile_two_independent_margins(self):
        rows = [
            dict(
                state="example", current=8, previous=11, current_only=3, previous_only=6
            )
        ]
        self.assertEqual(repeated_counts(rows)[0]["both"], 5)
        rows[0]["previous_only"] = 7
        with self.assertRaises(ValueError):
            repeated_counts(rows)

    def test_impossible_negative_cell_is_rejected(self):
        rows = [
            dict(
                state="example", current=1, previous=1, current_only=2, previous_only=2
            )
        ]
        with self.assertRaises(ValueError):
            repeated_counts(rows)


if __name__ == "__main__":
    unittest.main()
