# Percon To Excel v1.1, 22 Oct 2013
# Format Percon output summary to tabular data file for import to Excel.
# Author: Lev I. Uralsky (Institute of Molecular Genetics, Moscow, Russia)
# v1.0, 17 Mar 2013 First release
# v1.1, 22 Oct 2013 Correct formatting in 'check_sum' fields. Adding comments.

# Usage: gawk -f prcn2excel-v1.1.awk input1.prcn input2.prcn ... > output.txt

BEGIN { summary = 0; j = 0; SUBSEP = "\t"; }

/^total OK format doks/ { summary = 1; }

/^[[:space:]]+DB[[:space:]]+:[[:space:]]/ {
  summary = 0;
  j = 0;
#  FileName = FileName SUBSEP $NF;
  FileName = FileName SUBSEP FILENAME;
}

{
  if (summary) {
#   Prepare input line

#   Remove empty spaces around an equal sign
    gsub(/[[:space:]]+?=/, "=", $0);
    gsub(/=[[:space:]]+?/, "=", $0);
#   Remove word 'monomers'
    sub(/^monomers /, "", $0);
#   Remove long sentence 'M1 subtypes distribution total: '
    sub(/^M1 subtypes.+?: /, "", $0);
#   Replace spaces before 'check_sum' with tab
    sub(/[[:space:]]+?check_sum/, "\tcheck_sum", $0);
#   Replace 4+ spaces with tab
    gsub(/[[:space:]]{4,}/, SUBSEP, $0);
#   Replace 2+ spaces with one space
    gsub(/[[:space:]]{2,}/, " ", $0);
#   Remove space at the beginning of ' M1.'
    sub(/ M1./, SUBSEP "M1.", $0);
#   Remove all spaces
    sub(/^[[:space:]]+?/, "", $0);

    if ($0 ~ /=/) {
#     Split line with multiple columns
      k = split($0, se, SUBSEP);
      if (k > 1) {
        for (i = 1; i <= k; i++) {
          if (se[i] && (se[i] ~ /=/)) {
            a[++n] = se[i];
          }
        }
      } else {
        a[++n] = $0;
      }
#     Populate array with composite key (name, counter) and value (after equal sign)
      for (i = 1; i <= n; i++) {
        k = split(a[i], se, "=");
        if (b[se[1],j] != "") {
          b[se[1],j] = b[se[1],j] SUBSEP se[2];
        } else {
          b[se[1],j] = se[2];
        }
        ++j;
      }
      n = 0;
    }
  }
}

END {
# Create new combined array
  k = asorti(b, a);
  for (i = 1; i <= k; i++) {
    split(a[i], key, SUBSEP);
    c[key[2]] = key[1] SUBSEP b[key[1],key[2]];
  }
# Print sorted values
  printf("name%s\n", FileName);
  for (i = 0; i <= k; i++) {
    print c[i];
  }
}
