#!/bin/bash

ruby -Wall texttest_fixture.rb > golden_master_output.txt
git diff --exit-code golden_master_output.txt

if [ $? -eq 0 ]
then
  echo "Identical! Great!"
else
  echo "Boo! You broke it!"
fi
