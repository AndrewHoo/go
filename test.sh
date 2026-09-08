#!/bin/bash
mkdir -p test-report
# go test -v
go test -coverprofile=test-report/coverage.out -covermode=atomic -json > test-report/test.json
cat test-report/test.json | go tool go-test-report -o test-report/test_report.html 1>/dev/null
cat test-report/test.json | go tool test-report -o test-report/test_report.md
go tool cover -html=test-report/coverage.out -o test-report/coverage.html
go tool go-covercheck test-report/coverage.out
# go tool go-covercheck --no-color --format md test-report/coverage.out > test-report/coverage.md

go tool go-covercheck --format md test-report/coverage.out > test-report/coverage.md
sed -i '/|$/! s/$/\\/' test-report/coverage.md
sed -i -e '/^[^|]/ { i\\n' -e ':a; n; ba; }' test-report/coverage.md


echo -n "<pre><code>" >> test-report/coverage.md
go tool go-covercheck --inspect test-report/coverage.out | awk 'NF {print saved $0; saved=""; next} {saved = saved $0 ORS}' >> test-report/coverage.md
echo -n "</code></pre>" >> test-report/coverage.md

sed -E -i '
  s/\x1b\[1mBY([^\x1b]*)\x1b\[0m/<span style="font-weight: bold; color: #DCB604;">\1<\/span>/g;
  s/\x1b\[1m([^\x1b]*)\x1b\[0m/<span style="font-weight: bold">\1<\/span>/g;
  s/\x1b\[31m([^\x1b]*)\x1b\[0m/<span style="color:red">\1<\/span>/g
  s/\x1b\[32m([^\x1b]*)\x1b\[0m/<span style="color:green">\1<\/span>/g;
  s/\x1b\[33m([^\x1b]*)\x1b\[0m/<span style="color: #D4AF37;">\1<\/span>/g;
  s/\x1b\[36;1m([^\x1b]*)\x1b\[0(;22)?m/<span style="font-weight: bold; color: #0284C7;">\1<\/span>/g;
  s/\x1b\[36m([^\x1b]*)\x1b\[0m/<span style="color: #0284C7;">\1<\/span>/g;
  s/\x1b\[38;5;153m([^\x1b]*)\x1b\[0m/<span style="color: #AFD7FF;">\1<\/span>/g;
  s/\x1b\[38;5;183m([^\x1b]*)\x1b\[0m/<span style="color: #D7AFFF;">\1<\/span>/g;
  s/\x1b\[38;5;209m([^\x1b]*)\x1b\[0m/<span style="color: #FF875F;">\1<\/span>/g;
  s/\x1b\[38;5;243m([^\x1b]*)\x1b\[0m/<span style="color: #767676;">\1<\/span>/g;
  s/\x1b\[38;5;255m([^\x1b]*)\x1b\[0m/<span style="color: white;">\1<\/span>/g;
  s/\x1b\[1m(<span style=")/\1font-weight: bold; /g;
' test-report/coverage.md

sed -i -e :a -e 's/^\(\(&nbsp;\)*\) /\1\&nbsp;/;ta' test-report/coverage.md