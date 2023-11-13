module Duplication_old

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

public real countDuplicates(loc projectLocation, int totalLines) {
    map[list[str] k, int v] codeGroups = findDuplicates(getProjectLines(projectLocation));
    int duplicateLines = 0;
    for (int lines <- codeGroups.v) {
        duplicateLines += lines;
    }

    return duplicateLines / (totalLines * 1.0);
}


public map[str, int] findDuplicates(list[list[str]] files) {
    // Key: group of 6 consecutive lines of code.
    // Value: the location of found duplicate line that occurs in that group.
    map[str, int] codeGroups = ();
    for (file <- files) {
        // bool inDuplicate = false;
        for (line <- index(file)[0..-5]) {
            str group = file[line] + file[line+1] + file[line+2]+ file[line+3] + file[line+4]+ file[line+5];
            if (group in codeGroups) {
                codeGroups[group] += 6;
            }
            else {
                codeGroups += (group:0);
            }
        }
    }

    println("<codeGroups>");
    return codeGroups;
}
