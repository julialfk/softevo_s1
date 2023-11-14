module Main

import IO;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import Set;
import String;
import DateTime;
import Read;
import Volume;
import Duplication;
import ComplexityUnits;

// projectLocation main(|project://smallsql0.21_src|)
int overMain() {
    datetime startTime = now();
    main(|project://smallsql0.21_src|);
    datetime endSmol = now();
    main(|project://hsqldb-2.3.1/|);
    datetime endLarge = now();
    println("timespent smol: <endSmol - startTime>");
    println("timespent large: <endLarge - endSmol>");
    println("total time spent: <endLarge - startTime>");
    return 0;
}

int main(loc projectLocation) {
    list[loc] fileLocations = getFiles(projectLocation);
    list[list[str]] projectLines = getProjectLines(projectLocation);

    tuple[str rating, int lines] volume = countLinesProject(projectLines);
    println("Total number of lines: <volume.lines>");
    println("Volume rating: <volume.rating>");

    str duplicates = countDuplicates(projectLines, volume.lines);
    println("Duplication rating: <duplicates>");

    tuple[str CC, str US] CCUS = mainComplexity(fileLocations, volume.lines);
    println("complexity: <CCUS.CC>");
    println("unitsize: <CCUS.US>");

    println("\t \t \t | \t vol \t | \t CCPU \t |\tdupes \t | \t US \t |");
    println("---------------------------------------------------------------------------------------------------------");
    println("\t anal   \t | \t <volume.rating> \t | \t \t | \t <duplicates> \t | \t <CCUS.US> \t |");
    println("\t change \t | \t  \t | \t <CCUS.CC> \t | \t <duplicates> \t | \t \t |");
    println("\t test   \t | \t  \t | \t <CCUS.CC> \t | \t  \t | \t <CCUS.US> \t |");

    return 0;
}
