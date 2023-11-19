module Duplication

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

// Minimal size of code fragments taken into account
// for duplication calculation.
int GROUPSIZE = 6;

public str countDuplicates(list[list[str]] projectLines, int totalLines) {
    map[str k, int v] codeGroups = findDuplicates(projectLines);
    int duplicateLines = 0;
    for (group <- codeGroups) {
        duplicateLines += codeGroups[group];
    }

    real percentage = (duplicateLines / (totalLines * 1.0)) * 100;

    str rating = "--";
    if (percentage <= 20.0) { rating = "-"; }
    if (percentage <= 10.0) { rating = "o"; }
    if (percentage <= 5.0) { rating = "+"; }
    if (percentage <= 3.0) { rating = "++"; }

    println("Determining Duplication:");
    println("\tDuplication percentage: <duplicateLines> * 100 / <totalLines> = <percentage> %");
    println("\tDuplication rating: <rating>");

    return rating;
}

/* Create a mapping of blocks of code and the number of lines corresponding
   to that block.

   input:
   files - the list of files that have been converted into lists of strings.
   output:
   a map containing all distinct code groups with a size of 6 lines as the key
   and the number of duplicate lines found for that group.
*/
map[str, int] findDuplicates(list[list[str]] files) {
    // Key: group of 6 consecutive lines of code.
    // Value: the number of found duplicate lines that occurs in that group.
    map[str, int] codeGroups = ();
    for (file <- files) {
        bool inDuplicate = false;
        for (line <- index(file)[0..-(GROUPSIZE-1)]) {
            str group = concatGroup(file[line..line + GROUPSIZE]);
            int multiplier = 1;

            // If group is not a key yet, add it to the map.
            if (group notin codeGroups) {
                codeGroups[group] = 0;
                inDuplicate = false;
                continue;
            }

            // Number of lines duplicated should be counted for both instances
            // when the duplication for this block is caught for the first
            // time.
            if (codeGroups[group] == 0) { multiplier = 2; }
            else { multiplier = 1; }

            // Group is already in keys and this is the first group of a
            // potential series of groups found in the map.
            if (!inDuplicate) {
                codeGroups[group] += GROUPSIZE * multiplier;
                inDuplicate = true;
                continue;
            }
            // Group is already in keys and the group before was also a
            // duplicate group.
            codeGroups[group] += 1 * multiplier;
        }
    }

    return codeGroups;
}

str concatGroup(list[str] group) {
    str s = "";
    for (n <- index(group)) {
        s += group[n];
    }
    return s;
}
