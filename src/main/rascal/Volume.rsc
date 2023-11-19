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
public tuple[str, int] countLinesProject(list[list[str]] projectLines){
    int lines = size(concat(projectLines));
    str rating = "--";

    if (lines <= 66000) { rating = "++"; }
    if (lines <= 246000) { rating = "+"; }
    if (lines <= 665000) { rating = "o"; }
    if (lines <= 1310000) { rating = "-"; }

    println("Determining Volume:");
    println("\tTotal number of lines: <lines>");
    println("\tVolume rating: <rating>");

    return <rating, lines>;
}

// Count total number of lines in a file.
public int countLinesFile(loc fileLocation){
    list[str] file = readFileLines(fileLocation);
    file = deleteComments(file);
    int lines = size(file);

    return lines;
}
