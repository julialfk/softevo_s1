module Volume

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import Read;

// public int mainVolume(loc projectLocation){
//     list[loc] fileLocations = getFiles(projectLocation);
//     return countLinesProject(fileLocations);
// }

// Count total number of lines in a project.
// Does count lines containing only brackets.
public int countLinesProject(list[list[str]] projectLines){
    return size(concat(projectLines));
}

// Count total number of lines in a file.
public int countLinesFile(loc fileLocation){
    list[str] file = file2Array(fileLocation);
    file = deleteComments(file);
    // println("lines: <file>");
    int lines = size(file);

    return lines;
}
