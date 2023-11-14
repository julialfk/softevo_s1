module Volume

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

// Count total number of lines in a project.
// Does count lines containing only brackets.
public tuple[str, int] countLinesProject(loc projectLocation){
    int lines = size(concat(getProjectLines(projectLocation)));

    if (lines <= 66000) { return <"++", lines>; }
    if (lines <= 246000) { return <"+", lines>; }
    if (lines <= 665000) { return <"o", lines>; }
    if (lines <= 1310000) { return <"-", lines>; }

    return <"--", lines>;
}

// Count total number of lines in a file.
public int countLinesFile(loc fileLocation){
    list[str] file = readFileLines(fileLocation);
    file = deleteComments(file);
    int lines = size(file);

    return lines;
}
