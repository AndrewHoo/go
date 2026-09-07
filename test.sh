#!/bin/bash
mkdir -p test-report
go test -coverprofile=test-report/coverage.out -covermode=atomic -json ./... > test-report/test.json
cat test-report/test.json | go-test-report -o test-report/test_report.html
go tool cover -html=test-report/coverage.out -o test-report/coverage.html