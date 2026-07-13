# sum.R — example "script under test" for the test scaffold (scripts/run-tests.R).
#
# Reads integers, one per line, from STDIN and prints their sum to STDOUT.
# Try it by hand:   echo "3\n5\n7" | Rscript examples/sum.R   -> 15
# Run its tests:    Rscript scripts/run-tests.R examples/sum.R

con  <- file("stdin", open = "r")
nums <- suppressWarnings(as.integer(readLines(con, warn = FALSE)))
close(con)

nums <- nums[!is.na(nums)]      # ignore blank lines / non-numbers
cat(sum(nums), "\n", sep = "")
