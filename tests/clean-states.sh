#!/bin/bash

find . -type d -name '~state' -exec rm -r {} +
find . -type d -name '~zapusk.removed' -exec rm -r {} +
find . -type d -name '_state' -exec rm -r {} +
find . -type d -name '_zapusk.removed' -exec rm -r {} +
find . -type f -name 'result*.txt' -exec rm -r {} +