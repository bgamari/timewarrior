#!/usr/bin/env python2.7
# -*- coding: utf-8 -*-
###############################################################################
#
# Copyright 2006 - 2017, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# http://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import sys
import os
import unittest
from datetime import datetime
# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Timew, TestCase

# Test methods available:
#     self.assertEqual(a, b)
#     self.assertNotEqual(a, b)
#     self.assertTrue(x)
#     self.assertFalse(x)
#     self.assertIs(a, b)
#     self.assertIsNot(substring, text)
#     self.assertIsNone(x)
#     self.assertIsNotNone(x)
#     self.assertIn(substring, text)
#     self.assertNotIn(substring, text
#     self.assertRaises(e)
#     self.assertRegexpMatches(text, pattern)
#     self.assertNotRegexpMatches(text, pattern)
#     self.tap("")

class TestContinue(TestCase):
    def setUp(self):
        """Executed before each test in the class"""
        self.t = Timew()

    def test_continue_nothing(self):
        """Verify that continuing an empty db is an error"""
        code, out, err = self.t.runError("continue")
        self.assertIn("There is no previous tracking to continue.", err)

    def test_continue_open(self):
        """Verify that continuing an open interval is an error"""
        code, out, err = self.t("start tag1 tag2")
        self.assertIn("Tracking tag1 tag2\n", out)

        code, out, err = self.t.runError("continue")
        self.assertIn("There is already active tracking.", err)

    def test_continue_closed(self):
        """Verify that continuing a closed interval works"""
        code, out, err = self.t("start tag1 tag2")
        self.assertIn("Tracking tag1 tag2\n", out)

        code, out, err = self.t("stop")
        self.assertIn("Recorded tag1 tag2\n", out)

        code, out, err = self.t("continue")
        self.assertIn("Tracking tag1 tag2\n", out)

    def test_continue_with_multiple_ids(self):
        """Verify that 'continue' with multiple ids is an error"""
        code, out, err = self.t.runError("continue @1 @2")
        self.assertIn("You can only specify one ID to continue.\n", err)

    def test_continue_with_invalid_id(self):
        """Verify that 'continue' with invalid id is an error"""
        code, out, err = self.t.runError("continue @1")
        self.assertIn("ID '@1' does not correspond to any tracking.\n", err)

    def test_continue_with_id_without_active_tracking(self):
        """Verify that continuing a specified interval works"""
        code, out, err = self.t("start FOO")
        self.assertIn("Tracking FOO\n", out)

        code, out, err = self.t("stop")
        self.assertIn("Recorded FOO\n", out)

        code, out, err = self.t("start BAR")
        self.assertIn("Tracking BAR\n", out)

        code, out, err = self.t("stop")
        self.assertIn("Recorded BAR\n", out)

        code, out, err = self.t("continue @2")
        self.assertIn("Tracking FOO\n", out)

    def test_continue_with_id_with_active_tracking(self):
        """Verify that continuing a specified interval stops active tracking"""
        code, out, err = self.t("start FOO")
        self.assertIn("Tracking FOO\n", out)

        code, out, err = self.t("stop")
        self.assertIn("Recorded FOO\n", out)

        code, out, err = self.t("start BAR")
        self.assertIn("Tracking BAR\n", out)

        code, out, err = self.t("continue @2")
        self.assertIn("Recorded BAR\nTracking FOO\n", out)

if __name__ == "__main__":
    from simpletap import TAPTestRunner
    unittest.main(testRunner=TAPTestRunner())

# vim: ai sts=4 et sw=4 ft=python
