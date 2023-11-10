module Volume

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

public map[list[str], int] countDuplicates(list[list[str]] files) {
    // Key: group of 6 consecutive lines of code.
    // Value: the location of found duplicate line that occurs in that group.
    map[list[str], int] codeGroups = ();
    for (file <- files) {
        int line = 0;
        while (line <= size(file) - 5) {
            group = file[line..line + 6];
            if (group notin codeGroups) {
                codeGroups += group;
            }
            else {
                codeGroups(group) += 6;
            }
        }
    }

    return codeGroups;
}

public tuple[map[list[str], int], int] countAdditionalLines(list[str] file, int line) {
    
}